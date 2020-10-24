import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import '../api/api_manager.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';

class ChapterPageProvider with ChangeNotifier {
  final Size size;
  final SearchItem searchItem;
  ScrollController _controller;
  ScrollController get controller => _controller;

  bool get isLoading => _isLoading;
  bool _isLoading;

  static const BigList = 0;
  static const SmallList = 1;
  static const Grid = 2;

  String getListStyleName([int listStyle]) {
    if (listStyle == null) {
      listStyle = searchItem.chapterListStyle;
    }
    switch (listStyle) {
      case BigList:
        return "大列表";
      case SmallList:
        return "小列表";
      case Grid:
        return "宫格";
      default:
        return "宫格";
    }
  }

  ChapterPageProvider({@required this.searchItem, @required this.size}) {
    // _controller = ScrollController(initialScrollOffset: _calcHeight);
    _controller = ScrollController();
    _isLoading = false;
    if (searchItem.chapters == null) {
      _isLoading = true;
      initChapters();
    } else if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
  }

  // double get _calcHeight {
  //   if (searchItem.chapters == null) return 0.0;
  //   double itemHeight;
  //   int lineNum;
  //   switch (searchItem.chapterListStyle) {
  //     case BigList:
  //       lineNum = 1;
  //       itemHeight = 66;
  //       break;
  //     case SmallList:
  //       lineNum = 2;
  //       itemHeight = 52;
  //       break;
  //     case Grid:
  //       lineNum = 5;
  //       itemHeight = 47;
  //       break;
  //   }
  //   final durHeight = searchItem.durChapterIndex ~/ lineNum * itemHeight;
  //   double height = searchItem.chapters.length ~/ lineNum * itemHeight;
  //   if (searchItem.chapters.length % lineNum > 0) {
  //     height += itemHeight;
  //   }
  //   final screenHeight = size.height - 246;
  //   if (height < screenHeight) {
  //     return 1.0;
  //   }
  //   if ((height - durHeight) < screenHeight) {
  //     return height - screenHeight;
  //   }
  //   return durHeight;
  // }

  void adjustScroll() {
    //_controller.jumpTo(_calcHeight);
    notifyListeners();
  }

  void initChapters() async {
    searchItem.chapters =
        await APIManager.getChapter(searchItem.originTag, searchItem.url);
    searchItem.durChapterIndex = 0;
    searchItem.durContentIndex = 1;
    if (searchItem.chapters.isEmpty) {
      searchItem.durChapter = '';
      searchItem.chaptersCount = 0;
      searchItem.chapter = '';
    } else {
      searchItem.durChapter = searchItem.chapters?.first?.name ?? '';
      searchItem.chaptersCount = searchItem.chapters?.length ?? 0;
      searchItem.chapter = searchItem.chapters?.last?.name;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateChapter() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    if (searchItem.ruleContentType == API.RSS) {
      Set<String> chs = Set<String>();
      chs.addAll(searchItem.chapters?.map((ch) => ch.url));
      List<ChapterItem> temps =
          await APIManager.getChapter(searchItem.originTag, searchItem.url);
      searchItem.chapters.addAll(temps.where((ch) => !chs.contains(ch.url)));
    } else {
      searchItem.chapters =
          await APIManager.getChapter(searchItem.originTag, searchItem.url);
    }

    searchItem.chaptersCount = searchItem.chapters.length;
    if (searchItem.chaptersCount > 0) {
      searchItem.chapter = searchItem.chapters.last?.name;
    } else {
      searchItem.chapter = '';
    }
    if (SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      await SearchItemManager.saveChapter(searchItem.id, searchItem.chapters);
    }
    _isLoading = false;
    notifyListeners();
    return;
  }

  void changeChapter(int index) async {
    HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
    if (searchItem.durChapterIndex != index) {
      searchItem.durChapterIndex = index;
      searchItem.durChapter = searchItem.chapters[index].name;
      searchItem.durContentIndex = 1;
      await SearchItemManager.saveSearchItem();
      HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
      await HistoryItemManager.saveHistoryItem();
      notifyListeners();
    }
  }

  void toggleFavorite() async {
    if (_isLoading) return;
    await SearchItemManager.toggleFavorite(searchItem);
    notifyListeners();
  }

  void share() async {
    await FlutterShare.share(
      title: '亦搜 eso',
      text: '${searchItem.name}\n${searchItem.description}\n${searchItem.url}',
      //linkUrl: '${searchItem.url}',
      chooserTitle: '选择分享的应用',
    );
  }

  void scrollerToTop() {
    _controller.jumpTo(1);
  }

  void scrollerToBottom() {
    _controller.jumpTo(_controller.position.maxScrollExtent - 1);
  }

  void toggleReverse() {
    searchItem.reverseChapter = !searchItem.reverseChapter;
    notifyListeners();
  }

  void changeListStyle(int listStyle) async {
    if (searchItem.chapterListStyle != listStyle) {
      searchItem.chapterListStyle = listStyle;
      await SearchItemManager.saveSearchItem();
      notifyListeners();
      await Future.delayed(Duration(milliseconds: 10));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
