import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../database/chapter_item.dart';
import '../../database/search_item.dart';
import '../api.dart';

class Clicli implements API {
  @override
  String get origin => 'Clicli';

  @override
  String get originTag => 'Clicli';

  @override
  int get ruleContentType => API.VIDEO;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    return (json["posts"] as List)
        .map((item) => SearchItem(
              tags: <String>[],
              api: this,
              cover: null,
              name: '${item["title"]}',
              author: '${item["uname"]}',
              chapter: '${item["time"]}',
              description: '${item["sort"]} ${item["tag"]}',
              url:
                  'https://api.clicli.us/videos?page=1&pageSize=1000&pid=${item["id"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return commonParse(
        'https://api.clicli.us/search/posts?key=%E9%83%BD%E5%B8%82');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse('https://api.clicli.us/search/posts?key=$query');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    final videos = json["videos"];
    if (videos == null) return <ChapterItem>[];
    return (videos as List).map((chapter) {
      return ChapterItem(
        cover: null,
        name: '${chapter["oid"]} ${chapter["title"]}',
        time: '${chapter["time"]}'.trim().substring(0, 16),
        url: '${chapter["content"]}',
      );
    }).toList();
  }

  @override
  Future<List<String>> content(String url) async {
    return <String>[url];
  }

  String clear(String s) => s == '' ? null : s;

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[];
  }
}
