import 'dart:io';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/global.dart';
import 'package:eso/page/audio_page.dart';
import 'package:eso/page/manga_page.dart';
import 'package:eso/page/video_page_desktop.dart';
// import 'package:eso/page/rss_page.dart';
import 'package:eso/page/video_page_refactor.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:eso/utils/memory_cache.dart';
// import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'audio_page_refactor.dart';
import 'novel_more_page.dart';
import 'novel_page_refactor.dart';

class ContentPageRoute {
  MaterialPageRoute route(SearchItem searchItem) {
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    return MaterialPageRoute(
      builder: (context) {
        return ChangeNotifierProvider<ContentProvider>(
          create: (context) => ContentProvider(searchItem),
          builder: (context, child) {
            final provider = Provider.of<ContentProvider>(context);
            if (provider.showInfo) {
              return Material(
                child: SingleChildScrollView(
                  child: SelectableText(provider.info),
                ),
              );
            }
            switch (searchItem.ruleContentType) {
              case API.NOVEL:
                return NovelPage(searchItem: searchItem);
              case API.MANGA:
                return MangaPage(searchItem: searchItem);
              case API.NOVELMORE:
                return NovelMorePage(searchItem: searchItem);
              // case API.RSS:
              //   return RSSPage(searchItem: searchItem);
              case API.VIDEO:
                if (Global.isDesktop) return VideoPageDesktop(searchItem: searchItem);
                return VideoPage(searchItem: searchItem);
              case API.AUDIO:
                return AudioPage(searchItem: searchItem);
              default:
                throw ('${searchItem.ruleContentType} not support !');
            }
          },
        );
      },
    );
  }
}

/// 通用
class ContentProvider with ChangeNotifier {
  final SearchItem searchItem;

  String _info;
  String get info => _info;
  bool _showInfo;
  bool get showInfo => _showInfo != false;

  CacheUtil _cache;
  CacheUtil get cache => _cache;
  bool _canUseCache;
  bool get canUseCache => _canUseCache == true;

  final MemoryCache<int, List<String>> _memoryCache;

  ContentProvider(this.searchItem) : _memoryCache = MemoryCache(cacheSize: 30) {
    _info = "";
    _addInfo("获取书籍信息 (内容可复制)");
    init();
  }

  final _format = DateFormat("HH:mm:ss");
  _addInfo(String s) {
    _info += "\n[${_format.format(DateTime.now())}] $s";
    notifyListeners();
  }

  Future<void> init() async {
    try {
      if (searchItem.chapters == null || searchItem.chapters.isEmpty) {
        _addInfo("目录为空 重新获取目录");
        // if (SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
        //   searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
        // } else {
        searchItem.chapters =
            await APIManager.getChapter(searchItem.originTag, searchItem.url);
        // }
        _addInfo("结束 得到${searchItem.chapters.length}个章节");
      }
      _cache = CacheUtil(basePath: "cache${Platform.pathSeparator}${searchItem.id}");
      _canUseCache = await CacheUtil.requestPermission();
      if (_canUseCache != true) _addInfo("权限检查失败 本地缓存需要存储权限");
      _showInfo = false;
      notifyListeners();
    } catch (e, st) {
      _addInfo(e);
      _addInfo("$st");
    }
  }

  Future<void> retryUseCache() async {
    _cache = CacheUtil(basePath: "cache${Platform.pathSeparator}${searchItem.id}");
    _canUseCache = await CacheUtil.requestPermission();
  }

  Future<List<String>> refresh() {
    return loadChapter(searchItem.durChapterIndex, false, false);
  }

  Future<List<String>> loadChapter(int chapterIndex,
      [bool useCache = true, bool loadNext = true, bool shouldChangeIndex = true]) {
    final r = _memoryCache.getValueOrSet(chapterIndex, () async {
      if (useCache) {
        if (canUseCache) {
          final resp = await _cache.getData('$chapterIndex.txt',
              hashCodeKey: false, shouldDecode: false);
          if (resp != null && resp is String && resp.isNotEmpty) {
            return resp.split("\n");
          }
        } else {
          await retryUseCache();
        }
      }
      final chapter = searchItem.chapters[chapterIndex];
      final content = await APIManager.getContent(searchItem.originTag, chapter.url);
      chapter.contentUrl = API.contentUrl;
      final resp = content.join("\n").split(RegExp(r"\n\s*|\s{2,}"));
      if (canUseCache && resp.isNotEmpty) {
        await _cache.putData('$chapterIndex.txt', resp.join("\n"),
            hashCodeKey: false, shouldEncode: false);
      }
      return resp;
    });

    if (shouldChangeIndex) changeChapter(chapterIndex);

    () async {
      if (loadNext) {
        if (chapterIndex + 2 < searchItem.chapters.length &&
            !_memoryCache.containsKey(chapterIndex + 1)) {
          await Future.delayed(Duration(milliseconds: 100));
          await loadChapter(chapterIndex + 1, useCache, false, false);
        }
        if (chapterIndex + 3 < searchItem.chapters.length &&
            !_memoryCache.containsKey(chapterIndex + 2)) {
          await Future.delayed(Duration(milliseconds: 100));
          await loadChapter(chapterIndex + 2, useCache, false, false);
        }
      }
    }();

    return r;
  }

  void changeChapter(int index) async {
    // if (searchItem.durChapterIndex != index) {
    //   searchItem.durChapterIndex = index;
    //   searchItem.durChapter = searchItem.chapters[index].name;
    //   searchItem.durContentIndex = 1;
    //   await searchItem.save();
    // }
    await HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
  }
}
