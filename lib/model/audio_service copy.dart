// // import 'package:audioplayers/audioplayers.dart';
// import 'dart:convert';

// import 'package:just_audio/just_audio.dart';

// import 'package:eso/api/api_manager.dart';
// import 'package:eso/database/chapter_item.dart';
// import 'package:eso/database/history_item_manager.dart';
// import 'package:eso/database/search_item.dart';
// import 'package:eso/database/search_item_manager.dart';
// import 'package:eso/utils.dart';
// // import '../lyric/lyric.dart';
// import 'package:flutter_lyric/lyrics_reader.dart';
// import 'package:just_audio_background/just_audio_background.dart';

// class AudioService {
//   static const int REPEAT_FAVORITE = 3;
//   static const int REPEAT_ALL = 2;
//   static const int REPEAT_ONE = 1;
//   static const int REPEAT_NONE = 0;

//   static AudioService __internal;

//   static AudioService getAudioService() {
//     if (__internal == null) __internal = AudioService._internal();
//     return __internal;
//   }

//   factory AudioService() => getAudioService();

//   static bool get isPlaying => __internal != null && __internal.__isPlaying;

//   static Future<void> stop() async {
//     if (!isPlaying) return;
//     await __internal._player.stop();
//   }

//   static String getRepeatName(int value) {
//     switch (value) {
//       case REPEAT_FAVORITE:
//         return "跨源循环";
//       case REPEAT_ALL:
//         return "列表循环";
//       case REPEAT_ONE:
//         return "单曲循环";
//       case REPEAT_NONE:
//         return "不循环";
//     }
//     return null;
//   }

//   AudioService._internal() {
//     if (_player == null) {
//       _lyricModel = LyricsModelBuilder.create();
//       _durChapterIndex = -1;

//       _player = AudioPlayer(audioLoadConfiguration: AudioLoadConfiguration());
//       _repeatMode = REPEAT_ALL;
//       _duration = Duration.zero;
//       _positionDuration = Duration.zero;

//       _player.durationStream.listen((Duration d) {
//         //print("durationStream:${d.inSeconds}");
//         _duration = d;
//       });

//       _player.positionStream.listen((Duration p) {
//         //print("positionStream:${p.inSeconds}");
//         _positionDuration = p;
//       });

//       _player.playerStateStream.listen((PlayerState s) {
//         //print("playerStateStream:${s.playing}");
//         _playerState = s;
//       });
//       _player.processingStateStream.listen((ProcessingState ps) {
//         //print("processingStateStream:${ps}");
//         if (ps == ProcessingState.completed) {
//           switch (_repeatMode) {
//             case REPEAT_FAVORITE:
//               playNext(true);
//               break;
//             case REPEAT_ALL:
//               playNext();
//               break;
//             case REPEAT_ONE:
//               replay();
//               break;
//           }
//         }
//       });

//       // _player.onPlayerComplete.listen((event) {
//       //   switch (_repeatMode) {
//       //     case REPEAT_FAVORITE:
//       //       playNext(true);
//       //       break;
//       //     case REPEAT_ALL:
//       //       playNext();
//       //       break;
//       //     case REPEAT_ONE:
//       //       replay();
//       //       break;
//       //   }
//       // });

//     }
//   }

//   String get durChapter => _searchItem.durChapter;

//   Future<void> seek(Duration d) => _player.seek(d);

//   Future<void> replay() async {
//     await _player.pause();
//     await _player.seek(Duration.zero);
//     return _player.play();
//   }

//   /// 是否正在播放
//   bool get __isPlaying => _player.playing;

//   Future<void> play() async {
//     print("_player.processingState:${_player.processingState}");
//     switch (_player.processingState) {
//       case ProcessingState.completed:
//         return replay();
//         break;
//       // case PlayerState.PAUSED:
//       //   return _player.resume();
//       default:
//         return await _player.play();
//     }
//   }

//   Future<void> playOrPause() async {
//     if (_playerState.playing) {
//       return _player.pause();
//     } else {
//       return play();
//     }
//   }

//   void setSpeed(double speed) async {
//     if (_playerState.playing) {
//       try {
//         await _player.setSpeed(speed);
//         _playspeed = speed;
//       } catch (e) {}
//     }
//   }

//   void replay10s() async {
//     if (_playerState.playing) {
//       _player.seek(Duration(seconds: _positionDuration.inSeconds - 10));
//     }
//   }

//   void forward10s() async {
//     if (_playerState.playing) {
//       //print("_positionDuration.inSeconds:${_positionDuration.inSeconds}");
//       _player.seek(Duration(seconds: _positionDuration.inSeconds + 10));
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

//   // final durationReg = RegExp(r'\[(\d{1,2}):(\d{1,2})(\.\d{1,3})?\]');
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
//       _player.pause();
//       await _player.seek(Duration.zero);
//     } catch (e) {}
//     _player.stop();
//     _durChapterIndex = chapterIndex;
//     print(
//         "_durChapterIndex:${_durChapterIndex} == chapterIndex:${chapterIndex}");

//     if (_searchItem.chapters == null || _searchItem.chapters.isEmpty) return;
//     final content = await APIManager.getContent(
//         _searchItem.originTag, _searchItem.chapters[chapterIndex].url);
//     if (content == null || content.length == 0) return;
//     _url = content[0];
//     _lyricModel.reset();

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
//     HistoryItemManager.insertOrUpdateHistoryItem(_searchItem);
//     await HistoryItemManager.saveHistoryItem();
//     print(_url);
//     try {
//       if (_url.contains("@headers")) {
//         final u = _url.split("@headers");
//         final h = (jsonDecode(u[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
//         print("url:${u[0]},headers:${h}");

//         await _player.setAudioSource(
//           AudioSource.uri(
//             Uri.parse(u[0]),
//             headers: h,
//             tag: MediaItem(
//               id: u[0],
//               album: _searchItem.chapters[_searchItem.durChapterIndex].name,
//               title: _searchItem.name,
//               artUri: Uri.parse(
//                   "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
//             ),
//           ),
//         );
//       } else {
//         await _player.setAudioSource(AudioSource.uri(
//           Uri.parse(_url),
//           tag: MediaItem(
//             id: _url,
//             album: _searchItem.chapters[_searchItem.durChapterIndex].name,
//             title: _searchItem.name,
//             artUri: Uri.parse(
//                 "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
//           ),
//         ));
//       }

//       await _player.setSpeed(_playspeed);
//       //_player.load();
//       await _player.play();
//     } catch (e) {
//       print(e);
//       if (tryNext == true) {
//         await Utils.sleep(3000);
//         if (!AudioService.isPlaying) playNext();
//       }
//     }
//   }

//   void switchRepeatMode() {
//     int temp = _repeatMode + 1;
//     if (temp > 3) {
//       _repeatMode = 0;
//     } else {
//       _repeatMode = temp;
//     }
//   }

//   LyricsModelBuilder _lyricModel;
//   LyricsModelBuilder get lyricModel => _lyricModel;

//   AudioPlayer _player;
//   AudioPlayer get player => _player;
//   SearchItem _searchItem;
//   SearchItem get searchItem => _searchItem;
//   int _durChapterIndex;
//   String _url;
//   String get url => _url;
//   double _playspeed = 1.0;
//   double get playspeed => _playspeed;

//   int _repeatMode;
//   int get repeatMode => _repeatMode;

//   Duration _duration;
//   Duration get duration => _duration;
//   Duration _positionDuration;
//   Duration get positionDuration => _positionDuration;
//   Duration _bufferedPosition;
//   Duration get bufferedPosition => _bufferedPosition;

//   PlayerState _playerState;
//   PlayerState get playerState => _playerState;

//   /// 当前播放的节目
//   ChapterItem get curChapter => _durChapterIndex < 0 ||
//           _durChapterIndex >= (_searchItem?.chapters?.length ?? 0)
//       ? null
//       : _searchItem.chapters[_durChapterIndex];

//   void dispose() {
//     try {
//       _player?.stop();
//       //_player?.resume();
//       _player?.dispose();
//     } catch (_) {}
//   }
// }
