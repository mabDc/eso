import 'package:eso/api/api_manager.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'package:flutter/material.dart';

class ContentPageController with ChangeNotifier{
  final SearchItem searchItem;
  final List<ChapterItem>  chapters;

  List<String> _content;
  List<String> get content => _content;
  ScrollController _controller;
  ScrollController get controller => _controller;
  bool _isLoading;
  bool get isLoading => _isLoading;

  ContentPageController({List<String> content, this.chapters, this.searchItem }){
    _isLoading = false;
    _content = content;
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
      _content = await APIManager.getContent(searchItem.originTag, chapters[searchItem.durChapterIndex].url);
      searchItem.durChapter = chapters[searchItem.durChapterIndex].name;
      searchItem.durContentIndex = 1;
      _controller.jumpTo(0);
      _isLoading = false;
      notifyListeners();
    }
  }

}