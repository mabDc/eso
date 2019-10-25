import 'package:eso/api/iqiwx.dart';
import 'package:eso/api/manhualou.dart';
import 'package:eso/api/tencent_manga.dart';
import 'package:eso/api/u17.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'dongman.dart';
import 'tohomh.dart';
import 'api.dart';
import 'mankezhan.dart';
import 'qidian.dart';

class APIManager {
  static API chooseAPI(String originTag) {
    for (API api in allAPI) {
      if (api.originTag == originTag) {
        return api;
      }
    }
    throw ('can not get api when chooseAPI');
  }

  static List<API> get allAPI => <API>[
        Qidian(),
        Iqiwx(),
        Tohomh(),
        Mankezhan(),
    Dongman(),
    Manhualou(),
    U17(),
    TencentManga(),
      ];

  static Future<List<SearchItem>> discover(String originTag, String query,
      [int page = 1, int pageSize = 20]) {
    return chooseAPI(originTag).discover(query, page, pageSize);
  }

  static Future<List<SearchItem>> search(String originTag, String query,
      [int page = 1, int pageSize = 20]) {
    return chooseAPI(originTag).search(query, page, pageSize);
  }

  static Future<List<ChapterItem>> getChapter(String originTag, String url) {
    return chooseAPI(originTag).chapter(url);
  }

  static Future<List<String>> getContent(String originTag, String url) {
    return chooseAPI(originTag).content(url);
  }
}
