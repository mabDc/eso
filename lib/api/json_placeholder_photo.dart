import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/utils.dart';
import 'package:http/http.dart' as http;

class JSONPlaceHolderPhoto implements API {
  @override
  String get host => "https://jsonplaceholder.typicode.com";

  @override
  String get origin => "json_placeholder_photo";

  @override
  String get originTag => "json_placeholder_photo";

  @override
  int get ruleContentType => API.MANGA;

  @override
  Future<List<DiscoverMap>> discoverMap() async {
    return <DiscoverMap>[
      DiscoverMap("photo", <DiscoverPair>[
        DiscoverPair("photo", ""),
      ]),
    ];
  }

  @override
  Future<List<SearchItem>> discover(Map<String, DiscoverPair> params, int page, int pageSize) async {
    return <SearchItem>[
      SearchItem(
        api: this,
        name: 'photos',
        author: 'json_placeholder',
        description: '5000 photos',
        url: '/photos/',
        cover: 'https://via.placeholder.com/600/92c952',
        chapter: '',
        tags: [],
      )
    ];
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get(host + url);
    final list = jsonDecode(res.body) as List;
    return list
        .map((d) => ChapterItem(
              name: '${d['title']}',
              url: '$url${d['id']}',
              cover: '${d['thumbnailUrl']}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(host + url);
    return ["${jsonDecode(res.body)["url"]}"];
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) {
    Utils.toast("无搜索");
    throw UnimplementedError();
  }
}
