import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../global.dart';

class HistoryManager {
  static final _box = Hive.box<String>(Global.searchHistoryKey);

  static Set<String> get searchHistory => _box.values.toSet();

  static Future<bool> newSearch(String keyWord) async {
    if (!searchHistory.contains(keyWord)) {
      _box.add(keyWord);
      return true;
    }
    return false;
  }

  static Future<bool> remove(String keyWord) async {
    if (searchHistory.contains(keyWord)) {
      _box.toMap().forEach((key, value) {
        if (value == keyWord) _box.delete(key);
      });
      return true;
    }
    return false;
  }

  static clear() {
    _box.clear();
  }

  static Future<bool> restore(String history) async {
    if (history == null || history.isEmpty) return false;
    final searchHistory = (jsonDecode(history) as List)?.map((e) => '$e')?.toSet();
    if (searchHistory == null) return false;
    searchHistory.removeAll(_box.values);
    if (searchHistory.isNotEmpty) _box.addAll(searchHistory);
    return true;
  }

  static String backUpsearchHistory() {
    return jsonEncode(_box.values.toList());
  }
}
