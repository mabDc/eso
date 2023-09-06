// import 'package:audioplayers/audioplayers.dart';
// import 'package:eso/api/api_manager.dart';
// import 'package:eso/database/chapter_item.dart';
// import 'package:eso/database/history_item_manager.dart';
// import 'package:eso/database/search_item.dart';
// import 'package:eso/database/search_item_manager.dart';
// import 'package:eso/utils.dart';
// import '../lyric/lyric.dart';

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
//       _lyrics = <Lyric>[];
//       _durChapterIndex = -1;
//       _player = AudioPlayer();
//       _repeatMode = REPEAT_ALL;
//       _duration = Duration.zero;
//       _positionDuration = Duration.zero;
//       _player.onDurationChanged.listen((Duration d) {
//         _duration = d;
//       });
//       _player.onPositionChanged.listen((Duration p) {
//         _positionDuration = p;
//       });
//       _player.onPlayerStateChanged.listen((PlayerState s) {
//         _playerState = s;
//       });
//       _player.onPlayerComplete.listen((event) {
//         switch (_repeatMode) {
//           case REPEAT_FAVORITE:
//             playNext(true);
//             break;
//           case REPEAT_ALL:
//             playNext();
//             break;
//           case REPEAT_ONE:
//             replay();
//             break;
//         }
//       });
//     }
//   }

//   String get durChapter => _searchItem.durChapter;

//   Future<int> seek(Duration duration) => _player.seek(duration);

//   Future<void> replay() async {
//     await _player.pause();
//     await _player.seek(Duration.zero);
//     return _player.resume();
//   }

//   /// 是否正在播放
//   bool get __isPlaying =>
//       _playerState != null &&
//       _playerState != PlayerState.stopped &&
//       _playerState != PlayerState.completed &&
//       _playerState != PlayerState.paused;

//   Future<void> play() async {
//     switch (_playerState) {
//       case PlayerState.completed:
//       case PlayerState.stopped:
//         return replay();
//         break;
//       // case PlayerState.PAUSED:
//       //   return _player.resume();
//       default:
//         return _player.resume();
//     }
//   }

//   Future<void> playOrPause() async {
//     if (_playerState == PlayerState.playing) {
//       return _player.pause();
//     } else {
//       return play();
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

//   List<Lyric> _lyrics;
//   List<Lyric> get lyrics => _lyrics;
//   final durationReg = RegExp(r'\[(\d{1,2}):(\d{1,2})(\.\d{1,3})?\]');
//   Future<void> playChapter(int chapterIndex,
//       {SearchItem searchItem, bool tryNext = false}) async {
//     if (searchItem == null) {
//       if (chapterIndex < 0 || chapterIndex >= _searchItem.chapters.length) return;
//       if (_url != null && _searchItem.durChapterIndex == chapterIndex) {
//         replay();
//         return;
//       }
//     } else if (_searchItem != searchItem) {
//       _searchItem = searchItem;
//     } else if (_durChapterIndex == chapterIndex) {
//       play();
//       return;
//     }
//     try {
//       _player.pause();
//       await _player.seek(Duration.zero);
//     } catch (e) {}
//     _player.stop();
//     _durChapterIndex = chapterIndex;
//     if (_searchItem.chapters == null || _searchItem.chapters.isEmpty) return;
//     final content = await APIManager.getContent(
//         _searchItem.originTag, _searchItem.chapters[chapterIndex].url);
//     if (content == null || content.length == 0) return;
//     _url = content[0];
//     _lyrics.clear();
//     for (final c in content.skip(1)) {
//       if (c.startsWith('@cover')) {
//         _searchItem.chapters[chapterIndex].cover = c.substring(6);
//       }
//       if (c.startsWith('@lrc')) {
//         // 一行一行解析
//         // start继承最后一个，否则鬼畜
//         Duration start = Duration.zero;
//         _lyrics = c.substring(4).trim().split('\n').map((l) {
//           final m = durationReg.allMatches(l).toList();
//           Duration end;
//           int startIndex = 0;
//           int endIndex = l.length;
//           if (m.length > 0) {
//             final startM = m.first;
//             startIndex = startM.end;
//             start = Duration(
//               minutes: int.parse(startM.group(1)),
//               seconds: int.parse(startM.group(2)),
//               milliseconds: int.parse(startM.group(3)?.substring(1) ?? '0'),
//             );
//           }
//           if (m.length > 1) {
//             final endM = m.last;
//             endIndex = endM.start;
//             end = Duration(
//               minutes: int.parse(endM.group(1)),
//               seconds: int.parse(endM.group(2)),
//               milliseconds: int.parse(endM.group(3) ?? '0'),
//             );
//           }
//           return Lyric(
//             l.substring(startIndex, endIndex),
//             startTime: start,
//             endTime: end,
//           );
//         }).toList();
//         for (var i = 0; i < _lyrics.length - 1; i++) {
//           if (_lyrics[i].endTime == null) {
//             _lyrics[i].endTime = _lyrics[i + 1].startTime;
//           }
//         }
//         if (_lyrics.last.startTime.inSeconds == 0) {
//           _lyrics.last.endTime = _lyrics.last.startTime;
//         } else {
//           _lyrics.last.endTime = _lyrics.last.startTime + Duration(seconds: 10);
//         }
//       }
//     }
//     if (_lyrics == null || _lyrics.isEmpty) {
//       _lyrics = <Lyric>[
//         Lyric(
//           '没有歌词 >_<',
//           startTime: Duration.zero,
//           endTime: Duration.zero,
//         ),
//       ];
//     }
//     _searchItem.durChapterIndex = chapterIndex;
//     _searchItem.durChapter = _searchItem.chapters[chapterIndex].name;
//     _searchItem.durContentIndex = 1;
//     try {
//       await _searchItem.save();
//       HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
//     } catch (e) {}
//     // await SearchItemManager.saveSearchItem();
//     print(_url);
//     try {
//       await _player.play(UrlSource(_url));
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

//   AudioPlayer _player;
//   SearchItem _searchItem;
//   SearchItem get searchItem => _searchItem;
//   int _durChapterIndex;
//   String _url;
//   String get url => _url;

//   int _repeatMode;
//   int get repeatMode => _repeatMode;

//   Duration _duration;
//   Duration get duration => _duration;
//   Duration _positionDuration;
//   Duration get positionDuration => _positionDuration;

//   PlayerState _playerState;
//   PlayerState get playerState => _playerState;

//   /// 当前播放的节目
//   ChapterItem get curChapter =>
//       _durChapterIndex < 0 || _durChapterIndex >= (_searchItem?.chapters?.length ?? 0)
//           ? null
//           : _searchItem.chapters[_durChapterIndex];

//   void dispose() {
//     try {
//       _player?.stop();
//       _player?.resume();
//       _player?.dispose();
//     } catch (_) {}
//   }
// }
