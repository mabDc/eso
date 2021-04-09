import 'dart:math';

import 'package:eso/api/api_from_rule.dart';
import 'package:eso/api/json_placeholder.dart';
import 'package:eso/api/json_placeholder_photo.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'api.dart';

class APIManager {
  static Map<String, API> get apiMap => {
        JSONPlaceHolder().originTag: JSONPlaceHolder(),
        JSONPlaceHolderPhoto().origin: JSONPlaceHolderPhoto(),
      };

  static Future<API> chooseAPI(String originTag) async {
    return apiMap[originTag] ?? APIFromRUle(await Global.ruleDao.findRuleById(originTag));
  }

  static Future<List<DiscoverMap>> discoverMap(String originTag) async {
    if (originTag != null) {
      final api = apiMap[originTag];
      if (api != null) return api.discoverMap();
      return <DiscoverMap>[
        for (var i = 0; i < 10; i++)
          DiscoverMap("tab$i", <DiscoverPair>[
            for (var j = 0; j < 3; j++) DiscoverPair("class$j", ""),
          ])
      ];
    }
    return <DiscoverMap>[];
  }

  static Future<List<SearchItem>> discover(String originTag, Map<String, DiscoverPair> params,
      [int page = 1, int pageSize = 20]) async {
    if (originTag != null) {
      var api = apiMap[originTag];
      if (api != null) return api.discover(params, page, pageSize);
      api = await chooseAPI(originTag);
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

  static Future<List<SearchItem>> search(String originTag, String query, [int page = 1, int pageSize = 20]) async {
    if (originTag != null) {
      var api = apiMap[originTag];
      if (api != null) return api.search(query, page, pageSize);
      api = await chooseAPI(originTag);
      return <SearchItem>[
        for (var i = 0; i < pageSize; i++)
          SearchItem(
            name: "搜索$i",
            api: api,
            author: null,
            chapter: null,
            cover: null,
            description: null,
            tags: [],
            url: null,
          ),
      ];
    }
    return <SearchItem>[];
  }

  static Future<List<ChapterItem>> getChapter(String originTag, String url) async {
    if (originTag != null) {
      var api = apiMap[originTag];
      if (api != null) return api.chapter(url);
      return <ChapterItem>[
        for (var i = 0; i < 100; i++) ChapterItem(name: "章节$i", url: "1"),
      ];
    }
    return <ChapterItem>[];
  }

  static Future<List<String>> getContent(String originTag, String url) async {
    if (originTag != null) {
      var api = apiMap[originTag];
      if (api != null) return api.content(url);
      api = await chooseAPI(originTag);
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
