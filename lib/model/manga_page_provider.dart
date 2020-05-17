import 'dart:async';
import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intl/intl.dart' as intl;
import '../database/search_item.dart';
import 'package:flutter/material.dart';

class MangaPageProvider with ChangeNotifier {
  final _format = intl.DateFormat('HH:mm:ss');
  Timer _timer;
  final SearchItem searchItem;
  List<String> _content;
  List<String> get content => _content;
  ScrollController _controller;
  ScrollController get controller => _controller;
  bool _isLoading;
  bool get isLoading => _isLoading;
  Map<String, String> _headers;
  Map<String, String> get headers => _headers;
  String _bottomTime;
  String get bottomTime => _bottomTime;
  bool _showChapter;
  bool get showChapter => _showChapter;
  set showChapter(bool value) {
    if (_showChapter != value) {
      _showChapter = value;
      notifyListeners();
    }
  }

  bool _showMenu;
  bool get showMenu => _showMenu;
  set showMenu(bool value) {
    if (_showMenu != value) {
      _showMenu = value;
      notifyListeners();
    }
  }

  bool _showSetting;
  bool get showSetting => _showSetting;
  set showSetting(bool value) {
    if (_showSetting != value) {
      _showSetting = value;
      notifyListeners();
    }
  }

  MangaPageProvider({this.searchItem}) {
    _bottomTime = _format.format(DateTime.now());
    _isLoading = false;
    _showChapter = false;
    _showMenu = false;
    _showSetting = false;
    _headers = Map<String, String>();
    _controller = ScrollController();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        loadChapter(searchItem.durChapterIndex + 1);
      }
    });
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _initContent();
  }

  void refreshProgress() {
    searchItem.durContentIndex = _controller.position.pixels.floor();
    notifyListeners();
  }

  void _setHeaders() {
    final first = _content[0].split('@headers');
    if (first.length > 1) {
      _content[0] = first[0];
      _headers = (jsonDecode(first[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
    }
  }

  void _initContent() async {
    _content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
    _setHeaders();
    notifyListeners();
  }

  void share() async {
    await FlutterShare.share(
      title: '亦搜 eso',
      text:
          '${searchItem.name.trim()}\n${searchItem.author.trim()}\n\n${searchItem.description.trim()}\n\n${searchItem.url}',
      //linkUrl: '${searchItem.url}',
      chooserTitle: '选择分享的应用',
    );
  }

  DateTime _loadTime;
  void loadChapteDebounce(int chapterIndex) {
    _loadTime = DateTime.now();
    Future.delayed(const Duration(milliseconds: 201), () {
      if (DateTime.now().difference(_loadTime).inMilliseconds > 200) {
        loadChapter(chapterIndex);
      }
    });
  }

  Future<void> loadChapter(int chapterIndex) async {
    _showChapter = false;
    if (isLoading ||
        chapterIndex == searchItem.durChapterIndex ||
        chapterIndex < 0 ||
        chapterIndex >= searchItem.chapters.length) return;
    _isLoading = true;
    _content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[chapterIndex].url);
    _setHeaders();
    searchItem.durChapterIndex = chapterIndex;
    searchItem.durChapter = searchItem.chapters[chapterIndex].name;
    searchItem.durContentIndex = 1;
    await SearchItemManager.saveSearchItem();
    _isLoading = false;
    if (searchItem.ruleContentType != API.RSS) {
      _controller.jumpTo(1);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    content.clear();
    _controller.dispose();
    SearchItemManager.saveSearchItem();
    super.dispose();
  }
}
