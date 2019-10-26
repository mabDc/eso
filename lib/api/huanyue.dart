import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class Huanyue implements API {
  @override
  String get origin => '幻月书院';

  @override
  String get originTag => 'Huanyue';

  @override
  RuleContentType get ruleContentType => RuleContentType.NOVEL;

  Future<List<SearchItem>> commonParse(
      String url, Map<String, String> body) async {
    final res = await http.post(url, body: body);
    final items =
        parse(utf8.decode(res.bodyBytes)).querySelectorAll('.hot_sale');
    return items
        .skip(1)
        .map((item) => SearchItem(
              api: this,
              cover: null,
              name: '${item.querySelector('.title').text}',
              author: '${item.querySelectorAll('.author')[0].text}',
              chapter: '${item.querySelectorAll('.author')[1].text}',
              description: '',
              url:
                  'http://m.huanyue123.com${item.querySelector('a').attributes["href"]}all.html',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(String query, int page, int pageSize) {
    return commonParse("http://m.huanyue123.com/s.php", {
      "keyword": '都市',
      "t": '1',
    });
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse("http://m.huanyue123.com/s.php", {
      "keyword": query,
      "t": '1',
    });
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(utf8.decode(res.bodyBytes))
        .querySelectorAll('#chapterlist a')
        .skip(1)
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}'.trim(),
              url: 'http://m.huanyue123.com${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final text = parse(utf8.decode(res.bodyBytes))
        .querySelector('#chaptercontent')
        .text
        .split('\n')[3];
    return text.split(text.substring(0, 4)).map((s) => "　　$s").toList();
  }
}
