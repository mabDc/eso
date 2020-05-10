import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';

class Duitang implements API {
  @override
  String get origin => '堆糖';

  @override
  String get originTag => 'Duitang';

  @override
  int get ruleContentType => API.MANGA;

  int get timeSpan => DateTime.now().millisecondsSinceEpoch;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    return (json["data"]["object_list"] as List).map((item) {
      final covers = item["covers"];
      return SearchItem(
        tags: <String>[],
        api: this,
        cover: covers == null ? null : '${covers[0]}',
        name: '${item["name"]}',
        author: '${item["user"]["username"]}',
        chapter: '',
        description: '${item["date_str"]}\n${item["desc"]}',
        url:
            'https://www.duitang.com/napi/blog/list/by_album/?album_id=${item["id"]}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return commonParse(
        'https://www.duitang.com/napi/album/list/by_search/?include_fields=is_root%2Csource_link%2Citem%2Cbuyable%2Croot_id%2Cstatus%2Clike_count%2Csender%2Calbum%2Ccover&kw=梦&limit=$pageSize&type=album&_type=&start=${pageSize * (page - 1)}&_=$timeSpan');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        'https://www.duitang.com/napi/album/list/by_search/?include_fields=is_root%2Csource_link%2Citem%2Cbuyable%2Croot_id%2Cstatus%2Clike_count%2Csender%2Calbum%2Ccover&kw=$query&limit=$pageSize&type=album&_type=&start=${pageSize * (page - 1)}&_=$timeSpan');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    final limit = 10;
    final total = ((json["data"]["total"] as int) / limit).ceil();
    return List.generate(
        total,
        (index) => ChapterItem(
              cover: null,
              name: '${1 + index}',
              time: null,
              url:
                  '$url&limit=$limit&include_fields=top_comments%2Cis_root%2Csource_link%2Cbuyable%2Croot_id%2Cstatus%2Clike_count%2Clike_id%2Csender%2Creply_count&start=${limit * index}&_=$timeSpan',
            ));
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    return (json["data"]["object_list"] as List)
        .map((list) => '${list["photo"]["path"]}')
        .toList();
  }

  String clear(String s) => s == '' ? null : s;

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[];
  }
}
