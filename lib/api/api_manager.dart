import 'package:eso/api/bupt_ivi.dart';
import 'package:eso/api/huya.dart';
import 'package:eso/api/qula.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';
import 'audio_5sing.dart';
import 'bainian.dart';
import 'bilibili.dart';
import 'bilibili_manga.dart';
import 'buka.dart';
import 'clicli.dart';
import 'dongman.dart';
import 'duitang.dart';
import 'duyidu.dart';
import 'gank.dart';
import 'huanyue.dart';
import 'huba.dart';
import 'iqiwx.dart';
import 'ixs.dart';
import 'manhuadui.dart';
import 'manhualou.dart';
import 'manhuatai.dart';
import 'mankezhan.dart';
import 'migu_manga.dart';
import 'missevan.dart';
import 'music163.dart';
import 'news163.dart';
import 'qidian.dart';
import 'tencent_manga.dart';
import 'tohomh.dart';
import 'u17.dart';
import 'yinghuaw.dart';
import 'ymoxuan.dart';
import 'zzzfun.dart';

class APIManager {
  static List<API> get allAPI => <API>[
        BuptIvi(),
        Huya(),
        News163(),
        Gank(),
        Duitang(),
        Qula(),
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
        // Manhuadui(),
        TencentManga(),
        BilibiliManga(),
        MiguManga(),
        Bainian(),
        // Huba(),
        ZZZFun(),
        Clicli(),
        Yinghuaw(),
        Bilibili(),
        Audio5sing(),
        Music163(),
        Missevan(),
      ];

  static API chooseAPI(String originTag) {
    for (API api in allAPI) {
      if (api.originTag == originTag) {
        return api;
      }
    }
    throw ('can not get api when chooseAPI');
  }

  static Future<List<SearchItem>> discover(
      String originTag, Map<String, DiscoverPair> params,
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
