import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/audio_service_handler.dart';
// import 'package:eso/model/audio_service.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:audioplayers/audioplayers.dart';

import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:just_audio/just_audio.dart';

import 'package:share_plus/share_plus.dart';

enum meidaRepeatMode {
  REPEAT_FAVORITE,
  REPEAT_ALL,
  REPEAT_ONE,
  REPEAT_NONE,
}

class AudioPageController with ChangeNotifier, WidgetsBindingObserver {
  Timer _timer;
  AudioPlayerHandler _audioHandler = MyAudioService.audioHandler;
  AudioPlayerHandler get audioHandler => _audioHandler;
  bool get isPlay => audioHandler.playing;

  Duration get positionDuration => _audioHandler.position;
  int get seconds => _audioHandler.duration.inSeconds;
  int get postionSeconds => _audioHandler.position.inSeconds;
  Duration get duration => _audioHandler.duration;

  String get durationText => _getTimeString(seconds);
  String get positionDurationText => _getTimeString(postionSeconds);

  meidaRepeatMode get repeatMode => _audioHandler.repeatMode;
  PlaybackState get state => _audioHandler.playbackState.value;

  String get url => audioHandler.playUrl;
  int get durChapterIndex => audioHandler.durChapterIndex;
  SearchItem get searchItem => audioHandler.searchItem;

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   switch (state) {
  //     case AppLifecycleState.paused:
  //       SystemChrome.restoreSystemUIOverlays();
  //       break;
  //     case AppLifecycleState.resumed:
  //       SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //         statusBarColor: Colors.black,
  //       ));
  //       break;
  //     default:
  //   }
  // }

  LyricsModelBuilder get lyricModel => audioHandler.lyricModel;

  bool _showChapter;
  bool get showChapter => _showChapter;
  set showChapter(bool value) {
    if (_showChapter != value) {
      _showChapter = value;
      notifyListeners();
    }
  }

  // List<Lyric> get lyrics => _audioService?.lyrics;
  bool _showLyric;
  bool get showLyric => _showLyric;
  void toggleLyric() {
    _showLyric = !_showLyric;
    notifyListeners();
  }

  AudioPageController({@required SearchItem searchItem}) {
    // init
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    print("SystemChrome");
    print("AudioPageController:init");
    // _lyricModel = LyricsModelBuilder.create();
    // _repeatMode = meidaRepeatMode.REPEAT_ALL;
    // _searchItem = searchItem;
    audioHandler.playMain = true;

    _showLyric = false;
    _showChapter = false;
    _timer = Timer.periodic(Duration(milliseconds: 200), (_) {
      notifyListeners();
    });
    // searchItem
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    try {
      playChapter(searchItem.durChapterIndex, searchItem: searchItem);
    } catch (e) {
      print("e:${e}");
    }
  }

  Future<void> replay() async {
    await audioHandler.replay();
  }

  Future<void> playChapter(int chapterIndex,
      {SearchItem searchItem, bool tryNext = false}) async {
    audioHandler.readySongUrl(chapterIndex, searchItem, tryNext);
  }

  void share() async {
    Share.share("${searchItem.durChapter}\n${url}");
  }

  /// all -> all secends
  String _getTimeString(int all) {
    return Utils.formatDuration(Duration(seconds: all));
  }

  void loadChapter(int index) {
    _showChapter = false;
    notifyListeners();
    playChapter(index);
  }

  void update() {
    notifyListeners();
  }

  @override
  void dispose() async {
    // if (_audioService.playerState != PlayerState.playing) {
    //   _audioService.dispose();
    // }
    //_player.dispose();

    audioHandler.close = !audioHandler.playing;

    audioHandler.playMain = false;
    print("close:${audioHandler.close},${audioHandler.playing}");

    _timer?.cancel();
    super.dispose();
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;
  final bool showSeek;

  const SeekBar(
      {Key key,
      @required this.duration,
      @required this.position,
      @required this.bufferedPosition,
      this.onChanged,
      this.onChangeEnd,
      this.showSeek = true})
      : super(key: key);

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double _dragValue;
  SliderThemeData _sliderThemeData;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.showSeek
            ? Positioned(
                left: 20.0,
                bottom: 0.0,
                child: Text(
                    RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                            .firstMatch("$_position")
                            ?.group(1) ??
                        '$_position',
                    style: TextStyle(color: Colors.white)),
              )
            : Container(),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            activeTrackColor: Colors.blue.shade100,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
                  widget.duration.inMilliseconds.toDouble()),
              onChanged: (value) {
                setState(() {
                  _dragValue = value;
                });
                if (widget.onChanged != null) {
                  widget.onChanged(Duration(milliseconds: value.round()));
                }
              },
              onChangeEnd: (value) {
                if (widget.onChangeEnd != null) {
                  widget.onChangeEnd(Duration(milliseconds: value.round()));
                }
                _dragValue = null;
              },
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.transparent,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
                widget.duration.inMilliseconds.toDouble()),
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
              if (widget.onChanged != null) {
                widget.onChanged(Duration(milliseconds: value.round()));
              }
            },
            onChangeEnd: (value) {
              if (widget.onChangeEnd != null) {
                widget.onChangeEnd(Duration(milliseconds: value.round()));
              }
              _dragValue = null;
            },
          ),
        ),
        widget.showSeek
            ? Positioned(
                right: 20.0,
                bottom: 0.0,
                child: Text(
                    RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                            .firstMatch("$_duration")
                            ?.group(1) ??
                        '$_duration',
                    style: TextStyle(color: Colors.white)),
              )
            : Container(),
      ],
    );
  }

  Duration get _duration => widget.duration;

  Duration get _position => widget.position;
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    @required Animation<double> activationAnimation,
    @required Animation<double> enableAnimation,
    @required bool isDiscrete,
    @required TextPainter labelPainter,
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required TextDirection textDirection,
    @required double value,
    @required double textScaleFactor,
    @required Size sizeWithOverflow,
  }) {}
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

String getRepeatName(meidaRepeatMode value) {
  switch (value) {
    case meidaRepeatMode.REPEAT_FAVORITE:
      return "跨源循环";
    case meidaRepeatMode.REPEAT_ALL:
      return "列表循环";
    case meidaRepeatMode.REPEAT_ONE:
      return "单曲循环";
    case meidaRepeatMode.REPEAT_NONE:
      return "不循环";
  }
  return null;
}
