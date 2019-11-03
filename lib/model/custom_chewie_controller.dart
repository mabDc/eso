import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CustomChewieController extends StatelessWidget {
  final VideoPlayerController controller;
  final VideoPlayerController audioController;
  final SearchItem searchItem;
  final Function(int index) loadChapter;
  CustomChewieController({
    @required this.controller,
    this.audioController,
    this.searchItem,
    this.loadChapter,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _ChewieController(
        controller: controller,
        audioController: audioController,
      ),
      child: Consumer<_ChewieController>(
        builder: (BuildContext context, _ChewieController provider, _) {
          return _buildControllers(context, provider);
        },
      ),
    );
  }

  Widget _buildControllers(BuildContext context, _ChewieController provider) {
    return GestureDetector(
      onTap: () => provider.showController = !provider.showController,
      onDoubleTap: provider.playOrpause,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              ChewieController.of(context).isFullScreen
                  ? Container()
                  : SizedBox(height: MediaQuery.of(context).padding.top),
              provider.showController
                  ? Container(
                      width: double.infinity,
                      color: Colors.black.withAlpha(30),
                      padding: EdgeInsets.all(8),
                      child: _buildTopRow(context, provider),
                    )
                  : Container(),
              Expanded(
                child: Container(
                  color: Colors.transparent,
                ),
              ),
              provider.showController
                  ? Container(
                      width: double.infinity,
                      color: Colors.black.withAlpha(30),
                      padding: EdgeInsets.all(8),
                      child: _buildBottomRow(context, provider),
                    )
                  : Container(),
            ],
          ),
          provider.showChapter
              ? UIChapterSelect(
                  loadChapter: loadChapter,
                  searchItem: searchItem,
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, _ChewieController provider) {
    return Row(
      children: <Widget>[
        InkWell(
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Text(
            '${searchItem.durChapter}'.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        ChewieController.of(context).isFullScreen
            ? Container()
            : InkWell(
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                onTap: () => provider.showChapter = !provider.showChapter,
              ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context, _ChewieController provider) {
    return Row(
      children: <Widget>[
        InkWell(
          child: Icon(
            provider.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
          ),
          onTap: provider.playOrpause,
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          child: SeekBar(
            value: provider.positionSeconds.toDouble(),
            max: provider.seconds.toDouble(),
            backgroundColor: Colors.white54,
            progresseight: 4,
            afterDragShowSectionText: true,
            onValueChanged: (value) => provider.seekTo(value.value.toInt()),
            indicatorRadius: 5,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          '${provider.positionDuration}/${provider.duration}',
          style: TextStyle(color: Colors.white),
        ),
        InkWell(
          child: Icon(
            Icons.fullscreen,
            color: Colors.white,
          ),
          onTap: ChewieController.of(context).toggleFullScreen,
        ),
      ],
    );
  }
}

class _ChewieController with ChangeNotifier {
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

  _ChewieController({
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
