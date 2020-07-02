import 'package:audioplayers/audioplayers.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/evnts/audio_state_event.dart';
import 'package:eso/utils.dart';

class AudioService {
  static const int REPEAT_FAVORITE = 3;
  static const int REPEAT_ALL = 2;
  static const int REPEAT_ONE = 1;
  static const int REPEAT_NONE = 0;

  static AudioService __internal;

  static AudioService getAudioService() {
    if (__internal == null)
      __internal = AudioService._internal();
    return __internal;
  }

  factory AudioService() => getAudioService();

  static bool get isPlaying => __internal != null && __internal.__isPlaying;

  static Future<void> stop() async {
    if (!isPlaying) return;
    await __internal._player.stop();
  }

  static String getRepeatName(int value) {
    switch (value) {
      case REPEAT_FAVORITE: return "跨源循环";
      case REPEAT_FAVORITE: return "列表循环";
      case REPEAT_FAVORITE: return "单曲循环";
      case REPEAT_FAVORITE: return "不循环";
    }
    return null;
  }

  AudioService._internal() {
    if (_player == null) {
      _durChapterIndex = -1;
      _player = AudioPlayer();
      _repeatMode = REPEAT_ALL;
      _duration = Duration.zero;
      _positionDuration = Duration.zero;
      _player.onDurationChanged.listen((Duration d) {
        _duration = d;
      });
      _player.onAudioPositionChanged.listen((Duration p) {
        _positionDuration = p;
      });
      _player.onPlayerStateChanged.listen((AudioPlayerState s) {
        _playerState = s;
        eventBus.fire(AudioStateEvent(_searchItem, s));
      });
      _player.onPlayerCompletion.listen((event) {
        switch (_repeatMode) {
          case REPEAT_FAVORITE:
            playNext(true);
            break;
          case REPEAT_ALL:
            playNext();
            break;
          case REPEAT_ONE:
            replay();
            break;
        }
      });
    }
  }

  String get durChapter => _searchItem.durChapter;

  Future<int> seek(Duration duration) => _player.seek(duration);

  Future<int> replay() async {
    await _player.pause();
    await _player.seek(Duration.zero);
    return _player.resume();
  }

  /// 是否正在播放
  bool get __isPlaying => _playerState != null &&
      _playerState != AudioPlayerState.STOPPED &&
      _playerState != AudioPlayerState.COMPLETED &&
      _playerState != AudioPlayerState.PAUSED;

  Future<int> play() async {
    switch (_playerState) {
      case AudioPlayerState.COMPLETED:
      case AudioPlayerState.STOPPED:
        return replay();
        break;
      // case AudioPlayerState.PAUSED:
      //   return _player.resume();
      default:
        return _player.resume();
    }
  }

  Future<int> playOrPause() async {
    if (_playerState == AudioPlayerState.PLAYING) {
      return _player.pause();
    } else {
      return play();
    }
  }

  void playNext([bool allFavorite = false]) {
    if (_searchItem.durChapterIndex == (_searchItem.chapters.length - 1)) {
      if (allFavorite != true) {
        playChapter(0);
      } else {
        eventBus.fire(AudioStateEvent(_searchItem, AudioPlayerState.COMPLETED, playNext: true));
      }
    } else {
      playChapter(_searchItem.durChapterIndex + 1);
    }
  }

  void playPrev() => playChapter(_searchItem.durChapterIndex == 0
      ? _searchItem.chapters.length - 1
      : _searchItem.durChapterIndex - 1);

  Future<void> playChapter(int chapterIndex, [SearchItem searchItem]) async {
    if (searchItem == null || _searchItem == searchItem) {
      if (chapterIndex < 0 || chapterIndex >= _searchItem.chapters.length) return;
      if (_url != null && _searchItem.durChapterIndex == chapterIndex) {
        replay();
        return;
      }
    } else if (_searchItem != searchItem) {
      _searchItem = searchItem;
    } else if (_durChapterIndex == chapterIndex) {
      play();
      return;
    }
    _player.pause();
    await _player.seek(Duration.zero);
    _player.stop();
    _durChapterIndex = chapterIndex;
    if (_searchItem.chapters == null || _searchItem.chapters.isEmpty)
      return;
    final content = await APIManager.getContent(
        _searchItem.originTag, _searchItem.chapters[chapterIndex].url);
    if (content == null || content.length == 0) return;
    _url = content[0];
    if (content.length == 2 && content[1].substring(0, 5) == 'cover') {
      _searchItem.chapters[chapterIndex].cover = content[1].substring(5);
    }
    _searchItem.durChapterIndex = chapterIndex;
    _searchItem.durChapter = _searchItem.chapters[chapterIndex].name;
    _searchItem.durContentIndex = 1;
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    await SearchItemManager.saveSearchItem();
    _player.play(_url);
  }

  void switchRepeatMode() {
    int temp = _repeatMode + 1;
    if (temp > 3) {
      _repeatMode = 0;
    } else {
      _repeatMode = temp;
    }
  }

  AudioPlayer _player;
  SearchItem _searchItem;
  SearchItem get searchItem => _searchItem;
  int _durChapterIndex;
  String _url;
  String get url => _url;

  int _repeatMode;
  int get repeatMode => _repeatMode;

  Duration _duration;
  Duration get duration => _duration;
  Duration _positionDuration;
  Duration get positionDuration => _positionDuration;

  AudioPlayerState _playerState;
  AudioPlayerState get playerState => _playerState;

  /// 当前播放的节目
  ChapterItem get curChapter => _durChapterIndex < 0 || _durChapterIndex >= (_searchItem?.chapters?.length ?? 0) ? null : _searchItem.chapters[_durChapterIndex];


  void dispose() {
    try {
      _player?.stop();
      _player?.resume();
      _player?.dispose();
    } catch (_) {}
  }
}
