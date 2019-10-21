import 'package:flutter/material.dart';

class ChapterPageController with ChangeNotifier{

  int _durChapterIndex;
  int get durChapterIndex => _durChapterIndex;
  _ListStyle _listStyle;
  _ListStyle get listStyle => _listStyle;

  static const BigList = _ListStyle.BigList;
  static const SmallList = _ListStyle.SmallList;
  static const Grid = _ListStyle.Grid;

  String getListStyleName([_ListStyle listStyle]){
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

  ChapterPageController(){
    _durChapterIndex = 0;
    _listStyle = _ListStyle.values.first;
  }

  void changeChapter(int index){
    if(_durChapterIndex != index){
      _durChapterIndex = index;
      notifyListeners();
    }
  }

  void changeListStyle(_ListStyle listStyle){
    if(_listStyle != listStyle){
      _listStyle = listStyle;
      notifyListeners();
    }
  }
}

enum _ListStyle{
  BigList, SmallList, Grid
}