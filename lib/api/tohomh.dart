import 'dart:convert';

import 'api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Tohomh implements API {
  @override
  String get origin => "土豪漫画";

  @override
  String get originTag => 'Tohomh';

  @override
  RuleContentType get ruleContentType => RuleContentType.MANGA;

  Future<List<SearchItem>> commonParse(String url)async{
    final res =
        await http.get(url);
    return parse(res.body).querySelectorAll('div.mh-item').map((item) {
      final style = item.querySelector('p.mh-cover').attributes["style"];
      return SearchItem(
        api: this,
        cover: '${style.substring(style.indexOf('(') + 1, style.indexOf(')'))}',
        name: '${item.querySelector('h2 a').text}',
        author: '',
        chapter: '${item.querySelector('.chapter a').text}',
        description:
        '评分 ${item.querySelector('.zl .mh-star-line').attributes["class"].split(' ').last}',
        url:
        'https://www.tohomh123.com${item.querySelector('h2 a').attributes["href"]}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(String query, int page, int pageSize) async {
    return commonParse('https://www.tohomh123.com/f-1-------hits--$page.html');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse('https://www.tohomh123.com/action/Search?keyword=$query&page=$page');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('#detail-list-select-2 a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}',
              url: 'https://www.tohomh123.com${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get('$url');
    final body = res.body;

/*
var imgDomain = 'https://mh1.zhengdongwuye.cn';
var did=33705;
var sid=10;
var iid = 2;//1;
var pcount = 95;
var finished = true;
var nextPlayDataUrl = '';
var bq = 0;
var pl = 'https://mh3.zhengdongwuye.cn/upload/yulezhishang/8064529/0000.jpg';
var bqimg = '/pic/banquan.png';
*/
    final did = RegExp('var did\\s*=\\s*(\\d+)').firstMatch(body)[1];
    final sid = RegExp('var sid\\s*=\\s*(\\d+)').firstMatch(body)[1];
    final iid = int.parse(RegExp('var iid\\s*=\\s*(\\d+)').firstMatch(body)[1]);
    final pcount =
        int.parse(RegExp('var pcount\\s*=\\s*(\\d+)').firstMatch(body)[1]);
    final urls = List<String>(pcount);
    for (var i = 0; i < pcount; i++) {
      urls[i] =
          "https://www.tohomh123.com/action/play/read?did=$did&sid=$sid&iid=${iid+1}";
    }
    return Future.wait(urls.map((u) async {
      final r = await http.get('$u');
      return jsonDecode(r.body)["Code"];
    }));
  }
}
