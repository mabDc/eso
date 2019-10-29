import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class TencentManga implements API {
  @override
  String get origin => '腾讯动漫';

  @override
  String get originTag => 'TencentManga';

  @override
  int get ruleContentType => API.MANGA;

  @override
  Future<List<SearchItem>> discover(
      Map<String,DiscoverPair> params, int page, int pageSize) async {
    final res =
        await http.get("https://ac.qq.com/Comic/all/search/time/page/$page");
    final dom = parse(res.body);
    return dom
        .querySelectorAll('.ret-search-list li')
        .map((item) => SearchItem(
              api: this,
              cover: '${item.querySelector('img').attributes["data-original"]}',
              name: '${item.querySelector('h3 a').text}',
              author: '${item.querySelector('.ret-works-author').text}',
              chapter: '${item.querySelector('.mod-cover-list-text').text}',
              description: '${item.querySelector('.ret-works-decs').text}',
              url:
                  'https://ac.qq.com${item.querySelector('a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http
        .get("https://ac.qq.com/Comic/searchList?search=$query&page=$page");
    final dom = parse(res.body);
    return dom
        .querySelectorAll('.mod_book_list li')
        .map((item) => SearchItem(
              api: this,
              cover:
                  '${item.querySelector('img').attributes["data-original"]}',
              name: '${item.querySelector('h4').text}',
              author: '',
              chapter: '${item.querySelector('.mod_book_update').text}',
              description: '',
              url:
                  'https://ac.qq.com${item.querySelector('a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('.chapter-page-all span')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name:
                  '${item.querySelector('i').className == "ui-icon-pay" ? "🔒" : ""}${item.text}'.trim(),
              url:
                  'https://ac.qq.com${item.querySelector('a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final s = RegExp("DATA        = '([^']*)").firstMatch(res.body)[1];
    final pic = base64Decode(s.substring(s.length % 4));
    final json = RegExp("\"picture\":([^\\]]*\\])").firstMatch(String.fromCharCodes(pic))[1];
    return (jsonDecode(json) as List).map((s) => '${s["url"]}').toList();
  }
  @override
  List<DiscoverMap> discoverMap() {
    return [];
  }
}
