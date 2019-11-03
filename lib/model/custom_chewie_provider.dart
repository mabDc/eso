import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomChewieProvider with ChangeNotifier {
  VideoPlayerController controller;
  VideoPlayerController audioController;
  Timer _timer;
  int _lastShowTime;
  bool _showController;
  bool get showController => _showController;

  int get seconds => controller.value.duration.inSeconds;
  int get positionSeconds => controller.value.position.inSeconds;

  String get duration => _getTimeString(seconds);
  String get positionDuration => _getTimeString(positionSeconds);

  bool get isPlaying => controller.value.isPlaying;

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

  CustomChewieProvider({
    @required this.controller,
    @required this.audioController,
  }) {
    _showController = true;
    _showChapter = false;
    refreshLastTime();
    controller.play();
    audioController?.play();
    _syncController();
    _timer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      if (_showController) {
        if (DateTime.now().millisecondsSinceEpoch - _lastShowTime > 5000) {
          _showController = false;
        }
        notifyListeners();
      }
    });
  }

  void _syncController() async {
    if (audioController == null) return;
    int syncDuration = 100;
    if ((audioController.value.position.inMilliseconds -
                controller.value.position.inMilliseconds)
            .abs() >
        syncDuration) {
      await Future.delayed(Duration(milliseconds: syncDuration));
      do {
        _syncProgress();
        await Future.delayed(Duration(seconds: 2));
      } while ((audioController.value.position.inMilliseconds -
                  controller.value.position.inMilliseconds)
              .abs() >
          syncDuration);
      _syncProgress();
    }
  }

  void _syncProgress() {
    audioController.seekTo(controller.value.position);
    if (controller.value.isPlaying) {
      audioController.play();
    } else {
      audioController.pause();
    }
  }

  String _getTimeString(int all) {
    String s = '${_fixToTwo(all % 60)}';
    all = all ~/ 60;
    s = '${_fixToTwo(all % 60)}:$s';
    if (all >= 60) {
      all = all ~/ 60;
      s = '$all:$s';
    }
    return s;
  }

  String _fixToTwo(int i) {
    if (i > 9) {
      return '$i';
    }
    return '0$i';
  }

  void playOrpause() {
    if (isPlaying) {
      controller.pause();
      audioController?.pause();
    } else {
      controller.play();
      audioController?.play();
    }
    refreshLastTime();
    notifyListeners();
  }

  void refreshLastTime() {
    _lastShowTime = DateTime.now().millisecondsSinceEpoch;
  }

  void seekTo(int seconds) {
    controller.seekTo(Duration(seconds: seconds));
    refreshLastTime();
    _syncController();
  }

  void updateController(controller, audioController) {
    this.controller = controller;
    this.audioController = audioController;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
