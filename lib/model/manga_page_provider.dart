import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/page/content_page_manager.dart';
import 'package:eso/page/photo_view_page.dart';
import 'package:eso/profile.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock/wakelock.dart';
import 'package:win32/win32.dart';

class MangaList {
  final List<PhotoItem> photoItem;
  final String name;
  final int length;

  MangaList(
      {List<PhotoItem> this.photoItem, String this.name, int this.length});
}

class ListScrollData {
  int firstIndex;
  int lastIndex;
  double leadingScrollOffset;
  double trailingScrollOffset;
  int index;
  int length;
  bool isBottom;
  ListScrollData(
      {this.firstIndex,
      this.lastIndex,
      this.leadingScrollOffset,
      this.trailingScrollOffset,
      this.isBottom = false,
      this.index = -1,
      this.length = -1});
}

class MangaPageProvider with ChangeNotifier, WidgetsBindingObserver {
  final SearchItem searchItem;

  StreamController<ListScrollData> _streamController =
      StreamController.broadcast();

  StreamController<ListScrollData> get streamController => _streamController;

  ScrollController _controller = ScrollController();
  ScrollController get controller => _controller;

  int _firstChapterIndex;
  int get firstChapterIndex => _firstChapterIndex;
  EasyRefreshController _easycontroller;
  EasyRefreshController get easycontroller => _easycontroller;
  // Map<int, List<PhotoItem>> _loadsContent = Map<int, List<PhotoItem>>();
  // Map<int, List<PhotoItem>> get loadsContent => _loadsContent;

  List<MangaList> _contentList = [];
  List<MangaList> get contentList => _contentList;

  List<MangaList> _contentPrevList = [];
  List<MangaList> get contentPrevList => _contentPrevList;
  int _loadCount = 0;
  int get loadCount => _loadCount;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  set currentIndex(int value) {
    if (value != _currentIndex) {
      _currentIndex = value;
      notifyListeners();
    }
  }

  double _maxScrollExtent = 0.0;
  double get maxScrollExtent => _maxScrollExtent;

  // List<PhotoItem> get content => _content;

  // List<PhotoItem> _content;
  // List<PhotoItem> get content => _content;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        Wakelock.toggle(enable: false);
        break;
      case AppLifecycleState.resumed:
        Wakelock.toggle(enable: true);
        break;
      default:
    }

    super.didChangeAppLifecycleState(state);
  }

  bool _isfistLoad = true;
  bool get isfistLoad => _isfistLoad;
  set isfistLoad(bool value) {
    if (value != _isfistLoad) {
      _isfistLoad = value;
    }
  }

  bool _isNextLoad = false;
  bool get isNextLoad => _isNextLoad;
  set isNextLoad(bool value) {
    if (value != _isNextLoad) {
      _isNextLoad = value;
    }
  }

  bool _isLoading;
  bool get isLoading => _isLoading;
  bool _showLoading;
  bool get showLoading => _showLoading;

  Map<String, String> _headers;
  Map<String, String> get headers => _headers;

  final ContentProvider contentProvider;

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

  double _brightness;
  double get brightness => _brightness;
  set brightness(double value) {
    print("set brightness:${value}");
    if ((value - _brightness).abs() > 0.005) {
      _brightness = value;
      ScreenBrightness().setScreenBrightness(brightness);
    }
  }

  bool showMangaInfo;
  void setshowMangaInfo(bool value) {
    if (value != showMangaInfo) {
      showMangaInfo = value;
      Profile().showMangaInfo = value;

      // ScreenBrightness().keepOn(keepOn);
    }
  }

  FilterQuality _quality;
  FilterQuality get quality => _quality;

  void setQuality(FilterQuality quality) {
    if (_quality != quality) {
      _quality = quality;

      Profile().mangaQuality = _quality.index;
      notifyListeners();
    }
  }

  bool landscape;
  void setLandscape(bool value) {
    if (value != landscape) {
      landscape = value;
      if (landscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
      Profile().mangaLandscape = landscape;
    }
  }

  int direction;
  void setDirection(int value) {
    if (value != direction) {
      direction = value;
      Profile().mangaDirection = direction;
      notifyListeners();
    }
  }

  MangaPageProvider({
    this.searchItem,
    this.showMangaInfo = false,
    this.landscape = false,
    this.direction = Profile.mangaDirectionTopToBottom,
    this.contentProvider,
  }) {
    _brightness = 0.5;
    _isLoading = false;
    _showLoading = true;
    _showMenu = false;
    _showSetting = false;
    _headers = Map<String, String>();
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _easycontroller = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);

    _initContent();
    loadChapter(chapterIndex: null, isNext: true, isShowLoading: true);
  }

  void _initContent() async {
    if (Platform.isAndroid || Platform.isIOS) {
      _brightness = await ScreenBrightness().current;
      if (_brightness > 1) {
        _brightness = 0.5;
      }
      Wakelock.toggle(enable: true);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    _quality = FilterQuality.values.elementAt(Profile().mangaQuality);

    if (landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void share() {
    Share.share(
        '${searchItem.name.trim()}\n${searchItem.author.trim()}\n\n${searchItem.description.trim()}\n\n${searchItem.chapterUrl}');
  }

  int _refreshFav = 0;
  int get refreshFav => _refreshFav;

  void toggleFavorite() async {
    print("_isLoading:${_isLoading}");
    if (_isLoading) return;
    await SearchItemManager.toggleFavorite(searchItem);
    _refreshFav++;
    notifyListeners();
  }

  Future<Uint8List> _onDecrypt(Uint8List body) async {
    dynamic result = await APIManager.parseContent(searchItem.originTag, body);

    if (result is Uint8List) {
      return result;
    }
    result = jsonDecode(result);
    if (result is Map) {
      final bytes = result['bytes'].cast<int>();
      return Uint8List.fromList(bytes);
    }
    Utils.toast("解密返回数据不是OBJ");
    return body;
  }

  Future<void> loadChapter({
    int chapterIndex,
    bool useCache = true,
    bool loadNext = true,
    bool shouldChangeIndex = true,
    bool isNext = false,
    bool restList = false,
    bool isShowLoading = false,
  }) async {
    if (chapterIndex == null) {
      chapterIndex = searchItem.durChapterIndex;
    }
    print("chapterIndex:${chapterIndex}");

    if (isLoading ||
        chapterIndex < 0 ||
        chapterIndex >= searchItem.chapters.length) return;

    _isLoading = true;
    if (isShowLoading) {
      _showLoading = true;
    }
    if (restList) {
      print("重置列表");
      _contentList.clear();
      _contentPrevList.clear();
      controller?.jumpTo(1);
      _loadCount = 0;
      _firstChapterIndex = null;
      _streamController.add(ListScrollData(isBottom: true));
    }

    if (direction != Profile.mangaDirectionTopToBottom) {
      _contentPrevList.clear();
      _firstChapterIndex = null;
      _contentList.clear();
    }

    notifyListeners();
    final c = await contentProvider.loadChapter(
        chapterIndex, useCache, loadNext, shouldChangeIndex);
    Map<String, String> headers = null;

    final list = List.generate(c.length, (i) {
      final index = c[i].indexOf("@headers");
      if (index == -1) return PhotoItem(c[i], headers, _onDecrypt);
      headers = (jsonDecode(c[i].substring(index + 8)) as Map)
          .map((k, v) => MapEntry('$k', '$v'));
      return PhotoItem(c[i].substring(0, index), headers, _onDecrypt);
    });

    if (isNext || direction != Profile.mangaDirectionTopToBottom) {
      print("添加下一章");

      _contentList.add(MangaList(
          photoItem: list, name: searchItem.durChapter, length: list.length));
    } else {
      print("添加上一章");

      _contentPrevList.add(MangaList(
          photoItem: list, name: searchItem.durChapter, length: list.length));
    }

    if (direction != Profile.mangaDirectionTopToBottom) {
      _streamController.add(
        ListScrollData(
          firstIndex: 0,
          lastIndex: 0,
          isBottom: true,
          index: 1,
          length: list.length,
        ),
      );
    }
    if (_firstChapterIndex == null) {
      _firstChapterIndex = searchItem.durChapterIndex;
    }
    print(
        "_contentPrevList:${_contentPrevList.length},_contentList:${_contentList.length}");

    _loadCount++;
    _chapterName = searchItem.durChapter;

    headers = null;
    _isLoading = false;

    if (isShowLoading) {
      _showLoading = false;
    }

    notifyListeners();
  }

  String _chapterName = "";
  String get chapterName => _chapterName;

  void updateChapter(String name, int index) {
    searchItem.durChapter = name;
    searchItem.durChapterIndex = index;
    _chapterName = name;
    notifyListeners();
  }

  bool get isFavorite =>
      SearchItemManager.isFavorite(searchItem.originTag, searchItem.url);

  Future<bool> addToFavorite() async {
    if (isFavorite) return null;
    return await SearchItemManager.addSearchItem(searchItem);
  }

  Future<bool> removeFormFavorite() async {
    if (!isFavorite) return true;
    return await SearchItemManager.removeSearchItem(searchItem.id);
  }

  void loadNextChapter(bool isNext) {
    // print("next:${next}");
    final index = searchItem.durChapterIndex;
    if (isNext && index < (searchItem.chaptersCount - 1)) {
      loadChapter(chapterIndex: index + 1, isNext: isNext);
    } else if (index > 0) {
      loadChapter(chapterIndex: index - 1, isNext: isNext);
    }
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      ScreenBrightness().resetScreenBrightness();
      Wakelock.toggle(enable: false);

      //DeviceDisplayBrightness.resetBrightness();
      //DeviceDisplayBrightness.keepOn(enabled: false);
    }
    _contentList?.forEach((element) {
      element?.photoItem?.clear();
    });
    _contentList?.clear();

    _contentPrevList?.forEach((element) {
      element?.photoItem?.clear();
    });
    _contentPrevList?.clear();

    _controller?.dispose();
    _easycontroller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    super.dispose();
  }
}
