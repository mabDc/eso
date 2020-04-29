import 'package:eso/api/bupt_ivi.dart';
import 'package:eso/api/huya.dart';
import 'package:eso/api/onemanhua.dart';
import 'package:eso/api/qula.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/model/analyze_rule/analyze_rule.dart';
import 'package:eso/model/analyze_rule/analyze_url.dart';

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

  static API chooseAPI(String originTag) {
    for (API api in allAPI) {
      if (api.originTag == originTag) {
        return api;
      }
    }
    return null;
  }

  static Future<List<SearchItem>> discover(
      String originTag, Map<String, DiscoverPair> params,
      [int page = 1, int pageSize = 20, Rule rule]) async {
    if (originTag != null) {
      final api = chooseAPI(originTag);
      if (api != null) return api.discover(params, page, pageSize);
    }
    // if (rule == null) throw ('rule cannot be null');
    final rule = Rule.newRule();
    final res = await AnalyzeUrl.urlRuleParser(
      rule.discoverUrl,
      host: rule.host,
      page: page,
      pageSize: pageSize,
    );
    final list = await AnalyzeRule(res.body, res.request.url.toString())
        .getElements(rule.discoverList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzeRule(item, res.request.url.toString());
      result.add(SearchItem(
        cover: await analyzer.getString(rule.discoverCover),
        name: await analyzer.getString(rule.discoverName),
        author: await analyzer.getString(rule.discoverAuthor),
        chapter: await analyzer.getString(rule.discoverChapter),
        description: await analyzer.getString(rule.discoverDescription),
        url: await analyzer.getString(rule.discoverResult),
        api: null,
        tags: await analyzer.getStringList(rule.discoverTags),
      ));
    }
    return result;
  }

  static Future<List<SearchItem>> search(String originTag, String query,
      [int page = 1, int pageSize = 20, Rule rule]) async {
    final api = chooseAPI(originTag);
    if (api != null) return api.search('$query'.trim(), page, pageSize);
    // if (rule == null) throw ('rule cannot be null');
    final rule = Rule.newRule();
    final res = await AnalyzeUrl.urlRuleParser(
      rule.searchUrl,
      host: rule.host,
      page: page,
      pageSize: pageSize,
    );
    final list = await AnalyzeRule(res.body, res.request.url.toString())
        .getElements(rule.discoverList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzeRule(item, res.request.url.toString());
      result.add(SearchItem(
        cover: await analyzer.getString(rule.searchCover),
        name: await analyzer.getString(rule.searchName),
        author: await analyzer.getString(rule.searchAuthor),
        chapter: await analyzer.getString(rule.searchChapter),
        description: await analyzer.getString(rule.searchDescription),
        url: await analyzer.getString(rule.searchResult),
        api: null,
        tags: await analyzer.getStringList(rule.searchTags),
      ));
    }
    return result;
  }

  static Future<List<ChapterItem>> getChapter(String originTag, String url,
      [Rule rule]) async {
    final api = chooseAPI(originTag);
    if (api != null) return api.chapter(url);
    if (rule == null) throw ('rule cannot be null');
  }

  static Future<List<String>> getContent(String originTag, String url,
      [Rule rule]) {
    final api = chooseAPI(originTag);
    if (api != null) return api.content(url);
    if (rule == null) throw ('rule cannot be null');
  }
}
