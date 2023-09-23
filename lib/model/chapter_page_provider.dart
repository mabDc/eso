import 'dart:convert';
import 'dart:io';

import 'package:eso/api/api.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:eso/menu/menu_chapter.dart';
import 'package:eso/page/search_page.dart';
import 'package:eso/page/source/edit_rule_page.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_manager.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import '../global.dart';
import '../utils.dart';

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
    }
    //  else if (searchItem.chapters?.length == 0 &&
    //     SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
    //   searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    // }
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

  int _page = -1;
  int get page => _page;
  String checkContent;

  Future loadChpaterWithPage(int page) async {
    if (_page == 1) {
      _page++;
      notifyListeners();
      checkContent = buildCheck(searchItem.chapters);
    }

    final endCheck = () {
      _page = -page; // 结束
      checkContent = "";
      _isLoading = false;
      notifyListeners();
    };
    
    await Duration(milliseconds: 500); // 随意休息一下
    print("加载目录$page");
    final durChapters =
        await APIManager.getChapter(searchItem.originTag, searchItem.url, _page);
    if (durChapters.isEmpty) {
      endCheck();
      return;
    }
    final _checkContent = buildCheck(durChapters);
    if (checkContent == _checkContent) {
      endCheck();
      return;
    }
    searchItem.chapters.addAll(durChapters);
    searchItem.chaptersCount = searchItem.chapters?.length ?? 0;
    searchItem.chapter = searchItem.chapters?.last?.name;
    _page++;
    notifyListeners();
    loadChpaterWithPage(_page);
  }

  String buildCheck(List<ChapterItem> chapters) {
    return "${chapters.length}${chapters.map((c) => c.name.trim()).join("")}";
  }

  void initChapters() async {
    _page = 1;
    searchItem.chapters =
        await APIManager.getChapter(searchItem.originTag, searchItem.url, page);
    searchItem.chapterUrl = API.chapterUrl;
    searchItem.durChapterIndex = 0;
    searchItem.durContentIndex = 1;
    if (searchItem.chapters.isEmpty) {
      searchItem.durChapter = '';
      searchItem.chaptersCount = 0;
      searchItem.chapter = '';
      _page = 0;
    } else {
      searchItem.durChapter = searchItem.chapters?.first?.name ?? '';
      searchItem.chaptersCount = searchItem.chapters?.length ?? 0;
      searchItem.chapter = searchItem.chapters?.last?.name;
      loadChpaterWithPage(_page);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateChapter() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    searchItem.chapters =
        await APIManager.getChapter(searchItem.originTag, searchItem.url);
    searchItem.chapterUrl = API.chapterUrl;

    searchItem.chaptersCount = searchItem.chapters.length;
    if (searchItem.chaptersCount > 0) {
      searchItem.chapter = searchItem.chapters.last?.name;
      _page = 1;
      loadChpaterWithPage(_page);
    } else {
      _page = 0;
    }
    if (SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      await searchItem.save();
      // await SearchItemManager.saveChapter(searchItem.id, searchItem.chapters);
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
      // await SearchItemManager.saveSearchItem();
      await searchItem.save();
      notifyListeners();
    }
  }

  void toggleFavorite() async {
    if (_isLoading) return;
    await SearchItemManager.toggleFavorite(searchItem);
    notifyListeners();
  }

  void onSelect(MenuChapter value, BuildContext context) async {
    if (value == null) return;
    switch (value) {
      case MenuChapter.copy_dec:
        await Clipboard.setData(ClipboardData(text: searchItem.description));
        Utils.toast("已复制");
        break;
      case MenuChapter.refresh:
        updateChapter();
        break;
      case MenuChapter.clear_cache:
        final _fileCache =
            CacheUtil(basePath: "cache${Platform.pathSeparator}${searchItem.id}");
        await CacheUtil.requestPermission();
        await _fileCache.clear();
        Utils.toast("清理成功");
        break;
      case MenuChapter.edit:
        Utils.toast("请等待下个版本");
        break;
      case MenuChapter.edit_rule:
        final rule = await Global.ruleDao.findRuleById(searchItem.originTag);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => EditRulePage(rule: rule)));
        break;
      case MenuChapter.change:
        final r = await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SimpleChangeRule(searchItem: searchItem)));
        if (r != null && r is SearchItem) {
          searchItem.changeTo(r);
          updateChapter();
        } else {
          Utils.toast("未选择");
        }
        break;
      case MenuChapter.open_host_url:
        final rule = await Global.ruleDao.findRuleById(searchItem.originTag);
        if (rule.host != null) {
          launch(rule.host);
        } else {
          Utils.toast("错误 地址为空");
        }
        break;
      case MenuChapter.open_item_url:
        final url = searchItem.searchUrl;
        if (url != null) {
          launch(url);
        } else {
          Utils.toast("错误 地址为空");
        }
        break;
      case MenuChapter.open_chapter_url:
        final rule = await Global.ruleDao.findRuleById(searchItem.originTag);
        final url = searchItem.chapterUrl ?? Utils.getUrl(rule.host, searchItem.url);
        if (url != null) {
          launch(url);
        } else {
          Utils.toast("错误 地址为空");
        }
        break;
      case MenuChapter.share:
        // await FlutterShare.share(
        //   title: '亦搜 eso',
        //   text: '${searchItem.name}\n${searchItem.description}\n${searchItem.chapterUrl}',
        //   chooserTitle: '选择分享的应用',
        // );
        Share.share(
            '${searchItem.name.trim()}\n${searchItem.author.trim()}\n\n${searchItem.description}\n${searchItem.chapterUrl}');
        break;
      default:
        Utils.toast("该选项功能未实现${value}");
    }
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
      // await SearchItemManager.saveSearchItem();
      await searchItem.save();
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
