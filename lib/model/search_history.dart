import 'package:flutter/material.dart';
import '../global.dart';

class SearchHistory with ChangeNotifier {
  SearchHistory() {
    _searchHistory =
        Global.prefs.getString(Global.searchHistoryKey) ?? <String>[];
  }

  List<String> _searchHistory;
  List<String> get searchHistory => _searchHistory;

  void updateSearchHistory() async {
    await _saveSearchHistory();
    notifyListeners();
  }

  Future<bool> _saveSearchHistory() =>
      Global.prefs.setStringList(Global.searchHistoryKey, _searchHistory);
}
