import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:eso/api/api.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item_manager.dart';

import '../database/search_item.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPageController with ChangeNotifier {
  // const
  final SearchItem searchItem;
  // private
  VideoPlayerController _videoPlayerController;
  // public get
  int _progress;
  int get progress => _progress;
  List<String> _content;
  List<String> get content => _content;
  ChewieController _controller;
  ChewieController get controller => _controller;
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

  VideoPageController({this.searchItem}) {
    _isLoading = false;
    _showChapter = false;
    _progress = 0;
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _initContent();
  }

  void _initContent() async {
    _content = await APIManager.getContent(searchItem.originTag,
        searchItem.chapters[searchItem.durChapterIndex].url);
    _setControl();
    notifyListeners();
  }

  void _setControl() async {
    _controller?.dispose();
    final cacheControl = _videoPlayerController;
    _videoPlayerController = VideoPlayerController.network(_content[0]);
    _controller = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: false,
      startAt: Duration(milliseconds: searchItem.durContentIndex),
    );
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 100));
    cacheControl?.dispose();
  }

  void refreshProgress() {}

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
    await SearchItemManager.saveSearchItem();
    _setControl();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() async {
    _videoPlayerController.pause();
    searchItem.durContentIndex =
        (await _videoPlayerController.position).inMilliseconds;
    SearchItemManager.saveSearchItem();
    content.clear();
    _controller.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }
}
