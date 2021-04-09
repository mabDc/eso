import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/utils.dart';
import 'package:http/http.dart' as http;

class JSONPlaceHolder implements API {
  @override
  String get host => "https://jsonplaceholder.typicode.com";

  @override
  String get origin => "json_placeholder";

  @override
  String get originTag => "json_placeholder";

  @override
  int get ruleContentType => API.NOVEL;

  @override
  Future<List<DiscoverMap>> discoverMap() async {
    return <DiscoverMap>[
      DiscoverMap("文字", <DiscoverPair>[
        DiscoverPair("文字", ""),
      ]),
    ];
  }

  @override
  Future<List<SearchItem>> discover(Map<String, DiscoverPair> params, int page, int pageSize) async {
    return <SearchItem>[
      SearchItem(
        api: this,
        name: 'todos',
        author: 'json_placeholder',
        description: '200 todos',
        url: '/todos/',
        cover: 'https://via.placeholder.com/600/771796',
        chapter: '',
        tags: [],
      ),
      SearchItem(
        api: this,
        name: 'comments',
        author: 'json_placeholder',
        description: '500 comments',
        url: '/comments/',
        cover: 'https://via.placeholder.com/600/24f355',
        chapter: '',
        tags: [],
      ),
    ];
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get(host + url);
    final list = jsonDecode(res.body) as List;
    switch (url) {
      case "/todos/":
        return list
            .map((d) => ChapterItem(
                  name: '${d['title']}',
                  time: 'completed: ${d['completed']}',
                  url: '$url${d['id']}',
                ))
            .toList();
      case "/comments/":
        return list
            .map((d) => ChapterItem(
                  name: '${d['name']}',
                  time: 'email: ${d['email']}',
                  url: '$url${d['id']}',
                ))
            .toList();
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(host + url);
    return [res.body];
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) {
    Utils.toast("无搜索");
    throw UnimplementedError();
  }
}
