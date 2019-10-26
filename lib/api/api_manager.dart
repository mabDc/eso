import 'package:eso/api/buka.dart';
import 'package:eso/api/ymoxuan.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'dongman.dart';
import 'tohomh.dart';
import 'api.dart';
import 'mankezhan.dart';
import 'qidian.dart';
import 'iqiwx.dart';
import 'manhualou.dart';
import 'manhuatai.dart';
import 'tencent_manga.dart';
import 'u17.dart';

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
    Ymoxuan(),
        Dongman(),
        Mankezhan(),
        Manhuatai(),
        Manhualou(),
        Tohomh(),
    Buka(),
        U17(),
        TencentManga(),

      ];

  static Future<List<SearchItem>> discover(String originTag, String query,
      [int page = 1, int pageSize = 20]) {
    return chooseAPI(originTag).discover(query, page, pageSize);
  }

  static Future<List<SearchItem>> search(String originTag, String query,
      [int page = 1, int pageSize = 20]) {
    return chooseAPI(originTag).search('$query'.trim(), page, pageSize);
  }

  static Future<List<ChapterItem>> getChapter(String originTag, String url) {
    return chooseAPI(originTag).chapter(url);
  }

  static Future<List<String>> getContent(String originTag, String url) {
    return chooseAPI(originTag).content(url);
  }
}
