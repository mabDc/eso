import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/global.dart';
import 'package:eso/page/photo_view_page.dart';
import 'package:eso/ui/ui_fade_in_image.dart';
import 'package:eso/ui/widgets/chapter_page__view.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:screen/screen.dart';
import '../database/search_item.dart';
import 'package:flutter/material.dart';

import 'profile.dart';

class NovelPageProvider with ChangeNotifier {
  final SearchItem searchItem;
  int _progress;
  int get progress => _progress;
  List<dynamic> _paragraphs;
  List<dynamic> get paragraphs => _paragraphs;
  ScrollController _controller;
  ScrollController get controller => _controller;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _showMenu;
  bool get showMenu => _showMenu;

  set showMenu(bool value) {
    if (_showMenu != value) {
      _showMenu = value;
      if (value == false)
        _showChapter = false;
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

  ChapterPageController _pageController;
  ChapterPageController get pageController => _pageController;
  set pageController(value) => _pageController = value;

  final RefreshController refreshController = RefreshController();

  NovelPageProvider({this.searchItem, this.keepOn, this.height, Profile profile}) {
    _brightness = 0.5;
    _isLoading = false;
    _showChapter = false;
    _showMenu = false;
    _showSetting = false;
    _useSelectableText = false;
    _controller = ScrollController();
    _progress = 0;
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _initContent(profile);
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
    _readSetting = ReadSetting.fromProfile(profile, searchItem.durChapterIndex);
    _paragraphs = await loadContent(searchItem.durChapterIndex);
    if (this.mounted)
      notifyListeners();
  }

  Map<int, List<dynamic>> _cache;
  CacheUtil _fileCache;
  static bool _requestPermission = false;

  /// 切换章节
  switchChapter(Profile profile, int index) async {
    switch (profile.novelPageSwitch) {
      case Profile.novelHorizontalSlide:
      case Profile.novelVerticalSlide:
        pageController.toChapter(index, toFirst: true);
        break;
      default:
        var _data = await loadChapter(index);
        if (_data != null) this._paragraphs = _data;
        break;
    }
  }

  /// 刷新当前章节
  void refreshCurrent() async {
    if (await loadChapter(searchItem.durChapterIndex,
            useCache: false, changeCurChapter: false) !=
        null) searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
  }

  // 清理内存缓存
  _clearMemCache(int index) {
    if (_cache == null) return;
    int minIndex = index - 2;
    int maxIndex = index + 2;
    _cache.forEach((key, value) {
      if ((key <= minIndex || key >= maxIndex) && (key != index))
        _cache.remove(key);
    });
  }

  List<String> _cleanContent(List<String> content) {
    return content.join("\n").split(RegExp(r"\n\s*|\s{2,}"));
  }

  _updateCache(int index, List<String> content) {
    final _content = _cleanContent(content);
    _cache = {index: _content};
    _fileCache.putData('$index.${searchItem.name}.${searchItem.author}', _content);
  }

  _initFileCache() async {
    if (_fileCache == null) {
      _fileCache = CacheUtil(cacheName: searchItem.name);
      if (!_requestPermission) {
        _requestPermission = true;
        await _fileCache.requestPermission();
      }
    }
  }

  Future<List<dynamic>> _realLoadContent(int index, [bool useCache = true]) async {
    if (useCache) {
      if (_fileCache == null)
        await _initFileCache();
      var resp = await _fileCache.getData('$index.${searchItem.name}.${searchItem.author}');
      if (resp is List) {
        if (_cache == null)
          _cache = {index: resp};
        else
          _cache[index] = resp;
        return resp;
      }
    }
    List<String> result = await APIManager.getContent(
      searchItem.originTag,
      searchItem.chapters[index].url,
    );
    _updateCache(index, result);
    return result;
  }

  _cacheNextChapter(int index) async {
    if (index < searchItem.chapters.length - 1 && _cache[index + 1] == null) {
      Future.delayed(Duration(milliseconds: 200), () async {
        if (_cache[index + 1] == null) {
          await _realLoadContent(index + 1, true);
          if (index < searchItem.durChapterIndex + 3)
            _cacheNextChapter(index + 1);
        }
      });
    }
  }

  /// 加载章节内容
  Future<List<dynamic>> loadContent(int index,
      {bool useCache = true, VoidCallback onWait}) async {
    /// 检查当前章节
    if (_cache == null) {
      if (onWait != null) onWait();
      await _realLoadContent(index, useCache);
    } else if (_cache[index] == null) {
      if (onWait != null) onWait();
      await _realLoadContent(index, useCache);
    } else if (_cache.length > 16) {
      _clearMemCache(index);
    }

    /// 缓存下一个章节
    _cacheNextChapter(index);
    return _cache[index];
  }

  /// 加载指定章节
  Future<List<dynamic>> loadChapter(int chapterIndex,
      {bool useCache = true,
      bool notify = true,
      bool changeCurChapter = true,
      bool lastPage}) async {

    _showChapter = false;
    if (isLoading || chapterIndex < 0 || chapterIndex >= searchItem.chapters.length)
      return null;
    if (notify) _isLoading = true;
    var _data;
    try {
      _data = await loadContent(chapterIndex, useCache: useCache, onWait: () {
        if (notify) notifyListeners();
      });
    } catch (e) {
      print("加载失败：$e");
    }
    if (_data == null) {
      if (this.mounted) {
        _isLoading = false;
        if (notify)
          notifyListeners();
      }
      throw Future.error('加载章节失败：$chapterIndex');
    }

    if (changeCurChapter) {
      _paragraphs = _data;
      await updateSearchItem(chapterIndex, lastPage);
    } else if (lastPage == true) {
      searchItem.durContentIndex = 0x7fffffff;
    }

    if (changeCurChapter) {
      // 滚动模式
      if (_readSetting?.pageSwitch == Profile.novelScroll) {
        _controller.jumpTo(1);
      }
    }

    if (notify && this.mounted) {
      _isLoading = false;
      notifyListeners();
    }
    return _data;
  }

  /// 加载上一章或下一章，不显示loading
  loadChapterHideLoading(bool lastChapter) async {
    final loadIndex =
        lastChapter ? searchItem.durChapterIndex - 1 : searchItem.durChapterIndex + 1;
    if (loadIndex < 0 || loadIndex >= searchItem.chapters.length) return;
    await loadChapter(loadIndex, notify: false, changeCurChapter: true);
  }

  /// 更新当前章节信息
  updateSearchItem(int chapterIndex, [bool lastPage]) async {
    searchItem.durChapter = searchItem.chapters[chapterIndex].name;
    searchItem.durContentIndex = lastPage == true ? 0x7fffffff : 1;
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    searchItem.durChapterIndex = chapterIndex;
    await SearchItemManager.saveSearchItem();
  }

  int _currentPage;

  /// 当前页
  int get currentPage => _currentPage;
  set currentPage(int value) {
    if (value > 0 && value < spans.length) {
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
      } else if (leftHeight < 200) {
        loadChapter(searchItem.durChapterIndex + 1);
      } else {
        _controller.animateTo(
          _controller.position.maxScrollExtent - 40,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    } else if (_readSetting.pageSwitch == Profile.novelHorizontalSlide ||
        _readSetting.pageSwitch == Profile.novelVerticalSlide) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 200), curve: Curves.easeIn);
    } else {
      if (_currentPage < _spans.length) {
        _currentPage++;
        searchItem.durContentIndex = (_currentPage * 10000 / spans.length).floor();
        notifyListeners();
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
    } else if (_readSetting.pageSwitch == Profile.novelHorizontalSlide ||
        _readSetting.pageSwitch == Profile.novelVerticalSlide) {
      _pageController.previousPage(
          duration: Duration(milliseconds: 200), curve: Curves.easeOut);
    } else {
      if (_currentPage > 1) {
        _currentPage--;
        searchItem.durContentIndex = (_currentPage * 10000 / spans.length).floor();
        notifyListeners();
      } else {
        loadChapter(searchItem.durChapterIndex - 1, lastPage: true);
      }
    }
  }

  Future<bool> addToFavorite() async {
    if (SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
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
    refreshController.dispose();
    _cache?.clear();
    _isLoading = null;
    super.dispose();
  }

  bool get mounted => _isLoading != null;

  List<List<InlineSpan>> _spans;
  List<List<InlineSpan>> get spans => _spans;
  List<List<InlineSpan>> updateSpans(List<List<InlineSpan>> spans, {int initialPage}) {
    _spans = spans;
    _currentPage = (searchItem.durContentIndex * spans.length / 10000).round();
    if (_currentPage < 1) {
      _currentPage = 1;
    } else if (_currentPage > _spans.length) {
      _currentPage = _spans.length;
    }

    return _spans;
  }

  List<InlineSpan> _spansFlat;
  List<InlineSpan> get spansFlat => _spansFlat;
  List<InlineSpan> updateSpansFlat(List<List<InlineSpan>> spans) {
    _spansFlat = spans.expand((span) => span).toList();
    return _spansFlat;
  }

  ReadSetting _readSetting;
  bool didUpdateReadSetting(Profile profile) {
    if (_readSetting.durChapterIndex != searchItem.durChapterIndex) {
      _currentPage = 1;
      _readSetting.durChapterIndex = searchItem.durChapterIndex;
      return true;
    }
    if (_readSetting.pageSwitch != profile.novelPageSwitch) {
      _readSetting.pageSwitch = profile.novelPageSwitch;
      return true;
    }
    if ((null == _spansFlat && null == _spans) ||
        _readSetting.didUpdate(profile, searchItem.durChapterIndex)) {
      _readSetting = ReadSetting.fromProfile(profile, searchItem.durChapterIndex);
      print(_readSetting.durChapterIndex);
      return true;
    }
    return false;
  }

  /// 文字排版部分
  static List<List<InlineSpan>> buildSpans(BuildContext context, Profile profile,
      SearchItem searchItem, List<dynamic> paragraphs) {
    if (paragraphs == null || paragraphs.isEmpty || searchItem == null) return [];
    final __profile = profile;

    MediaQueryData mediaQueryData = MediaQueryData.fromWindow(ui.window);
    final width = mediaQueryData.size.width - __profile.novelLeftPadding * 2;
    final offset = Offset(width, 6);
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final oneLineHeight = __profile.novelFontSize * __profile.novelHeight;
    final height = mediaQueryData.size.height -
        __profile.novelTopPadding * 2 -
        32 -
        mediaQueryData.padding.top -
        oneLineHeight;
    //final fontColor = Color(__profile.novelFontColor);
    final _spans = <List<InlineSpan>>[];

    final newLine = TextSpan(text: "\n");
    final commonStyle = TextStyle(
      fontSize: __profile.novelFontSize,
      height: __profile.novelHeight,
      //color: fontColor,
    );
    final _buildHeightSpan = (double height) {
      return TextSpan(
          text: " ",
          style: TextStyle(
            height: 1,
            fontSize: height,
          ));
    };
    final paragraphLine = _buildHeightSpan(__profile.novelParagraphPadding);

    var _buildImageSpan = (String img, header) {
      return WidgetSpan(
        child: GestureDetector(
          onLongPress: () => Utils.startPageWait(
            context,
            PhotoViewPage(
              items: [PhotoItem(img, headers: header)],
              heroTag: "WidgetSpan$img",
            ),
          ),
          child: Container(
            width: width,
            child: Hero(
              tag: "WidgetSpan$img",
              child: UIFadeInImage(
                url: img,
                header: header,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
      );
    };

    var currentSpans = <InlineSpan>[
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
      paragraphLine,
    ];
    tp.text = TextSpan(children: currentSpans, style: commonStyle);
    tp.layout(maxWidth: width);
    var currentHeight = tp.height;
    if ((__profile.novelTitlePadding ?? 0) > 0) {
      currentSpans.add(TextSpan(
        children: [
          _buildHeightSpan(__profile.novelTitlePadding),
          newLine,
        ]
      ));
      currentHeight = currentHeight + __profile.novelTitlePadding;
    }
    tp.maxLines = 1;
    bool firstLine = true;
    final indentation = Global.fullSpace * __profile.novelIndentation;
    for (var paragraph in paragraphs) {
      if (!(paragraph is String)) continue;
      if (paragraph.startsWith("@img")) {
        print("------img--------");
        if (currentSpans.isNotEmpty) {
          _spans.add(currentSpans);
          currentHeight = 0;
          currentSpans = [];
        }
        final img = paragraph.split("@headers");
        final header = img.length == 2 ? jsonDecode(img[1]) : null;
        _spans.add([
          TextSpan(
            children: [
              _buildImageSpan(img[0], header),
              newLine,
            ],
          )
        ]);
        continue;
      } else if (paragraph.startsWith("<img")) {
        print("------img--------");
        if (currentSpans.isNotEmpty) {
          _spans.add(currentSpans);
          currentHeight = 0;
          currentSpans = [];
        }
        final img = RegExp(r"""(src|data\-original)[^'"]*('|")([^'"]*)""")
            .firstMatch(paragraph)
            .group(3);
        _spans.add([
          TextSpan(
            children: [
              _buildImageSpan(img, null),
              newLine,
            ],
          )
        ]);
        continue;
      }
      while (true) {
        if (currentHeight >= height) {
          _spans.add(currentSpans);
          currentHeight = 0;
          currentSpans = [];
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
          currentSpans.add(paragraphLine);
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
    if (currentSpans.isNotEmpty) {
      _spans.add(currentSpans);
    }
    return _spans;
  }

  void refreshProgress() {
    searchItem.durContentIndex =
        (_controller.position.pixels * 10000 / (_controller.position.maxScrollExtent + 1))
            .floor();
    _progress = searchItem.durContentIndex ~/ 100;
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
