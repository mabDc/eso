import 'dart:async';

import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_share/flutter_share.dart';

class AudioPageController with ChangeNotifier {
  AudioService _audioService;
  Timer _timer;
  int get seconds => _audioService.duration.inSeconds;
  int get postionSeconds => _audioService.positionDuration.inSeconds;
  String get durationText => _getTimeString(seconds);
  String get positionDurationText => _getTimeString(postionSeconds);
  int get repeatMode => _audioService.repeatMode;
  AudioPlayerState get state => _audioService.playerState;

  bool _showChapter;
  bool get showChapter => _showChapter;
  set showChapter(bool value) {
    if (_showChapter != value) {
      _showChapter = value;
      notifyListeners();
    }
  }

  AudioPageController({@required SearchItem searchItem}) {
    // init
    _audioService = AudioService();
    _showChapter = false;
    _timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      notifyListeners();
    });
    // searchItem
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _audioService.playChapter(searchItem.durChapterIndex, searchItem);
  }

  void share() async {
    await FlutterShare.share(
      title: '亦搜 eso',
      text: '${_audioService.durChapter}\n${_audioService.url}',
      //linkUrl: '${content?.first ?? ''}',
      chooserTitle: '选择分享的应用',
    );
  }

  /// all -> all secends
  String _getTimeString(int all) {
    int c = all % 60;
    String s = '${c > 9 ? '' : '0'}$c';
    all = all ~/ 60;
    c = all % 60;
    s = '${c > 9 ? '' : '0'}$c:$s';
    if (all >= 60) {
      all = all ~/ 60;
      s = '$all:$s';
    }
    return s;
  }

  void switchRepeatMode() {
    _audioService.switchRepeatMode();
    notifyListeners();
  }

  void loadChapter(int index) {
    _showChapter = false;
    notifyListeners();
    _audioService.playChapter(index);
  }

  void playPrev() {
    _audioService.playPrev();
  }

  void playOrPause() async {
    await _audioService.playOrPause();
    notifyListeners();
  }

  void playNext() {
    _audioService.playNext();
  }

  void seekSeconds(int seconds) async {
    await _audioService.seek(Duration(seconds: seconds));
    notifyListeners();
  }

  @override
  void dispose() async {
    _timer?.cancel();
    super.dispose();
  }
}
