import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item_manager.dart';

import '../database/search_item.dart';
import 'package:flutter/material.dart';

class ContentPageController with ChangeNotifier{
  final SearchItem searchItem;

  List<String> _content;
  List<String> get content => _content;
  ScrollController _controller;
  ScrollController get controller => _controller;
  bool _isLoading;
  bool get isLoading => _isLoading;

  ContentPageController({List<String> content, this.searchItem}){
    _isLoading = false;
    _content = content;
    _controller = ScrollController();
    _controller.addListener((){
      if (_controller.position.pixels ==
          _controller.position.maxScrollExtent) {
        _loadNextChapterContent();
      }
    });
    if(searchItem.chapters?.length == 0 && SearchItemManager.isFavorite(searchItem.url)){
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    if(content == null){
      initContent();
    }
  }

  void initContent() async{
    _content = await APIManager.getContent(searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
    notifyListeners();
  }

  void _loadNextChapterContent() async {
    if(isLoading) return;
    if(searchItem.durChapterIndex < searchItem.chapters.length - 1 ){
      _isLoading = true;
      notifyListeners();
      searchItem.durChapterIndex++;
      _content = await APIManager.getContent(searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
      searchItem.durChapter = searchItem.chapters[searchItem.durChapterIndex].name;
      searchItem.durContentIndex = 1;
      await SearchItemManager.saveSearchItem();
      _isLoading = false;
      _controller.jumpTo(0);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    content.clear();
    _controller.dispose();
    super.dispose();
  }
}