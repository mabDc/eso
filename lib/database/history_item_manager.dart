import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import 'search_item.dart';
import '../global.dart';

class HistoryItemManager {
  static List<SearchItem> get historyItem => _box.values.toList();
  static String get key => Global.historyItemKey;
  static final _box = Hive.box<SearchItem>(Global.historyItemKey);

  /// 根据类型和排序规则取出收藏
  static List<SearchItem> getHistoryItemByType(String name, int contentType) {
    if (contentType != null) {
      return historyItem
          .where((element) =>
              element.ruleContentType == contentType && element.name.contains(name ?? ''))
          .toList()
        ..sort(((a, b) => b.lastReadTime - a.lastReadTime));
    } else {
      return historyItem.where((element) => element.name.contains(name ?? '')).toList()
        ..sort(((a, b) => b.lastReadTime - a.lastReadTime));
    }
  }

  static Future<bool> insertOrUpdateHistoryItem(SearchItem searchItem) async {
    await _box.put(searchItem.id.toString(), SearchItem.fromJson(searchItem.toJson()));
    return true;
  }

  static Future<bool> removeSearchItem(Set<int> id) async {
    await _box.deleteAll(id.map((e) => e.toString()));
    return true;
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

  static String backupItems() {
    return jsonEncode(_box.toMap());
  }

  static Future<bool> restore(String data) async {
    final json = jsonDecode(data);
    if (json != null && json is List && json.isNotEmpty) {
      json.forEach((item) {
        final si = SearchItem.fromJson(item);
        _box.put(si.id.toString(), si);
      });
      return true;
    }
    return false;
  }
}
