import 'package:eso/api/api_manager.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:eso/database/search_item_manager.dart';
import '../database/search_item.dart';
import 'package:flutter/material.dart';

class RSSPageProvider with ChangeNotifier {
  final SearchItem searchItem;
  List<String> _content;
  List<String> get content => _content;
  bool _isLoading;
  bool get isLoading => _isLoading;
  bool _showChapter;
  bool get showChapter => _showChapter;
  set showChapter(bool value) {
    if (_showChapter != value) {
      _showChapter = value;
      notifyListeners();
    }
  }

  RSSPageProvider({this.searchItem}) {
    _isLoading = false;
    _showChapter = false;
    // if (searchItem.chapters?.length == 0 &&
    //     SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
    //   searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    // }
    _initContent();
  }

  void _initContent() async {
    _content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
    notifyListeners();
  }

  loadChapter(int chapterIndex) async {
    _showChapter = false;
    if (isLoading ||
        chapterIndex == searchItem.durChapterIndex ||
        chapterIndex < 0 ||
        chapterIndex >= searchItem.chapters.length) return;
    _isLoading = true;
    notifyListeners();
    _content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[chapterIndex].url);
    searchItem.durChapterIndex = chapterIndex;
    searchItem.durChapter = searchItem.chapters[chapterIndex].name;
    searchItem.durContentIndex = 1;
    // await SearchItemManager.saveSearchItem();
    await searchItem.save();
    HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    content.clear();
    () async {
      // await SearchItemManager.saveSearchItem();
      await searchItem.save();
      HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
    }();
    super.dispose();
  }
}
