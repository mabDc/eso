import '../global.dart';

class HistoryManager {
  HistoryManager() {
    _searchHistory = LocalStorage.getStringList(Global.searchHistoryKey) ?? <String>[];
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

  Future<bool> clearHistory() async {
    _searchHistory.clear();
    return await _saveSearchHistory();
  }

  Future<bool> _saveSearchHistory() async {
    return await LocalStorage.set(Global.searchHistoryKey, _searchHistory);
  }
}
