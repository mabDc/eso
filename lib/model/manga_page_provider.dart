// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:eso/api/api_manager.dart';
// import 'package:eso/database/history_item_manager.dart';
// import 'package:eso/database/search_item_manager.dart';
// import 'package:eso/profile.dart';
// import 'package:flutter/services.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:device_display_brightness/device_display_brightness.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
// import '../database/search_item.dart';
// import 'package:flutter/material.dart';

// class MangaPageProvider with ChangeNotifier {
//   final _format = intl.DateFormat('HH:mm:ss');
//   Timer _timer;
//   final SearchItem searchItem;
//   List<String> _content;
//   List<String> get content => _content;
//   bool _isLoading;
//   bool get isLoading => _isLoading;
//   Map<String, String> _headers;
//   Map<String, String> get headers => _headers;
//   String _bottomTime;
//   String get bottomTime => _bottomTime;
//   bool _showChapter;
//   bool get showChapter => _showChapter;

//   ItemScrollController _mangaScroller;
//   ItemScrollController get mangaScroller => _mangaScroller;
//   ItemPositionsListener _mangaPositionsListener;
//   ItemPositionsListener get mangaPositionsListener => _mangaPositionsListener;

//   set showChapter(bool value) {
//     if (_showChapter != value) {
//       _showChapter = value;
//       notifyListeners();
//     }
//   }

//   bool _showMenu;
//   bool get showMenu => _showMenu;
//   set showMenu(bool value) {
//     if (_showMenu != value) {
//       _showMenu = value;
//       notifyListeners();
//     }
//   }

//   bool _showSetting;
//   bool get showSetting => _showSetting;
//   set showSetting(bool value) {
//     if (_showSetting != value) {
//       _showSetting = value;
//       notifyListeners();
//     }
//   }

//   double _brightness;
//   double get brightness => _brightness;
//   set brightness(double value) {
//     if ((value - _brightness).abs() > 0.005) {
//       _brightness = value;
//       DeviceDisplayBrightness.setBrightness(brightness);
//     }
//   }

//   bool keepOn;
//   void setKeepOn(bool value) {
//     if (value != keepOn) {
//       keepOn = value;
//       // ScreenBrightness().keepOn(keepOn);
//     }
//   }

//   bool landscape;
//   void setLandscape(bool value) {
//     if (value != landscape) {
//       landscape = value;
//       if (landscape) {
//         SystemChrome.setPreferredOrientations([
//           DeviceOrientation.landscapeRight,
//           DeviceOrientation.landscapeLeft,
//         ]);
//       } else {
//         SystemChrome.setPreferredOrientations([
//           DeviceOrientation.portraitUp,
//           DeviceOrientation.portraitDown,
//         ]);
//       }
//     }
//   }

//   int direction;
//   void setDirection(int value) {
//     if (value != direction) {
//       direction = value;
//       notifyListeners();
//     }
//   }

//   void syncContentIndex() {
//     final index = _mangaPositionsListener.itemPositions.value.first.index;
//     if (index == 0) {
//     } else if (searchItem.durContentIndex != index) {
//       searchItem.durContentIndex = index;
//       notifyListeners();
//     }
//   }

//   MangaPageProvider({
//     this.searchItem,
//     this.keepOn = false,
//     this.landscape = false,
//     this.direction = Profile.mangaDirectionTopToBottom,
//   }) {
//     _mangaScroller = ItemScrollController();
//     _mangaPositionsListener = ItemPositionsListener.create();
//     _mangaPositionsListener.itemPositions.addListener(syncContentIndex);
//     _brightness = 0.5;
//     _bottomTime = _format.format(DateTime.now());
//     _isLoading = false;
//     _showChapter = false;
//     _showMenu = false;
//     _showSetting = false;
//     _headers = Map<String, String>();
//     if (searchItem.chapters?.length == 0 &&
//         SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
//       searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
//     }
//     _initContent();
//   }

//   void _initContent() async {
//     if (Platform.isAndroid || Platform.isIOS) {
//       _brightness = await DeviceDisplayBrightness.getBrightness();
//       if (_brightness > 1) {
//         _brightness = 0.5;
//       }
//       DeviceDisplayBrightness.keepOn(enabled: keepOn);
//     }
//     if (landscape) {
//       SystemChrome.setPreferredOrientations([
//         DeviceOrientation.landscapeRight,
//         DeviceOrientation.landscapeLeft,
//       ]);
//     } else {
//       SystemChrome.setPreferredOrientations([
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//       ]);
//     }
//     await freshContentWithCache();
//     notifyListeners();
//   }

//   void _setHeaders() {
//     if (_content.length == 0) return;
//     final first = _content[0].split('@headers');
//     if (first.length == 1) return;
//     _headers = (jsonDecode(first[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
//     for (var i = 0; i < _content.length; i++) {
//       _content[i] = _content[i].split('@headers')[0];
//     }
//   }

//   Map<int, List<String>> _cache;
//   Future<bool> freshContentWithCache() async {
//     final index = searchItem.durChapterIndex;

//     /// 检查当前章节
//     if (_cache == null) {
//       _cache = {
//         index: await APIManager.getContent(
//           searchItem.originTag,
//           searchItem.chapters[index].url,
//         ),
//       };
//     } else if (_cache[index] == null) {
//       _cache[index] = await APIManager.getContent(
//         searchItem.originTag,
//         searchItem.chapters[index].url,
//       );
//     }
//     _content = _cache[index];
//     _setHeaders();

//     /// 缓存下一个章节
//     if (index < searchItem.chapters.length - 1 && _cache[index + 1] == null) {
//       Future.delayed(Duration(milliseconds: 100), () async {
//         if (_cache[index + 1] == null) {
//           _cache[index + 1] = await APIManager.getContent(
//             searchItem.originTag,
//             searchItem.chapters[index + 1].url,
//           );
//         }
//       });
//     }
//     return true;
//   }

//   void share() async {
//     // await FlutterShare.share(
//     //   title: '亦搜 eso',
//     //   text:
//     //       '${searchItem.name.trim()}\n${searchItem.author.trim()}\n\n${searchItem.description.trim()}\n\n${searchItem.url}',
//     //   //linkUrl: '${searchItem.url}',
//     //   chooserTitle: '选择分享的应用',
//     // );
//     Share.share(
//         '${searchItem.name.trim()}\n${searchItem.author.trim()}\n\n${searchItem.description.trim()}\n\n${searchItem.chapterUrl}');
//   }

//   bool _hideLoading = false;
//   Future<void> loadChapterHideLoading(bool lastChapter) async {
//     _showChapter = false;
//     if (isLoading || _hideLoading) return;
//     final loadIndex =
//         lastChapter ? searchItem.durChapterIndex - 1 : searchItem.durChapterIndex + 1;
//     if (loadIndex < 0 || loadIndex >= searchItem.chapters.length) return;
//     _hideLoading = true;
//     searchItem.durChapterIndex = loadIndex;
//     await freshContentWithCache();
//     searchItem.durChapter = searchItem.chapters[loadIndex].name;
//     searchItem.durContentIndex = 1;
//     searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
//     await SearchItemManager.saveSearchItem();
//     HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
//     await HistoryItemManager.saveHistoryItem();
//     _hideLoading = false;
//     // if (searchItem.ruleContentType != API.RSS) {
//     //   _controller.jumpTo(1);
//     // }
//     mangaScroller.jumpTo(index: 1);
//     notifyListeners();
//   }

//   Future<void> loadChapter(int chapterIndex) async {
//     _showChapter = false;
//     if (isLoading ||
//         chapterIndex == searchItem.durChapterIndex ||
//         chapterIndex < 0 ||
//         chapterIndex >= searchItem.chapters.length) return;
//     _isLoading = true;
//     searchItem.durChapterIndex = chapterIndex;
//     notifyListeners();
//     await freshContentWithCache();
//     searchItem.durChapter = searchItem.chapters[chapterIndex].name;
//     searchItem.durContentIndex = 1;
//     searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
//     await SearchItemManager.saveSearchItem();
//     HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
//     await HistoryItemManager.saveHistoryItem();
//     _isLoading = false;
//     // if (searchItem.ruleContentType != API.RSS) {
//     //   _controller.jumpTo(1);
//     // }
//     notifyListeners();
//   }

//   bool get isFavorite =>
//       SearchItemManager.isFavorite(searchItem.originTag, searchItem.url);

//   Future<bool> addToFavorite() async {
//     if (isFavorite) return null;
//     return await SearchItemManager.addSearchItem(searchItem);
//   }

//   Future<bool> removeFormFavorite() async {
//     if (!isFavorite) return true;
//     return await SearchItemManager.removeSearchItem(searchItem.id);
//   }

//   void refreshCurrent() async {
//     if (isLoading) return;
//     _isLoading = true;
//     _showChapter = false;
//     notifyListeners();
//     _content = await APIManager.getContent(
//         searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
//     searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
//     _isLoading = false;
//     notifyListeners();
//   }

//   void clearCurrent() async {
//     _cache?.clear();
//     // if (isLoading) return;
//     // _isLoading = true;
//     // _isLoading = false;
//   }

//   @override
//   void dispose() {
//     if (Platform.isAndroid || Platform.isIOS) {
//       DeviceDisplayBrightness.resetBrightness();
//       DeviceDisplayBrightness.keepOn(enabled: false);
//     }
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeRight,
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.portraitUp,
//       DeviceOrientation.portraitDown,
//     ]);
//     _timer?.cancel();
//     content.clear();
//     // _controller.dispose();
//     () async {
//       searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
//       _cache.clear();
//       await SearchItemManager.saveSearchItem();
//       HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
//       await HistoryItemManager.saveHistoryItem();
//     }();
//     super.dispose();
//   }
// }
