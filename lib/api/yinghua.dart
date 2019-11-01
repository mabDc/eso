import 'dart:convert';

import 'api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Yinghua implements API {
  @override
  String get origin => "樱花动漫";

  @override
  String get originTag => 'Yinghua';

  @override
  int get ruleContentType => API.VIDEO;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    return parse(res.body)
        .querySelectorAll('.am-list>li')
        .map((item) {
      return SearchItem(
        api: this,
        cover: '${item.querySelector('img').attributes['data-original']}',
        name: '${item.querySelector('h2').text}',
        author: '${item.querySelector('.am_list_juqing').text}',
        chapter: '',
        description: '${item.querySelector('.am_list_item_text').text}',
        url:
            'https://www.6111.tv${item.querySelector('a').attributes['href']}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return commonParse('https://www.6111.tv/yinghua/${params["类型"].value}');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse('https://www.6111.tv/search.php?page=$page&searchword=$query&searchtype=');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('#fjtype li>a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}',
              url: 'https://www.6111.tv${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    return <String>[];
  }

  @override
  List<DiscoverMap> discoverMap() {
    // http://www.migudm.cn/comic/list_emotion_china_end_shaonv_time_p1/
    return <DiscoverMap>[
      DiscoverMap('类型', <DiscoverPair>[
        DiscoverPair('国产动漫', 'dongman1.html'),
        DiscoverPair('日本动漫', 'dongman2.html'),
        DiscoverPair('欧美动漫', 'dongman3.html'),
        DiscoverPair('动漫电影', 'dongman4.html'),
        DiscoverPair('动态漫画', 'dongman5.html'),
      ]),
    ];
  }
}
