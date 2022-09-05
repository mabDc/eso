import 'dart:convert';

import '../global.dart';

class HistoryManager {
  HistoryManager() {
    _searchHistory =
        Global.prefs.getStringList(Global.searchHistoryKey) ?? <String>[];
  }

  List<String> _searchHistory;
  List<String> get searchHistory => _searchHistory;

  Future<bool> updateSearchHistory() async {
    return await _saveSearchHistory();
  }

  Future<bool> newSearch(String keyWord) async {
    if (!_searchHistory.contains(keyWord)) {
      _searchHistory.add(keyWord);
      return await _saveSearchHistory();
    }
    _searchHistory.removeWhere((element) => element == keyWord);
    return newSearch(keyWord);
  }

  // Future<bool> restore(List searchHistory) async {
  //   _searchHistory.clear();
  //   _searchHistory.addAll(searchHistory.map((e) => '$e'));
  //   return await _saveSearchHistory();
  // }

  static Future<bool> restore(String history) async {
    if (history == null || history.isEmpty) return false;
    final searchHistory =
        (jsonDecode(history) as List)?.map((e) => '$e')?.toList();
    if (searchHistory == null) return false;
    return await Global.prefs
        .setStringList(Global.searchHistoryKey, searchHistory);
  }

  Future<bool> clearHistory() async {
    _searchHistory.clear();

    return await _saveSearchHistory();
  }

  Future<bool> _saveSearchHistory() async {
    return await Global.prefs
        .setStringList(Global.searchHistoryKey, _searchHistory);
  }
}
