import 'dart:async';

import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_share/flutter_share.dart';

class AudioPageController with ChangeNotifier {
  static const int REPEAT_ALL = 2;
  static const int REPEAT_ONE = 1;
  static const int REPEAT_NONE = 0;

  final SearchItem searchItem;
  final AudioPlayer player = AudioPlayer();
  // Timer _timer;
  // public get
  List<String> _content;
  List<String> get content => _content;

  bool _isLoading;
  bool get isLoading => _isLoading;
  bool _isParsing;
  bool get isParsing => _isParsing;

  AudioPlayerState _playerState;
  AudioPlayerState get playerState => _playerState;
  int _repeatMode;
  int get repeatMode => _repeatMode;

  Duration _duration;
  Duration get duration => _duration;
  String get durationText => _getTimeString(_duration.inSeconds);
  Duration _positionDuration;
  Duration get positionDuration => _positionDuration;
  String get positionDurationText =>
      _getTimeString(_positionDuration.inSeconds);

  bool _showChapter;
  bool get showChapter => _showChapter;
  set showChapter(bool value) {
    if (_showChapter != value) {
      _showChapter = value;
      notifyListeners();
    }
  }

  AudioPageController({@required this.searchItem}) {
    // init
    _isLoading = false;
    _isParsing = false;
    _showChapter = false;
    _duration = Duration.zero;
    _positionDuration = Duration.zero;
    _repeatMode = 2;
    // add listen
    player.onDurationChanged.listen((Duration d) {
      _duration = d;
      notifyListeners();
    });

    player.onAudioPositionChanged.listen((Duration p) {
      _positionDuration = p;
      notifyListeners();
    });

    player.onPlayerStateChanged.listen((AudioPlayerState s) {
      _playerState = s;
      notifyListeners();
    });

    player.onPlayerCompletion.listen((event) {
      switch (_repeatMode) {
        case REPEAT_ALL:
          playNext();
          break;
        case REPEAT_ONE:
          player.seek(Duration.zero);
          player.resume();
          break;
        default:
      }
    });
    // searchItem
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _initContent();
  }

  void _initContent() async {
    _content = await APIManager.getContent(searchItem.originTag,
        searchItem.chapters[searchItem.durChapterIndex].url);
    await _setPlayer();
  }

  Future<void> loadChapter(int chapterIndex) async {
    _showChapter = false;
    notifyListeners();
    if (_isParsing ||
        chapterIndex == searchItem.durChapterIndex ||
        chapterIndex < -1 ||
        chapterIndex > searchItem.chapters.length) return;
    if (chapterIndex == -1 || chapterIndex == searchItem.chapters.length) {
      player.seek(Duration.zero);
      player.resume();
      return;
    }
    _isParsing = true;
    notifyListeners();
    _content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[chapterIndex].url);
    searchItem.durChapterIndex = chapterIndex;
    searchItem.durChapter = searchItem.chapters[chapterIndex].name;
    searchItem.durContentIndex = 1;
    await SearchItemManager.saveSearchItem();
    await _setPlayer();
  }

  Future<void> _setPlayer() async {
    _isLoading = true;
    _isParsing = false;
    notifyListeners();
    if (_content != null && _content.length > 0) {
      int result = await player.play(_content[0]);
      if (result == 1) {}
    }
    // if (_timer == null) {
    //   _timer = Timer.periodic(Duration(milliseconds: 600), (timer) {
    //     notifyListeners();
    //   });
    // }
    _isLoading = false;
  }

  void seekTo(Duration duration) => player.seek(duration);

  void playNext() => loadChapter(searchItem.durChapterIndex + 1);

  void playPrev() => loadChapter(searchItem.durChapterIndex - 1);

  void playOrPause() {
    switch (_playerState) {
      case AudioPlayerState.PLAYING:
        player.pause();
        break;
      case AudioPlayerState.PAUSED:
        player.resume();
        break;
      case AudioPlayerState.COMPLETED:
      case AudioPlayerState.STOPPED:
        player.seek(Duration.zero);
        player.resume();
        break;
    }
  }

  void share() async {
    await FlutterShare.share(
      title: '亦搜 eso',
      text: '${searchItem.name}\n${searchItem.durChapter}\n${content.join()}',
      linkUrl: '${content?.first ?? ''}',
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
    int temp = _repeatMode + 1;
    if (temp > 2) {
      temp = 0;
    }
    _repeatMode = temp;
    notifyListeners();
  }

  @override
  void dispose() async {
    // _timer?.cancel();
    await Future.delayed(Duration(milliseconds: 100));
    player.release();
    super.dispose();
  }
}
