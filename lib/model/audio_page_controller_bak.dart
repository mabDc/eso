// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'package:audio_session/audio_session.dart';
// import 'package:eso/api/api_manager.dart';
// import 'package:eso/database/history_item_manager.dart';
// import 'package:eso/database/search_item.dart';
// import 'package:eso/database/search_item_manager.dart';
// import 'package:eso/model/audio_service%20copy.dart';
// import 'package:eso/model/audio_service.dart';
// import 'package:just_audio/just_audio.dart';

// import 'package:eso/utils.dart';
// import 'package:flutter/material.dart';
// // import 'package:audioplayers/audioplayers.dart';
// // import '../lyric/lyric.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:flutter_lyric/lyrics_reader.dart';
// import 'package:win32/win32.dart';

// enum meidaRepeatMode {
//   REPEAT_FAVORITE,
//   REPEAT_ALL,
//   REPEAT_ONE,
//   REPEAT_NONE,
// }

// class AudioPageController with ChangeNotifier {
//   AudioService _audioService;
//   SearchItem _searchItem;
//   SearchItem get searchItem => _searchItem;
//   Timer _timer;
//   bool get isPlay => _audioService?.playerState?.playing;
//   Duration get positionDuration => _audioService?.positionDuration;
//   Duration get duration => _audioService?.duration;
//   Duration get bufferedPosition => _audioService?.bufferedPosition;
//   Duration _timerStop = Duration.zero;
//   Duration get timerStop => _timerStop;

//   int get seconds => _audioService?.duration?.inSeconds;

//   int get postionSeconds => _audioService?.positionDuration?.inSeconds;
//   double _playspeed = 1.0;
//   double get playSpeed => _playspeed;
//   // String get durationText => _getTimeString(seconds);
//   // String get positionDurationText => _getTimeString(postionSeconds);
//   meidaRepeatMode _repeatMode = meidaRepeatMode.REPEAT_NONE;
//   meidaRepeatMode get repeatMode => _repeatMode;
//   int _durChapterIndex = -1;

//   PlayerState get state => _audioService?.playerState;
//   String _url;
//   String get url => _url;

//   LyricsModelBuilder get lyricModel => _audioService.lyricModel;

//   bool _showChapter;
//   bool get showChapter => _showChapter;
//   set showChapter(bool value) {
//     if (_showChapter != value) {
//       _showChapter = value;
//       notifyListeners();
//     }
//   }

//   bool _showLyric;
//   bool get showLyric => _showLyric;
//   void toggleLyric() {
//     _showLyric = !_showLyric;
//     print("_showLyric:${_showLyric}");
//     notifyListeners();
//   }

//   AudioPageController({@required SearchItem searchItem}) {
//     // () async {
//     //   final session = await AudioSession.instance;
//     //   await session.configure(const AudioSessionConfiguration.speech());
//     //   print("sessionOk");
//     // }();

//     // init
//     _audioService = AudioService();

//     _repeatMode = meidaRepeatMode.REPEAT_ALL;

//     _searchItem = searchItem;

//     _showLyric = false;
//     _showChapter = false;
//     _timer = Timer.periodic(Duration(milliseconds: 200), (_) {
//       notifyListeners();
//     });

//     // _player?.processingStateStream?.listen((ProcessingState ps) {
//     //   print("ps:${ps}");
//     //   if (ps == ProcessingState.completed) {
//     //     switch (_repeatMode) {
//     //       case meidaRepeatMode.REPEAT_FAVORITE:
//     //         playNext(true);
//     //         break;
//     //       case meidaRepeatMode.REPEAT_ALL:
//     //         playNext();
//     //         break;
//     //       case meidaRepeatMode.REPEAT_ONE:
//     //         replay();
//     //         break;
//     //       default:
//     //         break;
//     //     }
//     //   }
//     // });

//     // searchItem
//     if (searchItem.chapters?.length == 0 &&
//         SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
//       searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
//     }

//     playChapter(
//       searchItem.durChapterIndex,
//       searchItem: searchItem,
//     );

//     notifyListeners();
//   }

//   void share() async {
//     Share.share("${searchItem.durChapter}\n${searchItem.url}");
//     // await FlutterShare.share(
//     //   title: '亦搜 eso',
//     //   text: '${_audioService.durChapter}\n${_audioService.url}',
//     //   //linkUrl: '${content?.first ?? ''}',
//     //   chooserTitle: '选择分享的应用',
//     // );
//   }

//   void switchRepeatMode() {
//     if (_repeatMode == meidaRepeatMode.REPEAT_FAVORITE) {
//       _repeatMode = meidaRepeatMode.REPEAT_ALL;
//     } else if (_repeatMode == meidaRepeatMode.REPEAT_ALL) {
//       _repeatMode = meidaRepeatMode.REPEAT_ONE;
//     } else if (_repeatMode == meidaRepeatMode.REPEAT_ONE) {
//       _repeatMode = meidaRepeatMode.REPEAT_NONE;
//     } else if (_repeatMode == meidaRepeatMode.REPEAT_NONE) {
//       _repeatMode = meidaRepeatMode.REPEAT_FAVORITE;
//     }
//     notifyListeners();
//   }

//   Future<void> seek(Duration dur) async {
//     return await _audioService.seek(dur);
//   }

//   Future<void> replay() async {
//     await _audioService.player.pause();
//     await _audioService.seek(Duration.zero);
//     return await _audioService.play();
//   }

//   Future<void> play() async {
//     await _audioService.play();
//   }

//   Future<void> playOrPause() async {
//     await _audioService.playOrPause();
//   }

//   void setSpeed(double speed) async {
//     await _audioService.setSpeed(speed);
//   }

//   void replay10s() async {
//     await _audioService.replay10s();
//   }

//   void forward10s() async {
//     await _audioService.forward10s();
//   }

//   void playNext([bool allFavorite = false]) {
//     if (_searchItem.durChapterIndex == (_searchItem.chapters.length - 1)) {
//       if (allFavorite != true) {
//         playChapter(0);
//       }
//     } else {
//       playChapter(_searchItem.durChapterIndex + 1);
//     }
//   }

//   void playPrev() => playChapter(_searchItem.durChapterIndex == 0
//       ? _searchItem.chapters.length - 1
//       : _searchItem.durChapterIndex - 1);

//   Future<void> playChapter(int chapterIndex,
//       {SearchItem searchItem, bool tryNext = false}) async {
//     await _audioService.playChapter(chapterIndex,
//         searchItem: searchItem, tryNext: tryNext);
//     notifyListeners();
//   }

//   void loadChapter(int index) {
//     _showChapter = false;
//     notifyListeners();
//     playChapter(index);
//   }

//   void seekSeconds(int seconds) async {
//     await seek(Duration(seconds: seconds));
//     notifyListeners();
//   }

//   void update() {
//     notifyListeners();
//   }

//   @override
//   void dispose() async {
//     print("audio_page_controller   dispose");

//     //_player?.dispose();
//     lyricModel.reset();
//     _timer?.cancel();
//     super.dispose();
//   }

//   void seekDuration(Duration duration) {
//     seek(duration);
//   }

//   void setStopDuration(Duration timeDuration) {}
// }

// class SeekBar extends StatefulWidget {
//   final Duration duration;
//   final Duration position;
//   final Duration bufferedPosition;
//   final ValueChanged<Duration> onChanged;
//   final ValueChanged<Duration> onChangeEnd;

//   const SeekBar({
//     Key key,
//     @required this.duration,
//     @required this.position,
//     @required this.bufferedPosition,
//     this.onChanged,
//     this.onChangeEnd,
//   }) : super(key: key);

//   @override
//   SeekBarState createState() => SeekBarState();
// }

// class SeekBarState extends State<SeekBar> {
//   double _dragValue;
//   SliderThemeData _sliderThemeData;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     _sliderThemeData = SliderTheme.of(context).copyWith(
//       trackHeight: 2.0,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned(
//           left: 16.0,
//           bottom: 0.0,
//           child: Text(
//             RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
//                     .firstMatch("$_positionText")
//                     ?.group(1) ??
//                 '$_positionText',
//             style: TextStyle(color: Colors.white, fontSize: 13),
//           ),
//         ),
//         SliderTheme(
//           data: _sliderThemeData.copyWith(
//             thumbShape: HiddenThumbComponentShape(),
//             activeTrackColor: Colors.blue.shade100,
//             inactiveTrackColor: Colors.grey.shade300,
//           ),
//           child: ExcludeSemantics(
//             child: Slider(
//               min: 0.0,
//               max: widget.duration.inMilliseconds.toDouble(),
//               value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
//                   widget.duration.inMilliseconds.toDouble()),
//               onChanged: (value) {
//                 setState(() {
//                   _dragValue = value;
//                 });
//                 if (widget.onChanged != null) {
//                   widget.onChanged(Duration(milliseconds: value.round()));
//                 }
//               },
//               onChangeEnd: (value) {
//                 if (widget.onChangeEnd != null) {
//                   widget.onChangeEnd(Duration(milliseconds: value.round()));
//                 }
//                 _dragValue = null;
//               },
//             ),
//           ),
//         ),
//         SliderTheme(
//           data: _sliderThemeData.copyWith(
//             inactiveTrackColor: Colors.transparent,
//             thumbColor: Colors.white,
//             activeTrackColor: Colors.deepOrange,
//           ),
//           child: Slider(
//             min: 0.0,
//             max: widget.duration.inMilliseconds.toDouble(),
//             value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
//                 widget.duration.inMilliseconds.toDouble()),
//             onChanged: (value) {
//               setState(() {
//                 _dragValue = value;
//               });
//               if (widget.onChanged != null) {
//                 widget.onChanged(Duration(milliseconds: value.round()));
//               }
//             },
//             onChangeEnd: (value) {
//               if (widget.onChangeEnd != null) {
//                 widget.onChangeEnd(Duration(milliseconds: value.round()));
//               }
//               _dragValue = null;
//             },
//           ),
//         ),
//         Positioned(
//           right: 16.0,
//           bottom: 0.0,
//           child: Text(
//             RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
//                     .firstMatch("$_durationText")
//                     ?.group(1) ??
//                 '$_durationText',
//             style: TextStyle(color: Colors.white, fontSize: 13),
//           ),
//         ),
//       ],
//     );
//   }

//   Duration get _durationText => widget.duration;
//   Duration get _positionText => widget.position;
// }

// class HiddenThumbComponentShape extends SliderComponentShape {
//   @override
//   Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

//   @override
//   void paint(
//     PaintingContext context,
//     Offset center, {
//     @required Animation<double> activationAnimation,
//     @required Animation<double> enableAnimation,
//     @required bool isDiscrete,
//     @required TextPainter labelPainter,
//     @required RenderBox parentBox,
//     @required SliderThemeData sliderTheme,
//     @required TextDirection textDirection,
//     @required double value,
//     @required double textScaleFactor,
//     @required Size sizeWithOverflow,
//   }) {}
// }

// class PositionData {
//   final Duration position;
//   final Duration bufferedPosition;
//   final Duration duration;

//   PositionData(this.position, this.bufferedPosition, this.duration);
// }

// String getRepeatName(meidaRepeatMode value) {
//   switch (value) {
//     case meidaRepeatMode.REPEAT_FAVORITE:
//       return "跨源循环";
//     case meidaRepeatMode.REPEAT_ALL:
//       return "列表循环";
//     case meidaRepeatMode.REPEAT_ONE:
//       return "单曲循环";
//     case meidaRepeatMode.REPEAT_NONE:
//       return "不循环";
//   }
//   return null;
// }
