// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';

// import 'package:eso/api/api_manager.dart';
// import 'package:eso/database/chapter_item.dart';
// import 'package:eso/database/history_item_manager.dart';
// import 'package:eso/database/search_item.dart';
// import 'package:eso/database/search_item_manager.dart';
// // import 'package:eso/model/audio_service.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:eso/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// // import 'package:audioplayers/audioplayers.dart';
// import 'package:just_audio_background/just_audio_background.dart';

// import 'package:flutter_lyric/lyrics_reader.dart';

// import 'package:share_plus/share_plus.dart';

// enum meidaRepeatMode {
//   REPEAT_FAVORITE,
//   REPEAT_ALL,
//   REPEAT_ONE,
//   REPEAT_NONE,
// }

// class MyAudioPlayer with ChangeNotifier {
//   static AudioPlayer _player = AudioPlayer();
//   static AudioPlayer get player => _player;
//   static SearchItem _searchItem;
//   static SearchItem get searchItem => _searchItem;
//   static String get durChapter => _searchItem.durChapter;
// }

// class AudioPageController with ChangeNotifier {
//   Timer _timer;
//   bool get isPlay => MyAudioPlayer._player.playing;
//   Duration get positionDuration => MyAudioPlayer._player.position;
//   int get seconds => MyAudioPlayer._player.duration.inSeconds;
//   int get postionSeconds => MyAudioPlayer._player.position.inSeconds;
//   Duration get duration => MyAudioPlayer._player.duration;
//   double _playspeed = 1.0;
//   double get playSpeed => _playspeed;
//   String get durationText => _getTimeString(seconds);
//   String get positionDurationText => _getTimeString(postionSeconds);
//   meidaRepeatMode _repeatMode = meidaRepeatMode.REPEAT_NONE;
//   meidaRepeatMode get repeatMode => _repeatMode;

//   PlayerState get state => MyAudioPlayer._player.playerState;
//   Duration _duration_stopPlay = Duration.zero;
//   Duration get timerStop => _duration_stopPlay;

//   String _url;
//   String get url => _url;
//   int _durChapterIndex = -1;
//   SearchItem _searchItem;

//   void setStopDuration(Duration dur) {
//     _duration_stopPlay = dur;
    

//     // _audioService.setTimingstopPlay(dur);
//   }

//   LyricsModelBuilder _lyricModel;
//   LyricsModelBuilder get lyricModel => _lyricModel;

//   bool _showChapter;
//   bool get showChapter => _showChapter;
//   set showChapter(bool value) {
//     if (_showChapter != value) {
//       _showChapter = value;
//       notifyListeners();
//     }
//   }

//   // List<Lyric> get lyrics => _audioService?.lyrics;
//   bool _showLyric;
//   bool get showLyric => _showLyric;
//   void toggleLyric() {
//     _showLyric = !_showLyric;
//     notifyListeners();
//   }

//   AudioPageController({@required SearchItem searchItem}) {
//     // init

//     print("AudioPageController:init");
//     _init();
//     _lyricModel = LyricsModelBuilder.create();
//     _repeatMode = meidaRepeatMode.REPEAT_ALL;
//     _searchItem = searchItem;

//     _showLyric = false;
//     _showChapter = false;
//     _timer = Timer.periodic(Duration(milliseconds: 200), (_) {
//       notifyListeners();
//     });
//     // searchItem
//     if (searchItem.chapters?.length == 0 &&
//         SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
//       searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
//     }

//     playChapter(searchItem.durChapterIndex, searchItem: searchItem);
//   }
//   Future<void> _init() async {
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.speech());
//     // Listen to errors during playback.

//     MyAudioPlayer._player?.processingStateStream?.listen((ProcessingState ps) {
//       print("ps:${ps}");
//       if (ps == ProcessingState.completed) {
//         // switch (_repeatMode) {
//         //   case meidaRepeatMode.REPEAT_FAVORITE:
//         //     playNext(true);
//         //     break;
//         //   case meidaRepeatMode.REPEAT_ALL:
//         //     playNext();
//         //     break;
//         //   case meidaRepeatMode.REPEAT_ONE:
//         //     replay();
//         //     break;
//         //   default:
//         //     break;
//         // }
//       }
//     });
//   }

//   Future<void> replay() async {
//     await MyAudioPlayer._player.pause();
//     await MyAudioPlayer._player.seek(Duration.zero);
//     return await MyAudioPlayer._player.play();
//   }

//   Future<void> playChapter(int chapterIndex,
//       {SearchItem searchItem, bool tryNext = false}) async {
//     print("playChapter");
//     if (searchItem == null) {
//       if (chapterIndex < 0 || chapterIndex >= _searchItem.chapters.length)
//         return;
//       if (_url != null && _searchItem.durChapterIndex == chapterIndex) {
//         replay();
//         return;
//       }
//     } else if (_searchItem == null ||
//         (_searchItem.chapterUrl != searchItem.chapterUrl)) {
//       print("_searchItem != searchItem");
//       _searchItem = searchItem;
//     } else if (_durChapterIndex == chapterIndex) {
//       print(
//           "if _durChapterIndex:${_durChapterIndex} == chapterIndex:${chapterIndex}");

//       play();
//       return;
//     }

//     try {
//       print("_player.pause();");
//       MyAudioPlayer._player.pause();
//       await MyAudioPlayer._player.seek(Duration.zero);
//     } catch (e) {}
//     MyAudioPlayer._player.stop();
//     _durChapterIndex = chapterIndex;
//     print(
//         "_durChapterIndex:${_durChapterIndex} == chapterIndex:${chapterIndex}");

//     if (_searchItem.chapters == null || _searchItem.chapters.isEmpty) return;
//     final content = await APIManager.getContent(
//         _searchItem.originTag, _searchItem.chapters[chapterIndex].url);
//     if (content == null || content.length == 0) return;
//     _url = content[0];
//     _lyricModel?.reset();

//     print("content:${content}");

//     for (final c in content.skip(1)) {
//       if (c.startsWith('@cover')) {
//         _searchItem.chapters[chapterIndex].cover = c.substring(6);
//       }
//       if (c.startsWith('@lrc')) {
//         _lyricModel = _lyricModel.bindLyricToMain(c.substring(4));
//       }
//     }
//     if (_searchItem.chapters[chapterIndex].cover.isEmpty) {
//       _searchItem.chapters[chapterIndex].cover = _searchItem.cover;
//     }
//     print("cover:${_searchItem.chapters[chapterIndex].cover}");

//     _searchItem.durChapterIndex = chapterIndex;
//     _searchItem.durChapter = _searchItem.chapters[chapterIndex].name;
//     _searchItem.durContentIndex = 1;
//     _searchItem.lastReadTime = DateTime.now().millisecondsSinceEpoch;
//     await SearchItemManager.saveSearchItem();
//     HistoryItemManager.insertOrUpdateHistoryItem(searchItem ?? _searchItem);
//     await HistoryItemManager.saveHistoryItem();
//     print(_url);
//     try {
//       if (_url.contains("@headers")) {
//         final u = _url.split("@headers");
//         final h = (jsonDecode(u[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
//         print("url:${u[0]},headers:${h}");
//         String coverUrl = _searchItem.chapters[chapterIndex].cover;
//         Map<String, String> coverHeaders = {};

//         if (_searchItem.chapters[chapterIndex].cover.contains("@headers")) {
//           final cu = _searchItem.chapters[chapterIndex].cover.split("@headers");
//           final ch =
//               (jsonDecode(cu[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
//           coverUrl = cu[0];
//           coverHeaders = ch;
//         }
//         print("coverUrl:${coverUrl},coverHeaders:${coverHeaders}");

//         await MyAudioPlayer._player.setAudioSource(
//           AudioSource.uri(
//             Uri.parse(u[0]),
//             headers: h,
//             tag: MediaItem(
//               id: u[0],
//               album: _searchItem.chapter,
//               title: _searchItem.durChapter,
//               artUri: Uri.parse(coverUrl),
//               artHeaders: coverHeaders,
//             ),
//           ),
//         );
//       } else {
//         await MyAudioPlayer._player
//             .setAudioSource(AudioSource.uri(Uri.parse(_url)));
//       }

//       await MyAudioPlayer._player.setSpeed(_playspeed);
//       //_player.load();
//       await MyAudioPlayer._player.play();
//     } catch (e) {
//       print(e);
//       if (tryNext == true) {
//         await Utils.sleep(3000);
//         if (isPlay) playNext();
//       }
//     }
//   }

//   void share() async {
//     Share.share("${_searchItem.durChapter}\n${url}");
//     // await FlutterShare.share(
//     //   title: '亦搜 eso',
//     //   text: '${_audioService.durChapter}\n${_audioService.url}',
//     //   //linkUrl: '${content?.first ?? ''}',
//     //   chooserTitle: '选择分享的应用',
//     // );
//   }

//   /// all -> all secends
//   String _getTimeString(int all) {
//     return Utils.formatDuration(Duration(seconds: all));
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

//   void loadChapter(int index) {
//     _showChapter = false;
//     notifyListeners();
//     playChapter(index);
//   }

//   Future<void> play() async {
//     switch (MyAudioPlayer._player.processingState) {
//       case ProcessingState.completed:
//         return replay();
//         break;
//       // case PlayerState.PAUSED:
//       //   return _player.resume();
//       default:
//         return await MyAudioPlayer._player.play();
//     }
//   }

//   Future<void> playOrPause() async {
//     if (isPlay) {
//       return MyAudioPlayer._player.pause();
//     } else {
//       return play();
//     }
//   }

//   void setSpeed(double speed) async {
//     if (isPlay) {
//       try {
//         await MyAudioPlayer._player.setSpeed(speed);
//         // _playspeed = speed;
//       } catch (e) {}
//     }
//   }

//   void replay10s() async {
//     if (isPlay) {
//       await MyAudioPlayer._player
//           .seek(Duration(seconds: positionDuration.inSeconds - 10));
//     }
//   }

//   void forward10s() async {
//     if (isPlay) {
//       //print("_positionDuration.inSeconds:${_positionDuration.inSeconds}");
//       await MyAudioPlayer._player
//           .seek(Duration(seconds: positionDuration.inSeconds + 10));
//     }
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

//   void update() {
//     notifyListeners();
//   }

//   void seekSeconds(int seconds) async {
//     await seekDuration(Duration(seconds: seconds));
//     notifyListeners();
//   }

//   void seekDuration(Duration dur) async {
//     print("${dur}");
//     await MyAudioPlayer._player.seek(dur);

//     notifyListeners();
//   }

//   @override
//   void dispose() async {
//     // if (_audioService.playerState != PlayerState.playing) {
//     //   _audioService.dispose();
//     // }
//     //_player.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }
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
//               RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
//                       .firstMatch("$_remaining")
//                       ?.group(1) ??
//                   '$_remaining',
//               style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }

//   Duration get _remaining => widget.duration - widget.position;
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
