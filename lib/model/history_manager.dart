import '../global.dart';

class HistoryManager {
  HistoryManager() {
    _searchHistory = Global.prefs.getStringList(Global.searchHistoryKey) ?? <String>[];
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
    return false;
  }

  Future<bool> restore(List searchHistory, bool clean) async {
    if (clean) {
      _searchHistory.clear();
      _searchHistory.addAll(searchHistory.map((e) => '$e'));
      return await _saveSearchHistory();
    }
    _searchHistory.clear();
    _searchHistory.addAll(searchHistory.map((e) => '$e').where((e) => !_searchHistory.contains(e)));
    return await _saveSearchHistory();
  }

  Future<bool> clearHistory() async {
    _searchHistory.clear();
    return await _saveSearchHistory();
  }

  Future<bool> _saveSearchHistory() async {
    return await Global.prefs.setStringList(Global.searchHistoryKey, _searchHistory);
  }
}
