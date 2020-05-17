import 'dart:convert';
import 'dart:io';

import 'chapter_item.dart';
import 'search_item.dart';
import '../global.dart';
import 'package:path_provider/path_provider.dart';

class SearchItemManager {
  static List<SearchItem> _searchItem;
  static List<SearchItem> get searchItem => _searchItem;
  static String get key => Global.searchItemKey;

  static String genChapterKey(int id) => "chapter$id";

  /// 根据类型和排序规则取出收藏
  static List<SearchItem> getSearchItemByType(int contentType,{sortType = SortType.CREATE}){
    List<SearchItem> searchItem = [];
    _searchItem.forEach((element) {
      if (element.ruleContentType == contentType) searchItem.add(element);
    });
    //排序
    switch(sortType){
      case SortType.CREATE:
        searchItem.sort((a, b) => b.createTime.compareTo(a.createTime));
        break;
      case SortType.UPDATE:
        searchItem.sort((a, b) => b.updateTime.compareTo(a.updateTime));
        break;
      case SortType.LASTREAD:
        searchItem.sort((a, b) => b.lastReadTime.compareTo(a.lastReadTime));
        break;
    }
    
    return searchItem;
  }

  static bool isFavorite(String url) {
    return _searchItem.any((item) => item.url == url);
  }

  static Future<bool> toggleFavorite(SearchItem searchItem) {
    if (isFavorite(searchItem.url)) {
      return removeSearchItem(searchItem.url, searchItem.id);
    } else {
      //添加时间信息
      searchItem.serCreateTime = DateTime.now();
      searchItem.serUpdateTime = DateTime.now();
      searchItem.serLastReadTime = DateTime.now();
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
    return Global.prefs.setStringList(genChapterKey(id),
        chapters.map((item) => jsonEncode(item.toJson())).toList());
  }

  static Future<bool> backupItems() async {
    Directory dir = await getExternalStorageDirectory();
    String s = json.encode(_searchItem.map((item) {
      Map<String, dynamic> json = item.toJson();
      json["chapters"] = getChapter(item.id)
          .map((chapter) => jsonEncode(chapter.toJson()))
          .toList();
      return json;
    }).toList());
    await File(dir.path + '/backup.txt').writeAsString(s);
    return true;
  }

  static Future<bool> restore() async {
    Directory dir = await getExternalStorageDirectory();
    File file = File(dir.path + '/backup.txt');
    if (file.existsSync()) {
      String jsonString = await file.readAsString();
      List json = jsonDecode(jsonString);
      json.forEach((item) {
        SearchItem searchItem = SearchItem.fromJson(item);
        if (!isFavorite(searchItem.url)) {
          List<ChapterItem> chapters =
              (jsonDecode('${item["chapters"]}') as List)
                  .map((chapter) => ChapterItem.fromJson(chapter))
                  .toList();
          saveChapter(searchItem.id, chapters);
          _searchItem.add(searchItem);
        }
      });
      saveSearchItem();
    }
    return true;
  }
}

 enum SortType{
   UPDATE,CREATE,LASTREAD
}
