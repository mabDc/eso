import 'dart:io';

import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:screen/screen.dart';
import '../database/search_item.dart';
import 'package:flutter/material.dart';

import 'profile.dart';

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

  final double height;

  PageController _pageController;
  PageController get pageController => _pageController;

  NovelPageProvider({this.searchItem, this.keepOn, this.height, Profile profile}) {
    _brightness = 0.5;
    _isLoading = false;
    _showChapter = false;
    _showMenu = false;
    _showSetting = false;
    _useSelectableText = false;
    _controller = ScrollController();
    _needPageJumpTo = false;
    _progress = 0;
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _initContent(profile);
  }

  void refreshProgress() {
    searchItem.durContentIndex =
        (_controller.position.pixels * 10000 / _controller.position.maxScrollExtent)
            .floor();
    _progress = searchItem.durContentIndex ~/ 100;
    notifyListeners();
  }

  void _initContent(Profile profile) async {
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
    _paragraphs = content.join("\n").split(RegExp(r"\n\s*"));
    _readSetting = ReadSetting.fromProfile(profile, searchItem.durChapterIndex);
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
    final content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[loadIndex].url);
    _paragraphs = content.join("\n").split(RegExp(r"\n\s*"));
    searchItem.durChapter = searchItem.chapters[loadIndex].name;
    searchItem.durContentIndex = 1;
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    searchItem.durChapterIndex = loadIndex;
    await SearchItemManager.saveSearchItem();
    _hideLoading = false;
    if (_readSetting?.pageSwitch == Profile.novelScroll) {
      _controller.jumpTo(1);
    }
  }

  Future<void> loadChapter(int chapterIndex) async {
    _showChapter = false;
    if (isLoading ||
        chapterIndex == searchItem.durChapterIndex ||
        chapterIndex < 0 ||
        chapterIndex >= searchItem.chapters.length) return;
    _isLoading = true;
    notifyListeners();
    final content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[chapterIndex].url);
    _paragraphs = content.join("\n").split(RegExp(r"\n\s*"));
    searchItem.durChapter = searchItem.chapters[chapterIndex].name;
    searchItem.durContentIndex = 1;
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    searchItem.durChapterIndex = chapterIndex;
    await SearchItemManager.saveSearchItem();
    _isLoading = false;
    if (_readSetting?.pageSwitch == Profile.novelScroll) {
      _controller.jumpTo(1);
    }
    notifyListeners();
  }

  void refreshCurrent() async {
    if (isLoading) return;
    _isLoading = true;
    _showChapter = false;
    notifyListeners();
    final content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
    _paragraphs = content.join("\n").split(RegExp(r"\n\s*"));
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    _isLoading = false;
    notifyListeners();
  }

  int _currentPage;
  int get currentPage => _currentPage;
  set currentPage(int value) {
    if (value >= 0 && value < spans.length) {
      _currentPage = value + 1;
      searchItem.durContentIndex = (_currentPage * 10000 / spans.length).floor();
    }
  }

  void tapNextPage() {
    if (_readSetting.pageSwitch == Profile.novelScroll) {
      final leftHeight =
          _controller.position.maxScrollExtent - _controller.position.pixels;
      if (leftHeight > height) {
        _controller.animateTo(
          _controller.position.pixels + height,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else if (leftHeight < 50) {
        loadChapter(searchItem.durChapterIndex + 1);
      } else {
        _controller.animateTo(
          _controller.position.maxScrollExtent - 40,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } else if (_readSetting.pageSwitch == Profile.novelNone) {
      if (_currentPage < _spans.length) {
        _currentPage++;
        searchItem.durContentIndex = (_currentPage * 10000 / spans.length).floor();
        notifyListeners();
      } else {
        loadChapter(searchItem.durChapterIndex + 1);
      }
    } else if (_readSetting.pageSwitch == Profile.novelHorizontalSlide ||
        _readSetting.pageSwitch == Profile.novelVerticalSlide) {
      if (_currentPage < _spans.length) {
        _currentPage++;
        searchItem.durContentIndex = (_currentPage * 10000 / spans.length).floor();
        _pageController.animateToPage(_currentPage - 1,
            duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
      } else {
        loadChapter(searchItem.durChapterIndex + 1);
      }
    }
  }

  void tapLastPage() {
    if (_readSetting.pageSwitch == Profile.novelScroll) {
      if (_controller.position.pixels > height) {
        _controller.animateTo(
          _controller.position.pixels - height,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      } else if (_controller.position.pixels < 10) {
        loadChapter(searchItem.durChapterIndex - 1);
      } else {
        _controller.animateTo(
          1,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } else if (_readSetting.pageSwitch == Profile.novelNone) {
      if (_currentPage > 1) {
        _currentPage--;
        searchItem.durContentIndex = (_currentPage * 10000 / spans.length).floor();
        notifyListeners();
      } else {
        loadChapter(searchItem.durChapterIndex - 1);
      }
    } else if (_readSetting.pageSwitch == Profile.novelHorizontalSlide ||
        _readSetting.pageSwitch == Profile.novelVerticalSlide) {
      if (_currentPage > 1) {
        _currentPage--;
        searchItem.durContentIndex = (_currentPage * 10000 / spans.length).floor();
        _pageController.animateToPage(_currentPage - 1,
            duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
      } else {
        loadChapter(searchItem.durChapterIndex - 1);
      }
    }
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
    _paragraphs?.clear();
    _pageController?.dispose();
    spans?.clear();
    spansFlat?.clear();
    _controller?.dispose();
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    SearchItemManager.saveSearchItem();
    super.dispose();
  }

  List<List<TextSpan>> _spans;
  List<List<TextSpan>> get spans => _spans;
  List<List<TextSpan>> updateSpans(List<List<TextSpan>> spans) {
    _spans = spans;
    _currentPage = (searchItem.durContentIndex * spans.length / 10000).round();
    if (_currentPage < 1) {
      _currentPage = 1;
    } else if (_currentPage > _spans.length) {
      _currentPage = _spans.length;
    }
    if (_readSetting.pageSwitch == Profile.novelHorizontalSlide ||
        _readSetting.pageSwitch == Profile.novelVerticalSlide) {
      if (_pageController != null && _needPageJumpTo) {
        _pageController.jumpToPage(_currentPage - 1);
      } else {
        final temp = _pageController;
        _pageController = PageController(initialPage: _currentPage - 1);
        Future.delayed(Duration(seconds: 1), () => temp?.dispose());
      }
    }
    return _spans;
  }

  List<TextSpan> _spansFlat;
  List<TextSpan> get spansFlat => _spansFlat;
  List<TextSpan> updateSpansFlat(List<List<TextSpan>> spans) {
    _spansFlat = spans.expand((span) => span).toList();
    return _spansFlat;
  }

  bool _needPageJumpTo;
  ReadSetting _readSetting;
  bool didUpdateReadSetting(Profile profile) {
    if (_readSetting.durChapterIndex != searchItem.durChapterIndex) {
      _currentPage = 1;
      _readSetting.durChapterIndex = searchItem.durChapterIndex;
      _needPageJumpTo = false;
      return true;
    }
    if (_readSetting.pageSwitch != profile.novelPageSwitch) {
      _readSetting.pageSwitch = profile.novelPageSwitch;
      _needPageJumpTo = false;
      return true;
    }
    if ((null == _spansFlat && null == _spans) ||
        _readSetting.didUpdate(profile, searchItem.durChapterIndex)) {
      _readSetting = ReadSetting.fromProfile(profile, searchItem.durChapterIndex);
      _needPageJumpTo = true;
      return true;
    }
    return false;
  }
}

class ReadSetting {
  double fontSize;
  double height;
  double topPadding;
  double leftPadding;
  double paragraphPadding;
  int pageSwitch;
  int indentation;
  int durChapterIndex;

  ReadSetting.fromProfile(Profile profile, this.durChapterIndex) {
    fontSize = profile.novelFontSize;
    height = profile.novelHeight;
    leftPadding = profile.novelLeftPadding;
    topPadding = profile.novelTopPadding;
    paragraphPadding = profile.novelParagraphPadding;
    pageSwitch = profile.novelPageSwitch;
    indentation = profile.novelIndentation;
  }

  bool didUpdate(Profile profile, int durChapterIndex) {
    if ((fontSize - profile.novelFontSize).abs() < 0.1 &&
        (height - profile.novelHeight).abs() < 0.05 &&
        (leftPadding - profile.novelLeftPadding).abs() < 0.1 &&
        (topPadding - profile.novelTopPadding).abs() < 0.1 &&
        (paragraphPadding - profile.novelParagraphPadding).abs() < 0.1 &&
        pageSwitch == profile.novelPageSwitch &&
        indentation == profile.novelIndentation &&
        this.durChapterIndex == durChapterIndex) {
      return false;
    }
    return true;
  }
}
