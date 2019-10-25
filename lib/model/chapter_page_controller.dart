import '../api/api_manager.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import 'package:flutter/material.dart';

class ChapterPageController with ChangeNotifier {
  final SearchItem searchItem;
  ScrollController _controller;
  ScrollController get controller => _controller;

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
    if (searchItem.chapters == null) {
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
    searchItem.chapters =
        await APIManager.getChapter(searchItem.originTag, searchItem.url);
    searchItem.chaptersCount = searchItem.chapters.length;
    if (SearchItemManager.isFavorite(searchItem.url)) {
      await SearchItemManager.saveChapter(searchItem.id, searchItem.chapters);
    }
    notifyListeners();
    return;
  }

  void toggleFavorite() async {
    await SearchItemManager.toggleFavorite(searchItem);
    notifyListeners();
  }

  void scrollerToTop(){
    _controller.jumpTo(1);
  }

  void scrollerToBottom(){
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  void switchReverseChapter() async {
    searchItem.reverseChapter = !searchItem.reverseChapter;
    await SearchItemManager.saveSearchItem();
    notifyListeners();
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
