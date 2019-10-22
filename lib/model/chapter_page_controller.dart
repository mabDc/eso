import 'package:flutter/material.dart';

class ChapterPageController with ChangeNotifier{

  int _durChapterIndex;
  int get durChapterIndex => _durChapterIndex;
  ChapterListStyle _listStyle;
  ChapterListStyle get listStyle => _listStyle;

  static const BigList = ChapterListStyle.BigList;
  static const SmallList = ChapterListStyle.SmallList;
  static const Grid = ChapterListStyle.Grid;

  String getListStyleName([ChapterListStyle listStyle]){
    if(listStyle == null){
      listStyle = _listStyle;
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

  ChapterPageController({int durChapterIndex, ChapterListStyle chapterListStyle}){
    _durChapterIndex = durChapterIndex ?? 0;
    _listStyle = chapterListStyle ?? ChapterListStyle.values.first;
  }

  void changeChapter(int index){
    if(_durChapterIndex != index){
      _durChapterIndex = index;
      notifyListeners();
    }
  }

  void changeListStyle(ChapterListStyle listStyle){
    if(_listStyle != listStyle){
      _listStyle = listStyle;
      notifyListeners();
    }
  }

}

enum ChapterListStyle{
  BigList, SmallList, Grid
}