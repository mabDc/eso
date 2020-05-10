import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';
import 'package:html/parser.dart' show parse;

class Huya implements API {
  @override
  String get origin => '虎牙';

  @override
  String get originTag => 'Huya';

  @override
  int get ruleContentType => API.VIDEO;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return search('一', page, pageSize);
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http.get(
        'https://search.cdn.huya.com/?m=Search&do=getSearchContent&q=$query&uid=0&v=4&typ=-5&livestate=0&rows=$pageSize&start=${pageSize * (page - 1)}');
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    List searchItem = <SearchItem>[];
    (json["response"]["3"]["docs"] as List)
        .forEach((item) => searchItem.add(SearchItem(
              tags: <String>[],
              api: this,
              cover: '${item["game_imgUrl"]}',
              name: '${item["game_roomName"]}',
              author: '${item["game_nick"]}',
              chapter: '',
              description: '${item["game_introduction"]} ${item["tag_name"]}',
              url: 'https://m.huya.com/${item["game_privateHost"]}',
            )));
    return searchItem;
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final list = [
      {"sDisplayName": "流畅", "iBitRate": 500},
      {"sDisplayName": "高清", "iBitRate": 1200},
      {"sDisplayName": "超清", "iBitRate": 2000},
      {"sDisplayName": "蓝光4M", "iBitRate": 4000},
      {"sDisplayName": "蓝光8M", "iBitRate": 0},
    ];

    final res = await http.get('$url', headers: {
      "User-Agent":
          "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Mobile Safari/537.36"
    });

    final src = parse(res.body)
        .querySelector('#html5player-video')
        .attributes["src"]
        .split(RegExp('_\\d+'));
    return list
        .map((chapter) => ChapterItem(
              cover: null,
              name: '${chapter["sDisplayName"]}',
              time: null,
              url: 'https:${src[0]}_${chapter["iBitRate"]}${src[1]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    return <String>[url];
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[];
  }
}
