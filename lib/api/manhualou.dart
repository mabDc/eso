import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Manhualou implements API {
  @override
  String get origin => '漫画楼';

  @override
  String get originTag => 'Manhualou';

  @override
  RuleContentType get ruleContentType => RuleContentType.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final dom = parse(res.body);
    return dom
        .querySelectorAll('#contList li')
        .map((item) => SearchItem(
              api: this,
              cover: '${item.querySelector('img').attributes["src"]}',
              name: '${item.querySelector('p').text}',
              author: '',
              chapter: '${item.querySelector('.tt').text}',
              description: '${item.querySelector('.updateon').text}',
              url: '${item.querySelector('a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(String query, int page, int pageSize) {
    return commonParse("https://www.manhualou.com/list_$page/");
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        "https://www.manhualou.com/search/?keywords=$query&page=$page");
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('#chapter-list-1 a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}'.trim(),
              url: 'https://www.manhualou.com${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final json =
        RegExp("chapterImages\\s*=\\s*([^;]*)").firstMatch(res.body)[1];
    return (jsonDecode(json) as List)
        .map((s) => 'https://restp.dongqiniqin.com/$s')
        .toList();
  }
}
