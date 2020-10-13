import 'dart:convert';

import 'search_item.dart';
import '../global.dart';

class HistoryItemManager {
  static List<SearchItem> _historyItem;
  static List<SearchItem> get historyItem => _historyItem;
  static String get key => Global.historyItemKey;

  static String genChapterKey(int id) => "chapter$id";

  /// 根据类型和排序规则取出收藏
  static List<SearchItem> getHistoryItemByType(String name, int contentType) {
    if (contentType != null) {
      return _historyItem
          .where((element) =>
              element.ruleContentType == contentType && element.name.contains(name))
          .toList()
          .reversed
          .toList();
    } else {
      return _historyItem
          .where((element) => element.name.contains(name ?? ''))
          .toList()
          .reversed
          .toList();
    }
  }

  // static void sortReadTime() {
  //   _historyItem.sort((a, b) => b.lastReadTime.compareTo(a.lastReadTime));
  // }

  static Future<bool> insertOrUpdateHistoryItem(SearchItem searchItem) async {
    for (final item in _historyItem) {
      if (item.originTag == searchItem.originTag && item.url == searchItem.url) {
        _historyItem.remove(item);
        break;
      }
    }
    _historyItem.add(searchItem);
    return saveHistoryItem();
  }

  static void initHistoryItem() {
    _historyItem = <SearchItem>[];
    Global.prefs
        .getStringList(key)
        ?.forEach((item) => _historyItem.add(SearchItem.fromJson(jsonDecode(item))));
  }

  static Future<bool> removeSearchItem(int id) async {
    _historyItem.removeWhere((item) => item.id == id);
    return saveHistoryItem();
  }

  static Future<bool> saveHistoryItem() async {
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
    saveHistoryItem();
    return true;
  }
}
