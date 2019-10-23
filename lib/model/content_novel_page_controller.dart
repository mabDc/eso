import 'package:eso/api/api_manager.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'package:flutter/material.dart';

class ContentNovelPageController with ChangeNotifier{
  final SearchItem searchItem;
  final List<ChapterItem> chapters;

  List<String> _p;
  List<String> get p => _p;
  ScrollController _controller;
  ScrollController get controller => _controller;
  bool _isLoading;
  bool get isLoading => _isLoading;

  ContentNovelPageController({List<String> p, this.chapters, this.searchItem }){
    _isLoading = false;
    _p = p;
    _controller = ScrollController();
    _controller.addListener((){
      if (_controller.position.pixels ==
          _controller.position.maxScrollExtent) {
        _loadNextChapterContent();
      }
    });
  }

  void changeContentIndex(int index){
    if(index != searchItem.durContentIndex){
      searchItem.durContentIndex = index;
      notifyListeners();
    }
  }

  void _loadNextChapterContent() async {
    if(isLoading) return;
    if(searchItem.durChapterIndex < chapters.length - 1 ){
      _isLoading = true;
      notifyListeners();
      searchItem.durChapterIndex++;
      _p = await APIManager.getNovelContent(searchItem.originTag, chapters[searchItem.durChapterIndex].url);
      searchItem.durChapter = chapters[searchItem.durChapterIndex].name;
      searchItem.durContentIndex = 1;
      _controller.jumpTo(0);
      _isLoading = false;
      notifyListeners();
    }
  }

}