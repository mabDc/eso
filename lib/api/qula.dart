import 'dart:convert';
import 'dart:io';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';

import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class Qula implements API {
  @override
  String get origin => '笔趣阁';

  @override
  String get originTag => 'Qula';

  @override
  int get ruleContentType => API.NOVEL;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return search('一', page, pageSize);
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    if (page > 1) return <SearchItem>[];
    // final res = await http
    //     .get('https://sou.xanbhx.com/search?siteid=qula&q=$query', headers: {
    //   "User-Agent":
    //       "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36"
    // });
    HttpClient client = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    final request = await client.getUrl(
        Uri.parse("https://sou.xanbhx.com/search?siteid=qula&q=$query"));
    final response = await request.close();
    final responseBody = await response.transform(Utf8Decoder()).join();
    return parse(responseBody)
        .querySelectorAll('.search-list li')
        .skip(1)
        .map((item) => SearchItem(
              api: this,
              cover: null,
              name: '${item.querySelector('.s2').text}'.trim(),
              author: '${item.querySelector('.s4').text}',
              chapter: '${item.querySelector('.s3').text}',
              description:
                  '${item.querySelectorAll('.s1, .s7, .s6').map((span) => span.text).join(' ')}',
              url: '${item.querySelector('.s2 a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get(url);
    final list = parse(res.body).querySelectorAll('#list a');
    return list
        .skip(list.length > 12 ? 12 : 0)
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}'.trim(),
              url: '$url/${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    return parse(res.body)
        .querySelector('#content')
        .text
        .replaceFirst('chaptererror();', '')
        .split('　　');
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[];
  }
}
