import 'package:eso/api/api_from_rule.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'api.dart';

class APIManager {
  static Future<APIFromRUle> chooseAPI(String originTag) async {
    return APIFromRUle(await Global.ruleDao.findRuleById(originTag));
  }

  static Future<List<SearchItem>> discover(
      String originTag, Map<String, DiscoverPair> params,
      [int page = 1, int pageSize = 20]) async {
    if (originTag != null) {
      final api = await chooseAPI(originTag);
      if (api != null) return api.discover(params, page, pageSize);
    }
    return <SearchItem>[];
  }

  static Future<List<SearchItem>> search(String originTag, String query,
      [int page = 1, int pageSize = 20]) async {
    if (originTag != null) {
      final api = await chooseAPI(originTag);
      if (api != null) return api.search('$query'.trim(), page, pageSize);
    }
    return <SearchItem>[];
  }

  static Future<List<ChapterItem>> getChapter(String originTag, String url, [int page]) async {
    if (originTag != null) {
      final api = await chooseAPI(originTag);
      if (api != null) return api.chapter(url, page);
    }
    return <ChapterItem>[];
  }

  static Future<List<String>> getContent(String originTag, String url) async {
    if (originTag != null) {
      final api = await chooseAPI(originTag);
      if (api != null) return api.content(url);
    }
    return <String>[];
  }
}
