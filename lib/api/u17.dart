import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'api.dart';

class U17 implements API {
  @override
  String get origin => '有妖气';

  @override
  String get originTag => 'U17';

  @override
  RuleContentType get ruleContentType => RuleContentType.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(res.body);
    return (json["data"]["returnData"]["comics"] as List)
        .map((item) => SearchItem(
              api: this,
              cover: '${item["cover"]}',
              name: '${item["name"]}',
              author: '${item["author"]}',
              chapter: '',
              description:
                  '${item["description"] ?? (item["tags"] as List).join(" ")}',
              url: '${item["comicId"] ?? item["comic_id"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(
      String query, int page, int pageSize) async {
    return commonParse(
        'http://app.u17.com/v3/appV3_3/android/phone/list/conditionScreenlists?page=$page');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        'http://app.u17.com/v3/appV3_3/android/phone/search/searchResult?q=$query&page=$page');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final comicId = url;
    final res = await http.get(
        'http://app.u17.com/v3/appV3_3/android/phone/comic/detail_static_new?&comicid=$comicId');
    final json = jsonDecode(res.body);
    return (json["data"]["returnData"]["chapter_list"] as List).map((chapter) {
      final passTime = chapter["pass_time"];
      final time = DateTime.fromMillisecondsSinceEpoch(
          ((passTime is int) ? passTime : int.parse(passTime)) * 1000);
      final type = chapter["type"];
      return ChapterItem(
        cover: null,
        name: '${type == 2 ? "🔒" : type == 3 ? "🔓" : ""}${chapter["name"]}',
        time: '$time'.trim().substring(0, 16),
        url:
            'http://app.u17.com/v3/appV3_3/android/phone/comic/chapterNew?chapter_id=${chapter["chapter_id"]}',
      );
    }).toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(res.body);
    final data = json["data"]["returnData"];
    List<String> images = <String>[];
    (data["image_list"] as List)
        ?.forEach((image) => images.add(image["location"]));
    (data["free_image_list"] as List)
        ?.forEach((image) => images.add(image["location"]));
    return images;
  }
    @override
  Map<String, String> discoverMap() {
    return Map<String, String>();
  }
}
