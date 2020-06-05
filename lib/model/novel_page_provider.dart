import 'dart:io';

import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:screen/screen.dart';
import '../database/search_item.dart';
import 'package:flutter/material.dart';

class NovelPageProvider with ChangeNotifier {
  final SearchItem searchItem;
  int _progress;
  int get progress => _progress;
  List<String> _paragraphs;
  List<String> get paragraphs => _paragraphs;
  ScrollController _controller;
  ScrollController get controller => _controller;
  bool _isLoading;
  bool get isLoading => _isLoading;

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

  bool _showChapter;
  bool get showChapter => _showChapter;
  set showChapter(bool value) {
    if (_showChapter != value) {
      _showChapter = value;
      notifyListeners();
    }
  }

  bool _useSelectableText;
  bool get useSelectableText => _useSelectableText;
  set useSelectableText(bool value) {
    if (value != _useSelectableText) {
      _useSelectableText = value;
      notifyListeners();
    }
  }

  double _sysBrightness;
  double _brightness;
  double get brightness => _brightness;
  set brightness(double value) {
    if ((value - _brightness).abs() > 0.005) {
      _brightness = value;
      Screen.setBrightness(brightness);
    }
  }

  bool keepOn;
  void setKeepOn(bool value) {
    if (value != keepOn) {
      keepOn = value;
      Screen.keepOn(keepOn);
    }
  }

  NovelPageProvider({this.searchItem, this.keepOn}) {
    _brightness = 0.5;
    _isLoading = false;
    _showChapter = false;
    _showMenu = false;
    _showSetting = false;
    _useSelectableText = false;
    _controller =
        ScrollController(initialScrollOffset: searchItem.durContentIndex.toDouble());
    _progress = 0;
//    _controller.addListener(() {
//      if (progress > 0 &&
//          _controller.position.pixels == _controller.position.maxScrollExtent) {
//        loadChapter(searchItem.durChapterIndex + 1);
//      }
//    });
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _initContent();
  }

  void refreshProgress() {
    searchItem.durContentIndex = _controller.position.pixels.floor();
    _progress = searchItem.durContentIndex * 100 ~/ _controller.position.maxScrollExtent;
    notifyListeners();
  }

  void _initContent() async {
    if (Platform.isAndroid || Platform.isIOS) {
      _brightness = await Screen.brightness;
      if (_brightness > 1) {
        _brightness = 0.5;
      }
      _sysBrightness = _brightness;
      if (keepOn) {
        Screen.keepOn(keepOn);
      }
    }
    final content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
    _paragraphs = content
        .join("\n")
        .split(RegExp(r"\n\s*"))
        .map((s) => "　　" + s.trimLeft())
        .toList();
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

  bool _hideLoading = false;

  Future<void> loadChapterHideLoading(bool lastChapter) async {
    _showChapter = false;
    if (isLoading || _hideLoading) return;
    final loadIndex =
        lastChapter ? searchItem.durChapterIndex - 1 : searchItem.durChapterIndex + 1;
    if (loadIndex < 0 || loadIndex >= searchItem.chapters.length) return;
    _hideLoading = true;
    searchItem.durChapterIndex = loadIndex;
    final content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[loadIndex].url);
    _paragraphs = content
        .join("\n")
        .split(RegExp(r"\n\s*"))
        .map((s) => "　　" + s.trimLeft())
        .toList();
    searchItem.durChapter = searchItem.chapters[loadIndex].name;
    searchItem.durContentIndex = 1;
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    await SearchItemManager.saveSearchItem();
    _hideLoading = false;
    _controller.jumpTo(1);
    notifyListeners();
  }

  Future<void> loadChapter(int chapterIndex) async {
    _showChapter = false;
    if (isLoading ||
        chapterIndex == searchItem.durChapterIndex ||
        chapterIndex < 0 ||
        chapterIndex >= searchItem.chapters.length) return;
    _isLoading = true;
    searchItem.durChapterIndex = chapterIndex;
    notifyListeners();
    final content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[chapterIndex].url);
    _paragraphs = content
        .join("\n")
        .split(RegExp(r"\n\s*"))
        .map((s) => "　　" + s.trimLeft())
        .toList();
    searchItem.durChapter = searchItem.chapters[chapterIndex].name;
    searchItem.durContentIndex = 1;
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    await SearchItemManager.saveSearchItem();
    _isLoading = false;
    _controller.jumpTo(1);
    notifyListeners();
  }

  void refreshCurrent() async {
    if (isLoading) return;
    _isLoading = true;
    _showChapter = false;
    notifyListeners();
    final content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
    _paragraphs = content
        .join("\n")
        .split(RegExp(r"\n\s*"))
        .map((s) => "　　" + s.trimLeft())
        .toList();
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addToFavorite() async {
    if (SearchItemManager.isFavorite(searchItem.url)) {
      return null;
    }
    return SearchItemManager.addSearchItem(searchItem);
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      if (Platform.isAndroid) {
        Screen.setBrightness(-1.0);
      } else {
        Screen.setBrightness(_sysBrightness);
      }
      Screen.keepOn(false);
    }
    _paragraphs.clear();
    _controller.dispose();
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    SearchItemManager.saveSearchItem();
    super.dispose();
  }
}
