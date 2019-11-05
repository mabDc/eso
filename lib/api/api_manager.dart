import 'package:eso/api/audio_5sing.dart';
import 'package:eso/api/bainian.dart';
import 'package:eso/api/bilibili.dart';
import 'package:eso/api/migu_manga.dart';
import 'package:eso/api/yinghua.dart';
import 'package:eso/api/zzzfun.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';
import 'buka.dart';
import 'dongman.dart';
import 'duyidu.dart';
import 'huanyue.dart';
import 'iqiwx.dart';
import 'ixs.dart';
import 'manhualou.dart';
import 'manhuatai.dart';
import 'mankezhan.dart';
import 'qidian.dart';
import 'tencent_manga.dart';
import 'tohomh.dart';
import 'u17.dart';
import 'ymoxuan.dart';

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
        Ixs(),
        Duyidu(),
        Huanyue(),
        Dongman(),
        Mankezhan(),
        Manhuatai(),
        Manhualou(),
        Tohomh(),
        Buka(),
        U17(),
        TencentManga(),
        MiguManga(),
        Bainian(),
        ZZZFun(),
        Yinghua(),
        Bilibili(),
      ];

  static Future<List<SearchItem>> discover(String originTag, Map<String,DiscoverPair> params,
      [int page = 1, int pageSize = 20]) {
    return chooseAPI(originTag).discover(params, page, pageSize);
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
