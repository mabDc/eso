import 'dart:async';

import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/audio_service.dart';
import 'package:flutter/services.dart';
// import 'package:wakelock/wakelock.dart';

import '../database/search_item.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:dlna/dlna.dart';
import 'package:eso/utils/dlna_util.dart';
import 'package:wakelock/wakelock.dart';

class VideoPageController with ChangeNotifier {
  // const
  final SearchItem searchItem;

  // private
  bool _horizontal;
  VideoPlayerController _audioController;
  Timer _timer;
  int _lastShowTime;
  int _lastToastTime;

  // public get
  List<String> _content;
  List<String> get content => _content;

  VideoPlayerController _controller;
  VideoPlayerController get controller => _controller;

  double get aspectRatio => _controller.value.aspectRatio;

  int get seconds => _controller.value.duration.inSeconds;
  int get positionSeconds => _controller.value.position.inSeconds;

  int get milliseconds => _controller.value.duration.inMilliseconds;
  int get positionMilliseconds => _controller.value.position.inMilliseconds;

  String get duration => getTimeString(seconds);
  String get positionDuration => getTimeString(positionSeconds);

  String _toastText;
  String get toastText => _toastText;

  bool get isPlaying => _controller.value.isPlaying;

  bool _isLoading;
  bool get isLoading => _isLoading;

  bool _isParsing;
  bool get isParsing => _isParsing;

  bool _showToast;
  bool get showToast => _showToast;

  bool _showController;
  bool get showController => _showController;
  bool _parseFailure;
  bool get parseFailure => _parseFailure;

  set showController(bool value) {
    refreshLastTime();
    if (_showChapter) {
      _showChapter = false;
      notifyListeners();
    } else if (value != _showController) {
      _showController = value;
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

  double initial;
  int panSeconds;

  VideoPageController({this.searchItem}) {
    _horizontal = true;
    // Wakelock.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _isLoading = false;
    _isParsing = false;
    _parseFailure = false;
    _showChapter = false;
    initial = 0;
    panSeconds = 0;
    _showController = true;
    _showChapter = false;
    _showToast = false;
    _toastText = '';
    refreshLastTime();
    refreshToastTime();
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _initContent();
  }

  void _initContent() async {
    _content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
    await _setControl();
  }

  Future<void> _setControl() async {
    if (_content == null || _content.length == 0) {
      _parseFailure = true;
      notifyListeners();
      return;
    }
    _parseFailure = false;
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 100));
    _controller?.dispose();
    _controller = VideoPlayerController.network(_content[0]);
    await _controller.initialize();
    _audioController?.dispose();
    if (_content.length == 2 && _content[1].substring(0, 5) == 'audio') {
      _audioController = VideoPlayerController.network(_content[1].substring(5));
      await _audioController.initialize();
    }
    await seekTo(Duration(milliseconds: searchItem.durContentIndex));
    AudioService.stop();
    _controller.play();
    _syncController();
    if (_timer == null) {
      _timer = Timer.periodic(Duration(milliseconds: 300), (timer) {
        if (_showController) {
          if (DateTime.now().millisecondsSinceEpoch - _lastShowTime > 3000) {
            _showController = false;
          }
          notifyListeners();
        }
        if (_showToast) {
          if (DateTime.now().millisecondsSinceEpoch - _lastToastTime > 800) {
            _showToast = false;
          }
          notifyListeners();
        }
      });
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadChapter(int chapterIndex) async {
    _showChapter = false;
    if (_isParsing ||
        chapterIndex == searchItem.durChapterIndex ||
        chapterIndex < 0 ||
        chapterIndex >= searchItem.chapters.length) return;
    _isParsing = true;
    notifyListeners();
    _content = await APIManager.getContent(
        searchItem.originTag, searchItem.chapters[chapterIndex].url);
    searchItem.durChapterIndex = chapterIndex;
    searchItem.durChapter = searchItem.chapters[chapterIndex].name;
    searchItem.durContentIndex = 1;
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    await SearchItemManager.saveSearchItem();
    _isParsing = false;
    await _setControl();
  }

  void openWith() {
    if (_content != null && _content.length > 0) {
      launch(_content[0]);
    }
  }

  void openDLNA(BuildContext context) {
    if (_content == null || _content.isEmpty) return;
    DLNAUtil.instance.start(context,
      title: searchItem.name + ' - ' + searchItem.durChapter,
      url: _content[0],
      videoType: VideoObject.VIDEO_MP4,
      onPlay: () {
        if (isPlaying)
          playOrPause();
      }
    );
  }

  void _syncController() async {
    if (_audioController == null) return;
    do {
      await _audioController.seekTo(_controller.value.position);
      if (_controller.value.isPlaying) {
        _audioController.play();
      } else {
        _audioController.pause();
      }
      await Future.delayed(Duration(seconds: 3));
    } while (
        (_audioController.value.position.inMilliseconds - positionMilliseconds).abs() >
            200);
  }

  String getTimeString(int all) {
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

  void playOrPause() {
    if (isPlaying) {
      _controller.pause();
      _audioController?.pause();

      Wakelock.enable();
      showToastText('暂停');
    } else {
      AudioService.stop();
      _controller.play();
      _audioController?.play();

      Wakelock.disable();
      showToastText('播放');
    }
    refreshLastTime();
    _syncController();
    notifyListeners();
  }

  void refreshLastTime() => _lastShowTime = DateTime.now().millisecondsSinceEpoch;

  void refreshToastTime() => _lastToastTime = DateTime.now().millisecondsSinceEpoch;

  Future<void> seekTo(Duration duration) async {
    refreshLastTime();
    await _controller.seekTo(duration);
    _syncController();
  }

  void onPanEnd(DragEndDetails details) {
    if (panSeconds.abs() < 1) return;
    int positionSeconds = this.positionSeconds + panSeconds;
    if (positionSeconds < 0) {
      showToastText('从头播放');
      positionSeconds = 0;
    } else if (positionSeconds > this.seconds) {
      showToastText('结束');
      positionSeconds = this.seconds;
    }
    seekTo(Duration(seconds: positionSeconds));
  }

  void setVideoSpeed(double speed) {}

  void showToastText(String text) {
    _toastText = text;
    _showToast = true;
    refreshToastTime();
    notifyListeners();
  }

  void toggleRotation() {
    _horizontal = !_horizontal;
    refreshLastTime();
    if (_horizontal) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      showToastText('横向');
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      showToastText('纵向');
    }
  }

  @override
  void dispose() async {
    _timer?.cancel();
    // Wakelock.disable();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    if (_controller != null) {
      searchItem.durContentIndex = _controller.value.position.inMilliseconds;
      searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
      SearchItemManager.saveSearchItem();
    }
    content?.clear();
    await _audioController?.dispose();
    await _controller?.dispose();
    super.dispose();
  }
}
