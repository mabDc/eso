import 'package:eso/api/mankezhan.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:flutter/material.dart';

class ContentPageController with ChangeNotifier{
  List<String> _urls;
  List<String> get urls => _urls;
  List<ChapterItem> _chapters;
  List<ChapterItem> get chapters => _chapters;
  SearchItem _searchItem;
  SearchItem get searchItem => _searchItem;
  ScrollController _controller;
  ScrollController get controller => _controller;
  bool isLoading;

  ContentPageController({List<String> urls,List<ChapterItem> chapters, SearchItem searchItem }){
    isLoading = false;
    _controller = ScrollController();
    _controller.addListener((){
      if (_controller.position.pixels ==
          _controller.position.maxScrollExtent) {
        _loadNextChapterContent();
      }
    });
    _urls = urls;
    _chapters = chapters;
    _searchItem = searchItem;
  }

  void changeContentIndex(int index){
    if(index != _searchItem.durContentIndex){
      _searchItem.durContentIndex = index;
      notifyListeners();
    }
  }

  void _loadNextChapterContent() async {
    if(isLoading) return;
    isLoading = true;
    notifyListeners();
    _searchItem.durChapterIndex++;
    if(_searchItem.durChapterIndex >= _chapters.length){
      _searchItem.durChapterIndex--;
      return;
    }
    _urls = await Mankezhan.content(_chapters[_searchItem.durChapterIndex].url);
    _searchItem.durChapter = _chapters[_searchItem.durChapterIndex].name;
    _searchItem.durContentIndex = 1;
    _controller.jumpTo(0);
    isLoading = false;
    notifyListeners();
  }

}