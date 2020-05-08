import 'package:eso/api/api_form_rule.dart';
import 'package:eso/api/bupt_ivi.dart';
import 'package:eso/api/huya.dart';
import 'package:eso/api/onemanhua.dart';
import 'package:eso/api/qula.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/model/analyze_rule/analyze_rule.dart';
import 'package:eso/model/analyze_rule/analyze_url.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
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
        Onemanhua(),
        Mankezhan(),
        Manhuatai(),
        Manhualou(),
        Manhuadui(),
        Tohomh(),
        Buka(),
        U17(),
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

  static Future<API> chooseAPI(String originTag) async {
    for (API api in allAPI) {
      if (api.originTag == originTag) {
        return api;
      }
    }
    return APIFromRUle(await Global.ruleDao.findRuleById(originTag));
  }

  static Future<List<SearchItem>> discover(
      String originTag, Map<String, DiscoverPair> params,
      [int page = 1, int pageSize = 20, Rule rule]) async {
    if (originTag != null) {
      final api = await chooseAPI(originTag);
      if (api != null) return api.discover(params, page, pageSize);
    }
    return <SearchItem>[];
  }

  static Future<List<SearchItem>> search(String originTag, String query,
      [int page = 1, int pageSize = 20, Rule rule]) async {
    if (originTag != null) {
      final api = await chooseAPI(originTag);
      if (api != null) return api.search('$query'.trim(), page, pageSize);
    }
    return <SearchItem>[];
  }

  static Future<List<ChapterItem>> getChapter(String originTag, String url,
      [Rule rule]) async {
    if (originTag != null) {
      final api = await chooseAPI(originTag);
      if (api != null) return api.chapter(url);
    }
    return <ChapterItem>[];
  }

  static Future<List<String>> getContent(String originTag, String url,
      [Rule rule]) async {
    if (originTag != null) {
      final api = await chooseAPI(originTag);
      if (api != null) return api.content(url);
    }
    return <String>[];
  }
}
