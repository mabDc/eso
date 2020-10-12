import 'dart:convert';

import 'search_item.dart';
import '../global.dart';

class HistoryItemManager {
  static List<SearchItem> _historyItem;
  static List<SearchItem> get historyItem => _historyItem;
  static String get key => Global.historyItemKey;

  static String genChapterKey(int id) => "chapter$id";

  /// 根据类型和排序规则取出收藏
  static List<SearchItem> getHistoryItemByType([int contentType]) {
    _historyItem.sort((a, b) => b.lastReadTime.compareTo(a.lastReadTime));
    if (contentType != null) {
      return _historyItem
          .where((element) => element.ruleContentType == contentType)
          .toList();
    } else {
      return _historyItem;
    }
  }

  static bool isHistory(String originTag, String url) {
    return _historyItem.any((item) => item.originTag == originTag && item.url == url);
  }

  static Future<bool> addHistoryItem(SearchItem searchItem) async {
    _historyItem.add(searchItem);
    return true;
  }

  static void initHistoryItem() {
    _historyItem = <SearchItem>[];
    Global.prefs
        .getStringList(key)
        ?.forEach((item) => _historyItem.add(SearchItem.fromJson(jsonDecode(item))));
  }

  static Future<bool> removeSearchItem(int id) async {
    _historyItem.removeWhere((item) => item.id == id);
    return saveSearchItem();
  }

  static Future<bool> saveSearchItem() async {
    return await Global.prefs.setStringList(
        key, _historyItem.map((item) => jsonEncode(item.toJson())).toList());
  }

  static Future<String> backupItems() async {
    if (_historyItem == null || _historyItem.isEmpty) initHistoryItem();
    return json.encode(_historyItem);
  }

  static Future<bool> restore(String data) async {
    List json = jsonDecode(data);
    json.forEach((item) => _historyItem.add(SearchItem.fromJson(item)));
    saveSearchItem();
    return true;
  }
}
