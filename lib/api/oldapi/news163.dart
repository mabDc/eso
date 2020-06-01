import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../database/chapter_item.dart';
import '../../database/search_item.dart';
import '../api.dart';

class News163 implements API {
  @override
  String get origin => '网易要闻';

  @override
  String get originTag => 'News163';

  @override
  int get ruleContentType => API.RSS;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return <SearchItem>[
      SearchItem(
        tags: <String>[],
        api: this,
        cover:
            'https://ss3.bdstatic.com/yrwDcj7w0QhBkMak8IuT_XF5ehU5bvGh7c50/logopic/ecb601f5df22edd5e7e5dfb6126e0a38_fullsize.jpg',
        name: '网易要闻',
        author: 'RSS',
        chapter: '',
        description: '',
        url: 'http://47.105.79.245/v2/article/newest',
      )
    ];
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return <SearchItem>[];
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.post('http://47.105.79.245/v2/article/newest',
        body: jsonEncode({"articleId": "0", "feedId": "98"}),
        headers: {
          "User-Agent": "okhttp/3.10.0",
          "content-type": "application/json"
        });
    final json = jsonDecode(res.body);
    return (json["data"]["data"] as List)
        .map((chapter) {
          return ChapterItem(
            cover: '${chapter["thumbnail"]}',
            name: '${chapter["title"]}',
            time: '${chapter["createTime"]}',
            url: 'http://47.105.79.245/v2/text/${chapter["id"]}',
          );
        })
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    return <String>['${json["data"]["content"]}'];
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[];
  }
}
