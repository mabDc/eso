import '../api/api_manager.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import 'package:flutter/material.dart';

class ChapterPageController with ChangeNotifier{
  final SearchItem searchItem;
  static const BigList = ChapterListStyle.BigList;
  static const SmallList = ChapterListStyle.SmallList;
  static const Grid = ChapterListStyle.Grid;

  String getListStyleName([ChapterListStyle listStyle]){
    if(listStyle == null){
      listStyle = searchItem.chapterListStyle;
    }
    switch(listStyle){
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

  ChapterPageController({@required this.searchItem}){
    if(searchItem.chapters.length == 0 && SearchItemManager.isFavorite(searchItem.url)){
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
  }

  void changeChapter(int index) async {
    if(searchItem.durChapterIndex != index){
      searchItem.durChapterIndex = index;
      searchItem.durChapter = searchItem.chapters[index].name;
      searchItem.durContentIndex = 1;
      await SearchItemManager.saveSearchItem();
      notifyListeners();
    }
  }

  Future<void> updateChapter() async {
    searchItem.chapters = await APIManager.getChapter(searchItem.originTag, searchItem.url);
    searchItem.chaptersCount = searchItem.chapters.length;
    if(SearchItemManager.isFavorite(searchItem.url)){
      await SearchItemManager.saveChapter(searchItem.id, searchItem.chapters);
    }
    notifyListeners();
    return;
  }

  void toggleFavorite() async {
    await SearchItemManager.toggleFavorite(searchItem);
    notifyListeners();
  }

  void changeListStyle(ChapterListStyle listStyle) async {
    if(searchItem.chapterListStyle != listStyle){
      searchItem.chapterListStyle = listStyle;
      await SearchItemManager.saveSearchItem();
      notifyListeners();
    }
  }
}

enum ChapterListStyle{
  BigList, SmallList, Grid
}