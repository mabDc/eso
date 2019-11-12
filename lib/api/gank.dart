import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';

class Gank implements API {
  @override
  String get origin => '干货集中营';

  @override
  String get originTag => 'Gank';

  @override
  int get ruleContentType => API.MANGA;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return <SearchItem>[
      SearchItem(
        api: this,
        cover: 'http://gank.io/static/images/special/work.png',
        name: '干货集中营-妹子图',
        author: 'gank.io',
        chapter: '',
        description: '每日分享妹子图和技术干货，还有供大家中午休息的休闲视频\n妹子图每页10张，设置100页，前70页有图',
        url: '',
      )
    ];
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    
    return <SearchItem>[];
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    return List.generate(
        100,
        (index) => ChapterItem(
              cover: null,
              name: '${1 + index}',
              time: null,
              url: 'http://gank.io/api/data/福利/10/$index',
            ));
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    return (json["results"] as List)
        .map((results) => '${results["url"]}')
        .toList();
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[];
  }
}
