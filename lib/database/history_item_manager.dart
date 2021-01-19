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

  static Future<bool> removeSearchItem(Set<int> id) async {
    _historyItem.removeWhere((item) => id.contains(item.id));
    return saveHistoryItem();
  }

  static Future<bool> saveHistoryItem() async {
    return await Global.prefs.setStringList(
        key, _historyItem.map((item) => jsonEncode(item.toJson())).toList());
  }

  // static String backupItems() {
  //   if (_searchItem == null || _searchItem.isEmpty) initSearchItem();
  //   return json.encode(_searchItem.map((item) {
  //     Map<String, dynamic> json = item.toJson();
  //     json["chapters"] =
  //         getChapter(item.id).map((chapter) => jsonEncode(chapter.toJson())).toList();
  //     return json;
  //   }).toList());
  // }

  static Future<bool> restore(String data) async {
    final json = jsonDecode(data);
    if (json != null && json is List && json.isNotEmpty) {
      _historyItem.clear();
      json.forEach((item) => _historyItem.add(SearchItem.fromJson(jsonDecode(item))));
      saveHistoryItem();
      return true;
    }
    return false;
  }
}
