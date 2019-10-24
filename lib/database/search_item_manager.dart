import 'dart:convert';

import 'chapter_item.dart';
import 'search_item.dart';
import '../global.dart';

class SearchItemManager {
  static List<SearchItem> _searchItem;
  static List<SearchItem> get searchItem => _searchItem;
  static String get key => Global.searchItemKey;

  static String genChapterKey(int id) => "chapter$id";

  static bool isFavorite(String url) {
    return _searchItem.any((item) => item.url == url);
  }

  static Future<bool> toggleFavorite(SearchItem searchItem) {
    if (isFavorite(searchItem.url)) {
      return removeSearchItem(searchItem.url, searchItem.id);
    } else {
      return addSearchItem(searchItem);
    }
  }

  static Future<bool> addSearchItem(SearchItem searchItem) async {
    _searchItem.add(searchItem);
    return await saveSearchItem() &&
        await saveChapter(searchItem.id, searchItem.chapters);
  }

  static List<ChapterItem> getChapter(int id) {
    return Global.prefs
        .getStringList(genChapterKey(id))
        .map((item) => ChapterItem.fromJson(jsonDecode(item)))
        .toList();
  }

  static void initSearchItem() {
    _searchItem = <SearchItem>[];
    Global.prefs.getStringList(key)?.forEach(
        (item) => _searchItem.add(SearchItem.fromJson(jsonDecode(item))));
  }

  static Future<bool> removeSearchItem(String url, int id) async {
    await Global.prefs.remove(genChapterKey(id));
    _searchItem.removeWhere((item) => item.url == url);
    return saveSearchItem();
  }

  static Future<bool> saveSearchItem() async {
    return Global.prefs.setStringList(
        key, _searchItem.map((item) => jsonEncode(item.toJson())).toList());
  }

  static Future<bool> removeChapter(int id) {
    return Global.prefs.remove(genChapterKey(id));
  }

  static Future<bool> saveChapter(int id, List<ChapterItem> chapters) async {
    return Global.prefs.setStringList(
        genChapterKey(id), chapters.map((item) => jsonEncode(item.toJson())).toList());
  }
}
