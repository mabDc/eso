import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../database/chapter_item.dart';
import '../../database/search_item.dart';
import '../api.dart';

class Missevan implements API {
  @override
  String get origin => '猫耳FM';

  @override
  String get originTag => 'Missevan';

  @override
  int get ruleContentType => API.AUDIO;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    final searchItems = <SearchItem>[];
    for (var item in json["info"]["Datas"] as List) {
      var episodes = item["episodes"] as List;
      if (episodes.length == 0) continue;
      searchItems.add(SearchItem(
        tags: <String>[],
        api: this,
        cover: '${item["cover"]}',
        name: '${item["name"]}',
        author: '${item["catalog_name"]}',
        chapter: '${item["newest"]}',
        description: '${item["abstract"]}',
        url:
            'https://www.missevan.com/dramaapi/getdramabysound?sound_id=${episodes[0]["sound_id"]}',
      ));
    }
    return searchItems;
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return commonParse(
        'https://www.missevan.com/dramaapi/search?s=%E8%AF%9B%E4%BB%99&page=1');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        'https://www.missevan.com/dramaapi/search?s=$query&page=$page');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    return (json["info"]["episodes"]["episode"] as List).map((chapter) {
      final createTime = chapter["create_time"];
      final time = DateTime.fromMillisecondsSinceEpoch(
          ((createTime is int) ? createTime : int.parse(createTime)) * 1000);
      final pay = chapter["need_pay"];
      return ChapterItem(
        cover: null,
        name: '${pay == 0 ? "" : "🔒"}${chapter["name"]}',
        time: '$time'.trim().substring(0, 16),
        url:
            'https://www.missevan.com/sound/getsound?soundid=${chapter["sound_id"]}',
      );
    }).toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    final sound = json["info"]["sound"];
    final cover = '${sound["cover_image"]}';
    final url2 =
        '${clear(sound["soundurl_128"]) ?? clear(sound["soundurl_64"]) ?? clear(sound["soundurl_32"]) ?? clear(sound["soundurl"])}';
    return clear(url2) == null
        ? <String>[]
        : <String>[
            '$url2',
            'coverhttp://static.missevan.com/coversmini/$cover'
          ];
  }

  String clear(String s) => s == '' ? null : s;

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[];
  }
}
