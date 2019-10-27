import 'package:flutter/material.dart';

import '../api/api_manager.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';

class ChapterPageController with ChangeNotifier {
  final SearchItem searchItem;
  ScrollController _controller;
  ScrollController get controller => _controller;
  bool get isLoading => _isLoading;
  bool _isLoading;

  static const BigList = ChapterListStyle.BigList;
  static const SmallList = ChapterListStyle.SmallList;
  static const Grid = ChapterListStyle.Grid;

  String getListStyleName([ChapterListStyle listStyle]) {
    if (listStyle == null) {
      listStyle = searchItem.chapterListStyle;
    }
    switch (listStyle) {
      case BigList:
        return "大列表";
      case SmallList:
        return "小列表";
      case Grid:
        return "宫格";
      default:
        return "宫格";
    }
  }

  ChapterPageController({@required this.searchItem}) {
    _controller = ScrollController();
    _isLoading = false;
    if (searchItem.chapters == null) {
      _isLoading = true;
      initChapters();
    } else if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
  }

  void initChapters() async {
    searchItem.chapters =
        await APIManager.getChapter(searchItem.originTag, searchItem.url);
    searchItem.durChapterIndex = 0;
    searchItem.durContentIndex = 1;
    searchItem.durChapter = searchItem.chapters.first?.name;
    searchItem.chaptersCount = searchItem.chapters.length;
    _isLoading = false;
    notifyListeners();
  }

  void changeChapter(int index) async {
    if (searchItem.durChapterIndex != index) {
      searchItem.durChapterIndex = index;
      searchItem.durChapter = searchItem.chapters[index].name;
      searchItem.durContentIndex = 1;
      await SearchItemManager.saveSearchItem();
      notifyListeners();
    }
  }

  Future<void> updateChapter() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    searchItem.chapters =
        await APIManager.getChapter(searchItem.originTag, searchItem.url);
    searchItem.chaptersCount = searchItem.chapters.length;
    if (SearchItemManager.isFavorite(searchItem.url)) {
      await SearchItemManager.saveChapter(searchItem.id, searchItem.chapters);
    }
    _isLoading = false;
    notifyListeners();
    return;
  }

  void toggleFavorite() async {
    if (_isLoading) return;
    await SearchItemManager.toggleFavorite(searchItem);
    notifyListeners();
  }

  void scrollerToTop() {
    searchItem.reverseChapter = false;
    notifyListeners();
    _controller.jumpTo(1);
  }

  void scrollerToBottom() {
    searchItem.reverseChapter = true;
    notifyListeners();
    _controller.jumpTo(1);
  }

  void changeListStyle(ChapterListStyle listStyle) async {
    if (searchItem.chapterListStyle != listStyle) {
      searchItem.chapterListStyle = listStyle;
      await SearchItemManager.saveSearchItem();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

enum ChapterListStyle {
  BigList,
  SmallList,
  Grid,
}
