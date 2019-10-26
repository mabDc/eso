import 'dart:convert';

import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'api.dart';
class Buka implements API {
  @override
  String get origin => "布卡";

  @override
  String get originTag => "Buka";

  @override
  RuleContentType get ruleContentType => RuleContentType.MANGA;

  Future<List<SearchItem>> commonParse(String url, Map<String, String> body) async {
    final res = await http.post(url, body: body);
    final json = jsonDecode(res.body);
    return (json["datas"]["items"] as List).map((item) => SearchItem(
      api: this,
      cover: '${item["logo"]}',
      name: '${item["name"]}',
      author: '${item["author"]}',
      chapter: '',
      description: '',
      url:'${item["mid"]}',
    )).toList();
  }

  @override
  Future<List<SearchItem>> discover(String query, int page, int pageSize) async {
    return commonParse("http://m.buka.cn/search/ajax_search", {
      "key":'1',
      "start":'${15*(page-1)}',
      "count":'$pageSize',
    });
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse("http://m.buka.cn/search/ajax_search", {
      "key":query,
      "start":'${15*(page-1)}',
      "count":'$pageSize',
    });
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final cid = '$url';
    final res = await http.get('http://m.buka.cn/m/$cid');
    return parse(res.body)
        .querySelectorAll('#episodes a')
        .map((item) => ChapterItem(
      cover: null,
      time: null,
      name: '${item.text}'.trim(),
      url: 'http://buka.cn${item.attributes["href"]}',
    )).toList().reversed.toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    return  RegExp("class=\"lazy\"\\s*data-original=\"([^\"]*)").allMatches(res.body).map((m) => m[1]).toList();
  }

}