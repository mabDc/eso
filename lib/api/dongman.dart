import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class Dongman implements API{
  @override
  String get origin => '咚漫';
  @override
  String get originTag => 'Dongman';
  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(String url)async{
    String headers = jsonEncode({
      "Referer":"https://www.dongmanmanhua.cn",
    });
    final res = await http.get(url);
    final dom = parse(res.body);
    return dom.querySelectorAll('.card_lst li').map((item) => SearchItem(
      api: this,
      cover: '${item.querySelector('img').attributes["src"]}@headers$headers',
      name: '${item.querySelector('.subj').text}',
      author: '${item.querySelector('.author').text}',
      chapter: '',
      description: '${item.querySelector('.genre').text}',
      url: 'https:${item.querySelector('a').attributes["href"]}',
    )).toList();
  }

  @override
  Future<List<SearchItem>> discover(Map<String,DiscoverPair> params, int page, int pageSize) {
    return commonParse("https://www.dongmanmanhua.cn");
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse("https://www.dongmanmanhua.cn/search?keyword=$query&page=$page");
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final dom = parse(res.body);
    final href = dom.querySelector('#_listUl a').attributes["href"];
    final split = href.lastIndexOf("=") + 1;
    final half = href.substring(0, split);
    final len = int.parse(href.substring(split));
    List<ChapterItem> chapters = List<ChapterItem>(len);
    for(int i =0;i<len;i++){
      chapters[i] = ChapterItem(
        cover: null,
        time: null,
        name: '${i+1}',
        url:'https:$half${i+1}',
      );
    }
    return chapters;
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    String headers = jsonEncode({
      "Referer":"https://www.dongmanmanhua.cn",
    });
    final list = parse(res.body).querySelectorAll('#_imageList img').map((p) => p.attributes["data-url"].replaceFirst('?x-oss-process=image/quality,q_90', '')).toList();
    list[0] = list[0]+"@headers"+headers;
    return list;
  }
  @override
  List<DiscoverMap> discoverMap() {
    return [];
  }
}