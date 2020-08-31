import 'dart:math';

import 'package:eso/api/api_from_rule.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'api.dart';

class APIManager {
  static Future<API> chooseAPI(String originTag) async {
    return APIFromRUle(await Global.ruleDao.findRuleById(originTag));
  }

  static Future<List<SearchItem>> discover(
      String originTag, Map<String, DiscoverPair> params,
      [int page = 1, int pageSize = 20]) async {
    if (originTag != null) {
      final api = await chooseAPI(originTag);
      return <SearchItem>[
        for (var i = 0; i < pageSize; i++)
          SearchItem(
            name: "发现$i",
            api: api,
            author: "",
            chapter: "",
            cover: "",
            description: "",
            tags: [],
            url: "",
          ),
      ];
    }
    return <SearchItem>[];
  }

  static Future<List<SearchItem>> search(String originTag, String query,
      [int page = 1, int pageSize = 20]) async {
    if (originTag != null) {
      return <SearchItem>[
        for (var i = 0; i < pageSize; i++)
          SearchItem(
              name: "搜索$i",
              api: null,
              author: null,
              chapter: null,
              cover: null,
              description: null,
              tags: [],
              url: null),
      ];
    }
    return <SearchItem>[];
  }

  static Future<List<ChapterItem>> getChapter(String originTag, String url) async {
    if (originTag != null) {
      return <ChapterItem>[
        for (var i = 0; i < 100; i++) ChapterItem(name: "章节$i", url: null),
      ];
    }
    return <ChapterItem>[];
  }

  static Future<List<String>> getContent(String originTag, String url) async {
    if (originTag != null) {
      final api = await chooseAPI(originTag);
      switch (api.ruleContentType) {
        case API.NOVEL:
          return <String>[
            for (var i = 0; i < 100; i++) "正文$i" * Random().nextInt(10),
          ];
          break;
        case API.AUDIO:
          return <String>[
            for (var i = 0; i < 100; i++) "https://example.com/AUDIO$i",
          ];
          break;
        case API.MANGA:
          return <String>[
            for (var i = 0; i < 100; i++) "https://example.com/MANGA$i",
          ];
          break;
        case API.VIDEO:
          return <String>[
            for (var i = 0; i < 100; i++) "https://example.com/VIDEO$i",
          ];
          break;
        default:
      }
    }
    return <String>[];
  }
}
