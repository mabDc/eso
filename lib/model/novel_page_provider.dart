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
  List<String> _content;
  List<String> get content => _content;
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
    if ((value - _brightness).abs() > 0.05) {
      _brightness = value;
      Screen.setBrightness(brightness);
    }
  }

  bool _keepOn;
  bool get keepOn => _keepOn;
  set keepOn(bool value) {
    if (value != _keepOn) {
      _keepOn = value;
      Screen.keepOn(_keepOn);
      notifyListeners();
    }
  }

  // bgColor , fontColor
  final colorList = [
    [0xfff1f1f1, 0xff373534], //白底
    [0xfff5ede2, 0xff373328], //浅黄
    [0xff999c99, 0xff353535], //浅灰
    [0xff33383d, 0xffc5c4c9], //黑
    [0xffe3f8e1, 0xff485249]
  ];

  NovelPageProvider({this.searchItem}) {
    _brightness = 0.5;
    _keepOn = false;
    _isLoading = false;
    _showChapter = false;
    _showMenu = false;
    _showSetting = false;
    _useSelectableText = false;
    _controller =
        ScrollController(initialScrollOffset: searchItem.durContentIndex.toDouble());
    _progress = 0;
    _controller.addListener(() {
      if (progress > 0 &&
          _controller.position.pixels == _controller.position.maxScrollExtent) {
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
    _progress = searchItem.durContentIndex * 100 ~/ _controller.position.maxScrollExtent;
    notifyListeners();
  }

  void _initContent() async {
    _brightness = await Screen.brightness;
    if (_brightness > 1) {
      _brightness = 0.5;
    }
    _sysBrightness = _brightness;
    _keepOn = await Screen.isKeptOn;
    _content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
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

  Future<void> loadChapter(int chapterIndex) async {
    _showChapter = false;
    if (isLoading ||
        chapterIndex == searchItem.durChapterIndex ||
        chapterIndex < 0 ||
        chapterIndex >= searchItem.chapters.length) return;
    _isLoading = true;
    searchItem.durChapterIndex = chapterIndex;
    notifyListeners();
    _content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[chapterIndex].url);
    searchItem.durChapterIndex = chapterIndex;
    searchItem.durChapter = searchItem.chapters[chapterIndex].name;
    searchItem.durContentIndex = 1;
    await SearchItemManager.saveSearchItem();
    _isLoading = false;
    _controller.jumpTo(1);
    notifyListeners();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      Screen.setBrightness(-1.0);
    } else {
      Screen.setBrightness(_sysBrightness);
    }
    content.clear();
    _controller.dispose();
    SearchItemManager.saveSearchItem();
    super.dispose();
  }
}
