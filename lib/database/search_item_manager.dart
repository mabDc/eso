import 'dart:convert';

import 'package:eso/api/api_manager.dart';
import 'package:eso/utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'chapter_item.dart';
import 'search_item.dart';
import '../global.dart';

class SearchItemManager {
  static List<SearchItem> _searchItem;
  static List<SearchItem> get searchItem => _searchItem;
  static String get key => Global.searchItemKey;

  // static String genChapterKey(int id) => "chapter$id";

  /// 根据类型和排序规则取出收藏
  static List<SearchItem> getSearchItemByType(int contentType, SortType sortType,
      [String tag]) {
    if (tag == "全部") {
      tag = null;
    }
    final searchItem = <SearchItem>[];
    _searchItem.forEach((element) {
      if (element.ruleContentType == contentType &&
          (tag == null || tag.isEmpty || element.tags.contains(tag)))
        searchItem.add(element);
    });
    //排序
    sortType = SortType.CREATE;
    switch (sortType) {
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

  static bool isFavorite(String originTag, String url) {
    return _searchItem.any((item) => item.originTag == originTag && item.url == url);
  }

  static Future<bool> toggleFavorite(SearchItem searchItem) {
    if (isFavorite(searchItem.originTag, searchItem.url)) {
      return removeSearchItem(searchItem.id);
    } else {
      //添加时间信息
      searchItem.createTime = DateTime.now().microsecondsSinceEpoch;
      searchItem.updateTime = DateTime.now().microsecondsSinceEpoch;
      searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
      return addSearchItem(searchItem);
    }
  }

  static Future<bool> addSearchItem(SearchItem searchItem) async {
    _searchItem.removeWhere((element) => element.id == searchItem.id);
    _searchItem.add(searchItem);
    final sbox = Hive.box<SearchItem>(key);
    sbox.put(searchItem.id.toString(), searchItem);
    return true;
  }

  // static List<ChapterItem> getChapter(int id) {
  //   final sbox = Hive.box<SearchItem>(key);
  //   return sbox.get(id.toString()).chapters;
  // }

  static void initSearchItem() {
    // _searchItem = <SearchItem>[];
    final sbox = Hive.box<SearchItem>(key);
    _searchItem = sbox.values.toList();
  }

  static Future<bool> removeSearchItem(int id) async {
    final sbox = Hive.box<SearchItem>(key);
    sbox.delete(id.toString());
    _searchItem = sbox.values.toList();
    return true;
  }

  // static Future<bool> saveSearchItem() async {
  //   final sbox = Hive.box<SearchItem>(key);
  //   sbox.
  //   return true;
  //   return await Global.prefs.setStringList(
  //       key, _searchItem.map((item) => jsonEncode(item.toJson())).toList());
  // }

  // static Future<bool> removeChapter(int id) {
  //   return Global.prefs.remove(genChapterKey(id));
  // }

  // static Future<bool> saveChapter(int id, List<ChapterItem> chapters) async {
  //   return await Global.prefs.setStringList(
  //       genChapterKey(id), chapters.map((item) => jsonEncode(item.toJson())).toList());
  // }

  static String backupItems() {
    if (_searchItem == null || _searchItem.isEmpty) initSearchItem();
    return json.encode(_searchItem.map((item) {
      Map<String, dynamic> json = item.toJson();
      json["chapters"] =
          item.chapters.map((chapter) => jsonEncode(chapter.toJson())).toList();
      return json;
    }).toList());
  }

  static Future<bool> restore(String data) async {
    final sbox = Hive.box<SearchItem>(key);
    sbox.clear();
    jsonDecode(data).forEach((item) {
      SearchItem searchItem = SearchItem.fromJson(item);
      if (!isFavorite(searchItem.originTag, searchItem.url)) {
        searchItem.chapters = (jsonDecode('${item["chapters"]}') as List)
            .map((chapter) => ChapterItem.fromJson(chapter))
            .toList();
        // if(searchItem.chapters == null) searchItem.chapters = <ChapterItem>[];
        _searchItem.add(searchItem);
        sbox.put(searchItem.id.toString(), searchItem);
      }
    });
    return true;
  }

  static Future<void> refreshAll() async {
    // 先用单并发，加延时5s判定
    for (var item in _searchItem) {
      var current = item.name;
      await Future.any([
        refreshItem(item),
        (SearchItem temp) async {
          await Future.delayed(Duration(seconds: 5), () {
            if (current == temp.name) Utils.toast("${temp.name} 章节更新超时");
          });
        }(item),
      ]);
      current = null;
    }
    return;
  }

  static Future<void> refreshItem(SearchItem item) async {
    // if (item.chapters.isEmpty) {
    //   item.chapters = SearchItemManager.getChapter(item.id);
    // }
    List<ChapterItem> chapters;
    try {
      chapters = await APIManager.getChapter(item.originTag, item.url);
    } catch (e) {
      Utils.toast("${item.name} 章节获取失败");
      return;
    }
    if (chapters.isEmpty) {
      Utils.toast("${item.name} 章节为空");
      return;
    }
    final newCount = chapters.length - item.chapters.length;
    if (newCount > 0) {
      Utils.toast("${item.name} 新增 $newCount 章节");
      item.chapters = chapters;
      item.chapter = chapters.last?.name;
      item.chaptersCount = chapters.length;
      await item.save();
      // await SearchItemManager.saveChapter(item.id, item.chapters);
    } else {
      Utils.toast("${item.name} 无新增章节");
    }
    return;
  }
}

enum SortType { UPDATE, CREATE, LASTREAD }
