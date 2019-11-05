import 'package:audioplayers/audioplayers.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';

class AudioService {
  static const int REPEAT_ALL = 2;
  static const int REPEAT_ONE = 1;
  static const int REPEAT_NONE = 0;

  static final AudioService _audioService = AudioService._internal();
  factory AudioService() => _audioService;

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
      });
      _player.onPlayerCompletion.listen((event) {
        switch (_repeatMode) {
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

  void playNext() => playChapter(
      _searchItem.durChapterIndex == (_searchItem.chapters.length - 1)
          ? 0
          : _searchItem.durChapterIndex + 1);

  void playPrev() => playChapter(_searchItem.durChapterIndex == 0
      ? _searchItem.chapters.length - 1
      : _searchItem.durChapterIndex - 1);

  Future<void> playChapter(int chapterIndex, [SearchItem searchItem]) async {
    if (searchItem == null) {
      if (chapterIndex < 0 || chapterIndex >= _searchItem.chapters.length)
        return;
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
    await SearchItemManager.saveSearchItem();
    _player.play(_url);
  }

  void switchRepeatMode() {
    int temp = _repeatMode + 1;
    if (temp > 2) {
      _repeatMode = 0;
    } else {
      _repeatMode = temp;
    }
  }

  AudioPlayer _player;
  SearchItem _searchItem;
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
}
