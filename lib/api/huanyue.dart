import 'dart:convert';

import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'api.dart';

class Huanyue implements API {
  @override
  String get origin => '幻月书院';

  @override
  String get originTag => 'Huanyue';

  @override
  RuleContentType get ruleContentType => RuleContentType.NOVEL;

  @override
  Future<List<SearchItem>> discover(
      String query, int page, int pageSize) async {
    if (query == '') {
      query = discoverMap().values.first;
    }
    final res =
        await http.get('http://m.huanyue123.com/ph/${query}_$page.html');
    final dom = parse(utf8.decode(res.bodyBytes));
    return dom
        .querySelectorAll('.hot_sale')
        .map((item) => SearchItem(
              api: this,
              cover: '${item.querySelector('img').attributes["data-original"]}',
              name: '${item.querySelector('.title').text}'.trim(),
              author: '${item.querySelector('.author').text}'.trim(),
              chapter: '',
              description: '${item.querySelector('.review').text}'.trim(),
              url:
                  'http://m.huanyue123.com${item.querySelector('a').attributes["href"]}all.html',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http.post("http://m.huanyue123.com/s.php", body: {
      "keyword": query,
      "t": '1',
    });
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

  @override
  Map<String, String> discoverMap() {
    return {
      "周榜-全部": "week",
      "周榜-玄幻": "week1",
      "周榜-仙侠": "week2",
      "周榜-都市": "week3",
      "周榜-历史": "week4",
      "周榜-网游": "week5",
      "周榜-科幻": "week6",
      "周榜-灵异": "week7",
      "周榜-言情": "week8",
      "周榜-其他": "week9",
      "月榜-全部": "month",
      "月榜-玄幻": "month1",
      "月榜-仙侠": "month2",
      "月榜-都市": "month3",
      "月榜-历史": "month4",
      "月榜-网游": "month5",
      "月榜-科幻": "month6",
      "月榜-灵异": "month7",
      "月榜-言情": "month8",
      "月榜-其他": "month9",
      "总榜-全部": "all",
      "总榜-玄幻": "all1",
      "总榜-仙侠": "all2",
      "总榜-都市": "all3",
      "总榜-历史": "all4",
      "总榜-网游": "all5",
      "总榜-科幻": "all6",
      "总榜-灵异": "all7",
      "总榜-言情": "all8",
      "总榜-其他": "all9",
    };
  }
}
