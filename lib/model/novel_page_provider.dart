import 'dart:io';
import 'dart:ui' as ui;

import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/global.dart';
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

  Profile _profile;

  NovelPageProvider({this.searchItem, this.keepOn, this.height, Profile profile}) {
    _profile = profile;
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
    await freshContentWithCache();
    _readSetting = ReadSetting.fromProfile(profile, searchItem.durChapterIndex);
    notifyListeners();
  }

  Map<int, List<String>> _cache;
  Future<bool> freshContentWithCache([VoidCallback onWait]) async {
    final index = searchItem.durChapterIndex;

    /// 检查当前章节
    if (_cache == null) {
      if (onWait != null) onWait();
      final content = await APIManager.getContent(
        searchItem.originTag,
        searchItem.chapters[index].url,
      );
      _cache = {index: content.join("\n").split(RegExp(r"\n\s*|\s{2,}"))};
    } else if (_cache[index] == null) {
      if (onWait != null) onWait();
      final content = await APIManager.getContent(
        searchItem.originTag,
        searchItem.chapters[index].url,
      );
      _cache[index] = content.join("\n").split(RegExp(r"\n\s*|\s{2,}"));
    }
    _paragraphs = _cache[index];

    /// 缓存下一个章节
    if (index < searchItem.chapters.length - 1 && _cache[index + 1] == null) {
      Future.delayed(Duration(milliseconds: 100), () async {
        if (_cache[index + 1] == null) {
          final content = await APIManager.getContent(
            searchItem.originTag,
            searchItem.chapters[index + 1].url,
          );
          _cache[index + 1] = content.join("\n").split(RegExp(r"\n\s*|\s{2,}"));
        }
      });
    }
    return true;
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
    await freshContentWithCache();
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

  Future<void> loadChapter(int chapterIndex, [bool notify = true]) async {
    _showChapter = false;
    if (isLoading ||
        chapterIndex == searchItem.durChapterIndex ||
        chapterIndex < 0 ||
        chapterIndex >= searchItem.chapters.length) return;
    _isLoading = true;
    await freshContentWithCache(() => notifyListeners());
    searchItem.durChapter = searchItem.chapters[chapterIndex].name;
    searchItem.durContentIndex = 1;
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    searchItem.durChapterIndex = chapterIndex;
    await SearchItemManager.saveSearchItem();
    _isLoading = false;
    if (_readSetting?.pageSwitch == Profile.novelScroll) {
      _controller.jumpTo(1);
    }
    if (notify == true)
      notifyListeners();
  }

  void refreshCurrent() async {
    if (isLoading) return;
    _isLoading = true;
    _showChapter = false;
    notifyListeners();
    final content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
    _paragraphs = content.join("\n").split(RegExp(r"\n\s*|\s{2,}"));
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    _isLoading = false;
    notifyListeners();
  }

  int _currentPage;
  int get currentPage => _currentPage;
  set currentPage(int value) {
    if (value > 0 && value < spans.length) {
      _currentPage = value + 1;
      searchItem.durContentIndex = (_currentPage * 10000 / spans.length).floor();
    } else if (_readSetting.pageSwitch == Profile.novelHorizontalSlide ||
        _readSetting.pageSwitch == Profile.novelVerticalSlide) {
      if (_autoSwitchPageing) return;
      _autoSwitchPageing = true;
      _currentPage = value;
      _autoSwitchPage(value);
    }
  }

  bool _needJumpToLastPage = false;
  bool _autoSwitchPageing = false;

  void _autoSwitchPage(int value) async {
    if (value <= 0 && searchItem.durChapterIndex > 0) {
      _needJumpToLastPage = true;
      await loadChapter(searchItem.durChapterIndex - 1);
    } else if (value > spans.length && searchItem.durChapterIndex < searchItem.chapters.length - 1) {
      await loadChapter(searchItem.durChapterIndex + 1);
      //_pageController.jumpToPage(1);
    }
    _autoSwitchPageing = false;
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
    _cache?.clear();
    super.dispose();
  }

  List<List<TextSpan>> _spans;
  List<List<TextSpan>> get spans => _spans;
  List<List<TextSpan>> updateSpans(List<List<TextSpan>> spans, {int initialPage}) {
    _spans = spans;
    _currentPage = (searchItem.durContentIndex * spans.length / 10000).round();
    if (_currentPage < 1) {
      _currentPage = 1;
    } else if (_currentPage > _spans.length) {
      _currentPage = _spans.length;
    }
    if (_needJumpToLastPage) {
      _currentPage = _spans.length;
      _needJumpToLastPage = false;
    }

    if (searchItem.durChapterIndex > 0)
      _currentPage++;

    if (_readSetting.pageSwitch == Profile.novelHorizontalSlide ||
        _readSetting.pageSwitch == Profile.novelVerticalSlide) {
      if (_pageController != null && _needPageJumpTo) {
        _pageController.jumpToPage(_currentPage - 1);
      } else {
        final temp = _pageController;
        _pageController = PageController(initialPage: initialPage ?? _currentPage - 1);
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

  /// 文字排版部分
  List<List<TextSpan>> buildSpans(NovelPageProvider provider, Profile profile) {
    final __profile = profile ?? _profile;
    if (_profile != __profile) _profile = __profile;
    MediaQueryData mediaQueryData = MediaQueryData.fromWindow(ui.window);
    final width = mediaQueryData.size.width - __profile.novelLeftPadding * 2;
    final offset = Offset(width, 6);
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    final oneLineHeight = __profile.novelFontSize * __profile.novelHeight;
    final height = mediaQueryData.size.height -
        __profile.novelTopPadding * 2 -
        32 -
        mediaQueryData.padding.top -
        oneLineHeight;
    //final fontColor = Color(__profile.novelFontColor);
    final spanss = <List<TextSpan>>[];

    final newLine = TextSpan(text: "\n");
    final commonStyle = TextStyle(
      fontSize: __profile.novelFontSize,
      height: __profile.novelHeight,
      //color: fontColor,
    );

    var currentSpans = <TextSpan>[
      TextSpan(
        text: searchItem.durChapter,
        style: TextStyle(
          fontSize: __profile.novelFontSize + 2,
          //color: fontColor,
          height: __profile.novelHeight,
          fontWeight: FontWeight.bold,
        ),
      ),
      newLine,
      TextSpan(
          text: " ",
          style: TextStyle(
            height: 1,
            //color: fontColor,
            fontSize: __profile.novelParagraphPadding,
          )),
      newLine,
    ];
    tp.text = TextSpan(children: currentSpans);
    tp.layout(maxWidth: width);
    var currentHeight = tp.height;
    bool firstLine = true;
    final indentation = Global.fullSpace * __profile.novelIndentation;
    for (var paragraph in provider.paragraphs) {
      while (true) {
        if (currentHeight >= height) {
          spanss.add(currentSpans);
          currentHeight = 0;
          currentSpans = <TextSpan>[];
        }
        var firstPos = 1;
        if (firstLine) {
          firstPos = 3;
          firstLine = false;
          paragraph = indentation + paragraph;
        }
        tp.text = TextSpan(text: paragraph, style: commonStyle);
        tp.layout(maxWidth: width);
        final pos = tp.getPositionForOffset(offset).offset;
        final text = paragraph.substring(0, pos);
        paragraph = paragraph.substring(pos);
        if (paragraph.isEmpty) {
          // 最后一行调整宽度保证单行显示
          if (width - tp.width - __profile.novelFontSize < 0) {
            currentSpans.add(TextSpan(
              text: text.substring(0, firstPos),
              style: commonStyle,
            ));
            currentSpans.add(TextSpan(
                text: text.substring(firstPos, text.length - 1),
                style: TextStyle(
                  fontSize: __profile.novelFontSize,
                  //color: fontColor,
                  height: __profile.novelHeight,
                  letterSpacing: (width - tp.width) / (text.length - firstPos - 1),
                )));
            currentSpans.add(TextSpan(
              text: text.substring(text.length - 1),
              style: commonStyle,
            ));
          } else {
            currentSpans.add(TextSpan(
                text: text,
                style: TextStyle(
                  fontSize: __profile.novelFontSize,
                  height: __profile.novelHeight,
                  //color: fontColor,
                )));
          }
          currentSpans.add(newLine);
          currentSpans.add(TextSpan(
              text: " ",
              style: TextStyle(
                height: 1,
                //color: fontColor,
                fontSize: __profile.novelParagraphPadding,
              )));
          currentSpans.add(newLine);
          currentHeight += oneLineHeight;
          currentHeight += __profile.novelParagraphPadding;
          firstLine = true;
          break;
        }
        tp.text = TextSpan(
          text: text,
          style: TextStyle(
            fontSize: __profile.novelFontSize,
            //color: fontColor,
            height: __profile.novelHeight,
          ),
        );
        tp.layout();
        currentSpans.add(TextSpan(
          text: text.substring(0, firstPos),
          style: commonStyle,
        ));
        currentSpans.add(TextSpan(
            text: text.substring(firstPos, text.length - 1),
            style: TextStyle(
              fontSize: __profile.novelFontSize,
              //color: fontColor,
              height: __profile.novelHeight,
              letterSpacing: (width - tp.width) / (text.length - firstPos - 1),
            )));
        currentSpans.add(TextSpan(
          text: text.substring(text.length - 1),
          style: commonStyle,
        ));
        currentHeight += oneLineHeight;
      }
    }
    spanss.add(currentSpans);
    return spanss;
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
