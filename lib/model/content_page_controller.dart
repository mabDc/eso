import 'dart:convert';

import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item_manager.dart';

import '../database/search_item.dart';
import 'package:flutter/material.dart';

class ContentPageController with ChangeNotifier {
  final SearchItem searchItem;
  int _progress;
  int get progress => _progress;
  List<String> _content;

  List<String> get content => _content;
  ScrollController _controller;

  ScrollController get controller => _controller;
  bool _isLoading;

  bool get isLoading => _isLoading;
  Map<String, String> _headers;

  Map<String, String> get headers => _headers;

  ContentPageController({this.searchItem}) {
    _isLoading = false;
    _headers = Map<String, String>();
    _controller = ScrollController();
    _progress = 0;
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _loadNextChapterContent();
      }
    });
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    initContent();
  }

  void refreshProgress() {
    searchItem.durContentIndex = _controller.position.pixels.floor();
    _progress = searchItem.durContentIndex *100 ~/ _controller.position.maxScrollExtent;
    notifyListeners();
  }

  void _setHeaders() {
    final first = _content[0].split('@headers');
    if (first.length > 1) {
      _content[0] = first[0];
      _headers =
          (jsonDecode(first[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
    }
  }

  void initContent() async {
    _content = await APIManager.getContent(searchItem.originTag,
        searchItem.chapters[searchItem.durChapterIndex].url);
    _setHeaders();
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 10));
    _controller.jumpTo(searchItem.durContentIndex ==
            _controller.position.maxScrollExtent.floor()
        ? _controller.position.maxScrollExtent - 300
        : searchItem.durContentIndex.toDouble());
  }

  void _loadNextChapterContent() async {
    if (isLoading) return;
    if (searchItem.durChapterIndex < searchItem.chapters.length - 1) {
      _isLoading = true;
      notifyListeners();
      searchItem.durChapterIndex++;
      _content = await APIManager.getContent(searchItem.originTag,
          searchItem.chapters[searchItem.durChapterIndex].url);
      _setHeaders();
      searchItem.durChapter =
          searchItem.chapters[searchItem.durChapterIndex].name;
      searchItem.durContentIndex = 1;
      await SearchItemManager.saveSearchItem();
      _isLoading = false;
      _controller.jumpTo(1);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    content.clear();
    _controller.dispose();
    SearchItemManager.saveSearchItem();
    super.dispose();
  }
}
