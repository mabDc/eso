// import 'dart:convert';

// import 'package:eso/api/api_manager.dart';
// import 'package:eso/database/chapter_item.dart';
// import 'package:eso/database/history_item_manager.dart';
// import 'package:eso/database/search_item.dart';
// // import 'package:eso/database/search_item_manager.dart';
// // import 'package:eso/model/audio_page_controller.dart';
// import 'package:eso/page/content_page_manager.dart';
// import 'package:eso/utils.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:audio_service/audio_service.dart';
// import 'package:flutter_lyric/lyrics_reader.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';
// // import 'package:provider/provider.dart';

// typedef upStateCallBack = void Function();

// class MyAudioService {
//   static AudioPlayerHandler audioHandler;
//   static get isPlaying => audioHandler?.playing == true;
//   static void Init() async {
//     audioHandler = await AudioService.init<AudioPlayerHandler>(
//       builder: () => MyAudioPlayerHandler(),
//       config: const AudioServiceConfig(
//         androidNotificationChannelId: 'com.eso.channel.audio',
//         androidNotificationChannelName: '亦搜音频',
//         androidNotificationOngoing: true,
//         androidNotificationIcon: 'mipmap/eso_logo',
//       ),
//     );
//   }
//     static String getRepeatName(MeidaRepeatMode value) {
//     switch (value) {
//       case MeidaRepeatMode.REPEAT_FAVORITE:
//         return "跨源循环";
//       case MeidaRepeatMode.REPEAT_ALL:
//         return "列表循环";
//       case MeidaRepeatMode.REPEAT_ONE:
//         return "单曲循环";
//       case MeidaRepeatMode.REPEAT_NONE:
//         return "不循环";
//     }
//     return null;
//   }
// }

// enum MeidaRepeatMode {
//   REPEAT_FAVORITE,
//   REPEAT_ALL,
//   REPEAT_ONE,
//   REPEAT_NONE,
// }

// abstract class AudioPlayerHandler implements AudioHandler {
//   final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
//   Duration duration;
//   Duration position;
//   Duration timer_stopPlay;
//   bool playing;
//   bool disposePage;
//   ChapterItem curChapter;
//   int durChapterIndex;
//   String playUrl;
//   double speed;
//   bool close;
//   bool playMain;

//   SearchItem searchItem;
//   LyricsModelBuilder lyricModel;
//   MeidaRepeatMode repeatMode;
//   Stream<Duration> positionStream;
//   Stream<Duration> durationStream;
//   Stream<Duration> bufferedPositionStream;

//   Future<void> readySongUrl(int chapterIndex,
//       [SearchItem searchItem, bool tryNext = false]);
//   void playNext([bool allFavorite = false]);
//   Future<void> replay();
//   void switchRepeatMode();
//   Future<void> playOrPause();
//   void forward10s();
//   void replay10s();
//   void playPrev();
//   void setTimerStop(Duration _dur);
// }

// class MyAudioPlayerHandler extends BaseAudioHandler
//     with SeekHandler
//     implements AudioPlayerHandler {
//   final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
//   final _player = AudioPlayer();

//   MyAudioPlayerHandler() {
//     _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

//     // ... and also the current media item via mediaItem.
//     _init();

//     // Load the player.
//   }
//   @override
//   Future<void> skipToNext() {
//     // TODO: implement skipToNext
//     return super.skipToNext();
//   }

//   void _init() async {
//     final session = await AudioSession.instance;
//     await session.configure(AudioSessionConfiguration.speech());
//     _repeatMode = MeidaRepeatMode.REPEAT_ALL;
//     _lyricModel = LyricsModelBuilder.create();
//     // _player.durationStream.listen((_dur) {
//     //   print("durationStream:${_dur},${_player.processingState}");
//     //   if (_dur != null && _dur != Duration.zero) {
//     //   }
//     // });
//     AudioService.notificationClicked.listen((event) {
//       print("notificationClicked");
//       if (event == true && (disposePage == null || disposePage == true)) {
//         print("导航");
//         Future.delayed(Duration(seconds: 0)).then((_) {
//           Navigator.push(navigatorKey.currentState.overlay.context,
//               ContentPageRoute().route(searchItem));
//         });
//       }

//       print("notificationClicked:${event}");
//     });
//     // playbackState.listen((value) {value.processingState})

//     _player.processingStateStream.listen((ps) {
//       print("processingStateStream:${ps}");
//       if (ps == ProcessingState.completed) {
//         print("_repeatMode:${_repeatMode}");
//         switch (_repeatMode) {
//           case MeidaRepeatMode.REPEAT_FAVORITE:
//             playNext(true);
//             break;
//           case MeidaRepeatMode.REPEAT_ALL:
//             playNext();
//             break;
//           case MeidaRepeatMode.REPEAT_ONE:
//             replay();
//             break;
//           default:
//             break;
//         }
//       }
//     });

//     if (_timer == null) {
//       _timer = Timer.periodic(Duration(milliseconds: 1000), (_) {
//         if (timer_stopPlay != Duration.zero && _lastduration_stopPlay != null) {
//           int sy =
//               _lastduration_stopPlay.compareTo(DateTime.now().subtract(timer_stopPlay));
//           if (sy != 1) {
//             _timer_stopPlay = Duration.zero;
//             _lastduration_stopPlay = null;
//             pause();
//           }

//           print("compare:${sy}");
//         }

//         // if (timeProc != null) {
//         //   if (timeProc(duration_stopPlay)) {
//         //     _player.stop();
//         //   }
//         // }
//       });
//     }
//   }

//   int _durChapterIndex = -1;
//   int get durChapterIndex => _durChapterIndex;

//   String _playUrl;
//   String get playUrl => _playUrl;

//   SearchItem _searchItem;
//   SearchItem get searchItem => _searchItem;

//   LyricsModelBuilder _lyricModel;
//   LyricsModelBuilder get lyricModel => _lyricModel;

//   MeidaRepeatMode _repeatMode;
//   MeidaRepeatMode get repeatMode => _repeatMode;
//   @override
//   ChapterItem get curChapter =>
//       _durChapterIndex < 0 || _durChapterIndex >= (_searchItem?.chapters?.length ?? 0)
//           ? null
//           : _searchItem.chapters[_durChapterIndex];

//   @override
//   Future<void> readySongUrl(int chapterIndex,
//       [SearchItem searchItem, bool tryNext = false]) async {
//     print("playChapter");

//     if (searchItem == null) {
//       if (chapterIndex < 0 || chapterIndex >= _searchItem.chapters.length) return;
//       if (_playUrl != null && _searchItem.durChapterIndex == chapterIndex) {
//         // 重新播放
//         // replay();
//         return;
//       }
//     } else if (_searchItem == null || (_searchItem.chapterUrl != searchItem.chapterUrl)) {
//       print("_searchItem != searchItem");
//       _searchItem = searchItem;
//     } else if (_durChapterIndex == chapterIndex) {
//       print("if _durChapterIndex:${_durChapterIndex} == chapterIndex:${chapterIndex}");
//       play();
//       return;
//     }

//     // await pause();
//     // await seek(Duration(microseconds: 0));
//     // await stop();
//     // await _player.stop();
//     _durChapterIndex = chapterIndex;
//     print("_durChapterIndex:${_durChapterIndex} == chapterIndex:${chapterIndex}");

//     if (_searchItem.chapters == null || _searchItem.chapters.isEmpty) return;
//     final content = await APIManager.getContent(
//         _searchItem.originTag, _searchItem.chapters[chapterIndex].url);
//     if (content == null || content.length == 0) return;
//     _playUrl = content[0];

//     print("content:${content}");

//     for (final c in content.skip(1)) {
//       if (c.startsWith('@cover')) {
//         _searchItem.chapters[chapterIndex].cover = c.substring(6);
//       }
//       if (c.startsWith('@lrc')) {
//         _lyricModel.reset();
//         _lyricModel = _lyricModel.bindLyricToMain(c.substring(4));
//       }
//     }
//     if (_searchItem.chapters[chapterIndex].cover.isEmpty) {
//       _searchItem.chapters[chapterIndex].cover = _searchItem.cover;
//     }
//     // print("cover:${_searchItem.chapters[chapterIndex].cover}");

//     _searchItem.durChapterIndex = chapterIndex;
//     _searchItem.durChapter = _searchItem.chapters[chapterIndex].name;
//     _searchItem.durContentIndex = 1;
//     _searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
//     // print(
//     //     "lastReadTime:${_searchItem.lastReadTime},${DateTime.fromMillisecondsSinceEpoch(_searchItem.lastReadTime)}");
//     try {
//       await _searchItem.save();
//     // await SearchItemManager.saveSearchItem();
//       HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
//     } catch (e) {}

//     try {
//       Duration _dur;
//       if (_playUrl.contains("@headers")) {
//         final u = _playUrl.split("@headers");
//         final h = (jsonDecode(u[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
//         print("url:${u[0]},headers:${h}");

//         _dur = await _player.setAudioSource(
//           AudioSource.uri(
//             Uri.parse(u[0]),
//             headers: h,
//           ),
//         );
//         // await _player
//         //     .setAudioSource(AudioSource.uri(Uri.parse(u[0]), headers: h));
//       } else {
//         _dur = await _player.setAudioSource(AudioSource.uri(Uri.parse(_playUrl)));
//       }

//       String _cover = _searchItem.chapters[_searchItem.durChapterIndex].cover;
//       // print("_cover:${_cover}");
//       if (_cover.isEmpty) {
//         _cover = _searchItem.cover;
//       }
//       String _coverUrl = _cover;
//       Map<String, String> _aHeaders = null;

//       if (_cover.contains("@headers")) {
//         final u = _cover.split("@headers");
//         final h = (jsonDecode(u[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
//         _coverUrl = u[0];
//         _aHeaders = h;
//       }
//       // print("_cover:${_cover},\n${_coverUrl},\n_aHeaders:${_aHeaders}");

//       mediaItem.add(MediaItem(
//         id: _searchItem.chapterUrl,
//         album: _searchItem.chapters[_searchItem.durChapterIndex].name,
//         title: _searchItem.name,
//         artist: _searchItem.author,
//         duration: _dur,
//         artHeaders: _aHeaders,
//         artUri: Uri.parse(_coverUrl),
//       ));
//       // playMediaItem(mediaItem)
//       play();

//       // await _player.setPlaybackRate(_playspeed);
//     } catch (e) {
//       print(e);
//       if (tryNext == true) {
//         await Utils.sleep(3000);
//         if (!_player.playing) playNext();
//       }
//     }
//   }

//   @override
//   void playNext([bool allFavorite = false]) {
//     if (_searchItem.durChapterIndex == (_searchItem.chapters.length - 1)) {
//       if (allFavorite != true) {
//         readySongUrl(0);
//       }
//     } else {
//       readySongUrl(_searchItem.durChapterIndex + 1);
//     }
//   }

//   Stream<Duration> get positionStream => _player.positionStream;
//   Stream<Duration> get durationStream => _player.durationStream;
//   Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

//   @override
//   Future<void> replay() async {
//     await _player.pause();
//     await _player.seek(Duration.zero);
//     // if (onUpStateCallBack != null && playMain == false) {
//     //   onUpStateCallBack();
//     // }
//     return await _player.play();
//   }

//   @override
//   void switchRepeatMode() {
//     if (_repeatMode == MeidaRepeatMode.REPEAT_FAVORITE) {
//       _repeatMode = MeidaRepeatMode.REPEAT_ALL;
//     } else if (_repeatMode == MeidaRepeatMode.REPEAT_ALL) {
//       _repeatMode = MeidaRepeatMode.REPEAT_ONE;
//     } else if (_repeatMode == MeidaRepeatMode.REPEAT_ONE) {
//       _repeatMode = MeidaRepeatMode.REPEAT_NONE;
//     } else if (_repeatMode == MeidaRepeatMode.REPEAT_NONE) {
//       _repeatMode = MeidaRepeatMode.REPEAT_FAVORITE;
//     }
//   }

//   @override
//   Future<void> play() {
//     final _state = _player.processingState;
//     if (_state == ProcessingState.completed) {
//       return replay();
//     }
//     // if (onUpStateCallBack != null && playMain == false) {
//     //   onUpStateCallBack();
//     // }
//     return _player.play();
//   }

//   @override
//   Future<void> playOrPause() async {
//     if (_player.playing) {
//       return pause();
//     } else {
//       return play();
//     }
//   }

//   @override
//   void replay10s() async {
//     if (playing) {
//       await _player.seek(Duration(seconds: position.inSeconds - 10));
//     }
//   }

//   @override
//   void playPrev() => readySongUrl(_searchItem.durChapterIndex == 0
//       ? _searchItem.chapters.length - 1
//       : _searchItem.durChapterIndex - 1);

//   @override
//   void forward10s() async {
//     if (playing) {
//       await _player.seek(Duration(seconds: position.inSeconds + 10));
//     }
//   }

//   @override
//   Future<void> setSpeed(double speed) => _player.setSpeed(speed);

//   @override
//   Future<void> pause() => _player.pause();

//   @override
//   Future<void> seek(Duration position) => _player.seek(position);

//   @override
//   Future<void> stop() => _player.stop();

//   @override
//   void setTimerStop(Duration _dur) {
//     _lastduration_stopPlay = DateTime.now();
//     _timer_stopPlay = _dur;
//   }

//   PlaybackState _transformEvent(PlaybackEvent event) {
//     return PlaybackState(
//       controls: [
//         MediaControl.rewind,
//         if (_player.playing) MediaControl.pause else MediaControl.play,
//         MediaControl.stop,
//         MediaControl.fastForward,
//       ],
//       systemActions: const {
//         MediaAction.seek,
//         MediaAction.seekForward,
//         MediaAction.seekBackward,
//       },
//       androidCompactActionIndices: const [0, 1, 3],
//       processingState: const {
//         ProcessingState.idle: AudioProcessingState.idle,
//         ProcessingState.loading: AudioProcessingState.loading,
//         ProcessingState.buffering: AudioProcessingState.buffering,
//         ProcessingState.ready: AudioProcessingState.ready,
//         ProcessingState.completed: AudioProcessingState.completed,
//       }[_player.processingState],
//       playing: _player.playing,
//       updatePosition: _player.position,
//       bufferedPosition: _player.bufferedPosition,
//       speed: _player.speed,
//       queueIndex: event.currentIndex,
//     );
//   }

//   @override
//   bool disposePage;

//   @override
//   Duration get duration => _player.duration;
//   @override
//   Duration get position => _player.position;
//   @override
//   bool get playing => _player.playing;
//   @override
//   double get speed => _player.speed;

//   Timer _timer;
//   DateTime _lastduration_stopPlay;

//   Duration _timer_stopPlay = Duration.zero;
//   @override
//   Duration get timer_stopPlay => _timer_stopPlay;

//   bool _close = true;

//   @override
//   bool get close => _close;
//   bool _playMain = false;
//   @override
//   bool get playMain => _playMain;

//   set close(bool value) {
//     if (value != _close) {
//       _close = value;
//     }
//   }

//   set playMain(bool value) {
//     if (value != _playMain) {
//       _playMain = value;
//     }
//   }
//   // @override
//   // set duration(Duration _duration) {
//   //   duration = _duration;
//   // }
//   // @override
//   // set playing(bool _playing) {
//   //   playing = _playing;
//   // }
//   // @override
//   // set position(Duration _position) {
//   //   position = _position;
//   // }
//   // @override
//   // set durChapterIndex(int _durChapterIndex) {
//   //   durChapterIndex = _durChapterIndex;
//   // }
//   // @override
//   // set lyricModel(LyricsModelBuilder _lyricModel) {
//   //   lyricModel = _lyricModel;
//   // }
//   // @override
//   // set playUrl(String _playUrl) {
//   //   playUrl = _playUrl;
//   // }
//   // @override
//   // set repeatMode(meidaRepeatMode _repeatMode) {
//   //   repeatMode = _repeatMode;
//   // }
//   // @override
//   // set searchItem(SearchItem _searchItem) {
//   //   searchItem = _searchItem;
//   // }

//   @override
//   dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
// }
