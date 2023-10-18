import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/widgets/animation_rotate_view.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../lyric/lyric.dart';
import '../lyric/lyric_widget.dart';
import '../lyric/lyric_controller.dart';
import 'dart:math';

import '../fonticons_icons.dart';
import '../global.dart';
import 'content_page_manager.dart';
import 'hidden/linyuan_page.dart';
import 'langding_page.dart';
import 'package:rxdart/rxdart.dart';

AudioHandler _audioHandler;
AudioHandler get audioHandler => _audioHandler;

Future<bool> ensureInitAudioHandler(SearchItem searchItem) async {
  if (_audioHandler == null) {
    _audioHandler = await AudioService.init(
      builder: () => AudioHandler(searchItem),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.eso.channel.audio',
        androidNotificationChannelName: '亦搜音频',
        androidNotificationOngoing: true,
        androidNotificationIcon: 'mipmap/eso_logo',
      ),
    );
  }
  return true;
}

checkAudioInList(List<SearchItem> searchList) {
  if (_audioHandler?.searchItem != null &&
      !SearchItemManager.isFavorite(
          _audioHandler.searchItem.originTag, _audioHandler.searchItem.url)) {
    searchList.add(_audioHandler.searchItem);
  }
}

class AudioHandler extends BaseAudioHandler with SeekHandler {
  SearchItem _searchItem;
  SearchItem get searchItem => _searchItem;
  int _currentIndex = 0;
  ChapterItem get chapter {
    if (searchItem.chapters == null || searchItem.chapters.isEmpty) {
      Utils.toast("无曲目");
      return null;
    }
    final len = searchItem.chapters.length;
    if (_currentIndex < 0) {
      _currentIndex = len - 1;
    } else if (_currentIndex >= len) {
      _currentIndex = 0;
    }
    return searchItem.chapters[_currentIndex];
  }

  var close = false;
  String cover = "";
  Map<String, String> headers;
  bool get emptyCover => Utils.empty(cover);
  ContentProvider _contentProvider;
  final _player = AudioPlayer();
  bool get playing => _player.playing;
  Stream<Duration> get positionStream => _player.positionStream;
  Duration get position => _player.position;
  Duration get duration => _player.duration;
  Duration get bufferedPosition => _player.bufferedPosition;

  final _repeatMode = BehaviorSubject.seeded(AudioServiceRepeatMode.all);
  Stream<AudioServiceRepeatMode> get repeatMode => _repeatMode.stream;

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    if (repeatMode == AudioServiceRepeatMode.group) {
      final list = AudioServiceRepeatMode.values;
      repeatMode = list[(repeatMode.index + 1) % list.length];
    }
    _repeatMode.add(repeatMode);
    super.setRepeatMode(repeatMode);
  }

  void toggleRepeatMode() {
    final list = AudioServiceRepeatMode.values;
    final next = list[(_repeatMode.value.index + 1) % list.length];
    if (next == AudioServiceRepeatMode.group) {
      _repeatMode.add(list[(_repeatMode.value.index + 2) % list.length]);
    } else {
      _repeatMode.add(next);
    }
  }

  MapEntry<String, IconData> getRepeatModeName() {
    switch (_repeatMode.value) {
      case AudioServiceRepeatMode.all:
        return MapEntry<String, IconData>("歌单循环", Icons.repeat_rounded);
      case AudioServiceRepeatMode.none:
        return MapEntry<String, IconData>("不循环", Icons.label_outline);
      case AudioServiceRepeatMode.one:
        return MapEntry<String, IconData>("单曲循环", Icons.repeat_one_rounded);
      case AudioServiceRepeatMode.group:
        return MapEntry<String, IconData>("分组循环", Icons.event_repeat_rounded);
      default:
        return MapEntry<String, IconData>("位置循环模式", Icons.report_gmailerrorred_outlined);
    }
  }

  AudioHandler(SearchItem searchItem) {
    _searchItem = searchItem;
    upMediaItem();
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.processingStateStream.listen((event) {
      if (event == ProcessingState.completed) {
        switch (_repeatMode.value) {
          case AudioServiceRepeatMode.all:
            return skipToNext();
            break;
          case AudioServiceRepeatMode.none:
            if (_currentIndex < searchItem.chapters.length - 1)
              skipToNext();
            else
              stop();
            break;
          case AudioServiceRepeatMode.one:
            _player.seek(Duration.zero);
            play();
            break;
          case AudioServiceRepeatMode.group:
            skipToNext();
            break;
          default:
        }
      }
    });
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.setRepeatMode,
        MediaAction.play,
        MediaAction.pause,
        MediaAction.playPause,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState],
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      repeatMode: _repeatMode.value,
      // queueIndex: currentIndex,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToPrevious() async {
    loadChapter(searchItem.durChapterIndex - 1);
  }

  @override
  Future<void> skipToNext() async {
    loadChapter(searchItem.durChapterIndex + 1);
  }

  Future<void> playOrPause() async {
    if (_player.playing)
      return pause();
    else
      play();
  }

  void upMediaItem({Duration duration, String coverUrl}) {
    if (coverUrl != null) {
      upCover(coverUrl);
    }
    mediaItem.add(MediaItem(
      id: "${_searchItem.id}${_searchItem.durChapterIndex}",
      title: chapter.name,
      displayTitle: chapter.name,
      displaySubtitle: "${searchItem.name} ( ${searchItem.author} ${searchItem.origin} )",
      displayDescription: searchItem.description,
      album: searchItem.origin,
      artist: "${searchItem.name}(${searchItem.author})",
      artUri: Uri.tryParse(cover),
      artHeaders: headers,
      duration: duration,
    ));
  }

  void upCover(String urlWithHeaders) {
    final index = urlWithHeaders.indexOf("@headers");
    if (index == -1) {
      cover = urlWithHeaders;
      headers?.clear();
      headers = null;
    } else {
      cover = urlWithHeaders.substring(0, index);
      headers = (jsonDecode(urlWithHeaders.substring(index + "@headers".length)) as Map)
          .map((k, v) => MapEntry('$k', '$v'));
    }
  }

  void load(SearchItem searchItem, [ContentProvider contentProvider = null]) {
    close = false;
    if (contentProvider != null) _contentProvider = contentProvider;
    if (_searchItem?.id != searchItem.id) {
      _searchItem = searchItem;
      _currentIndex = _searchItem.durChapterIndex;
      final c = chapter;
      if (chapter == null) {
        upMediaItem(duration: Duration.zero);
        _player.stop();
      } else {
        upMediaItem(coverUrl: _searchItem.cover);
        loadChapter(_searchItem.durChapterIndex, c);
      }
    } else if (_searchItem.durChapterIndex == _currentIndex) {
      play();
    } else {
      loadChapter(_searchItem.durChapterIndex);
    }
  }

  Future<void> loadChapter(int index, [ChapterItem c]) async {
    if (c == null && _currentIndex == index) {
      play();
      return;
    }
    if (_currentIndex != index) {
      _currentIndex = index;
      c = chapter;
    }
    if (c == null) {
      Utils.toast("播放失敗");
      _player.stop();
      upMediaItem(duration: Duration.zero);
      return;
    }
    _searchItem.durChapterIndex = _currentIndex;
    _searchItem.durChapter = c.name;
    _searchItem.lastReadTime = DateTime.now().millisecondsSinceEpoch;
    if (SearchItemManager.isFavorite(_searchItem.originTag, _searchItem.url))
      _searchItem.save();
    final result = await _contentProvider.loadChapter(_currentIndex);
    final url = result[0];
    String coverTemp = null;

    int lrcIndex = 0;
    int coverIndex = 0;
    for (var i = 1; i < result.length; i++) {
      final r = result[i];
      if (r.startsWith('@cover')) {
        coverIndex = i;
        final cover = r.substring('@cover'.length);
        if (cover.isNotEmpty) {
          c.cover = cover;
          if (SearchItemManager.isFavorite(_searchItem.originTag, _searchItem.url))
            _searchItem.save();
        }
      } else if (r.startsWith('@lrc')) {
        lrcIndex = i;
      }
    }
    if (lrcIndex != 0) {
      if (lrcIndex < coverIndex) {
        upLyrics(result.getRange(lrcIndex, coverIndex).join("\n"));
      } else {
        upLyrics(result.skip(lrcIndex).join('\n'));
      }
    } else {
      _lyrics.clear();
    }

    if (coverTemp == null && !Utils.empty(c.cover)) {
      coverTemp = c.cover;
    }
    if (url.isEmpty) {
      Utils.toast("播放失敗");
      upMediaItem(duration: Duration.zero, coverUrl: coverTemp);
      _player.stop();
    } else {
      if (url.contains("@headers")) {
        final u = url.split("@headers");
        final h = (jsonDecode(u[1]) as Map).map((k, v) => MapEntry('$k', '$v'));
        print("url:${u[0]},headers:${h}");
        final d = await _player.setUrl(u[0], headers: h);
        upMediaItem(duration: d, coverUrl: coverTemp);
        await play();
        upMediaItem(duration: d, coverUrl: coverTemp);
      } else {
        final d = await _player.setUrl(url);
        upMediaItem(duration: d, coverUrl: coverTemp);
        await play();
        upMediaItem(duration: d, coverUrl: coverTemp);
      }
    }
  }

  final List<Lyric> _lyrics = <Lyric>[];
  List<Lyric> get lyrics => _lyrics.isNotEmpty
      ? _lyrics
      : [Lyric('暂无歌词', startTime: Duration.zero, endTime: Duration.zero)];

  void upLyrics(String lrc) {
    if (lrc.startsWith("@lrc")) {
      lrc = lrc.substring("@lrc".length);
    }
    Duration start = Duration.zero;
    final durationReg = RegExp(r'\[(\d{1,2}):(\d{1,2})(\.\d{1,3})?\]');
    final temp = lrc.split("\n").map((l) {
      final m = durationReg.allMatches(l).toList();
      Duration end;
      int startIndex = 0;
      int endIndex = l.length;
      if (m.length > 0) {
        final startM = m.first;
        startIndex = startM.end;
        start = Duration(
          minutes: int.parse(startM.group(1)),
          seconds: int.parse(startM.group(2)),
          milliseconds: int.parse(startM.group(3)?.substring(1) ?? '0'),
        );
      }
      if (m.length > 1) {
        final endM = m.last;
        endIndex = endM.start;
        end = Duration(
          minutes: int.parse(endM.group(1)),
          seconds: int.parse(endM.group(2)),
          milliseconds: int.parse(endM.group(3) ?? '0'),
        );
      }
      return Lyric(
        l.substring(startIndex, endIndex),
        startTime: start,
        endTime: end,
      );
    });
    _lyrics.clear();
    if (temp.isEmpty) {
      return;
    }
    _lyrics.addAll(temp);
    for (var i = 0; i < _lyrics.length - 1; i++) {
      if (_lyrics[i].endTime == null) {
        _lyrics[i].endTime = _lyrics[i + 1].startTime;
      }
    }
    if (_lyrics.last.startTime.inSeconds == 0) {
      _lyrics.last.endTime = _lyrics.last.startTime;
    } else {
      _lyrics.last.endTime = _lyrics.last.startTime + Duration(seconds: 10);
    }
  }

  void share() {
    Share.share(
        "${searchItem.name} ${searchItem.author}(${searchItem.origin})\n${chapter.name}\n${chapter.url}");
  }
}

class AudioPage extends StatefulWidget {
  final SearchItem searchItem;

  const AudioPage({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  _AudioPageState createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> with TickerProviderStateMixin {
  Widget _audioPage;
  SearchItem searchItem;
  LyricController _lyricController;
  bool _showSelect = false;
  bool _showLyric = false;
  bool _showChapter = false;

  void closeChapter() {
    if (_showChapter && mounted) {
      _showChapter = false;
      setState(() {});
    }
  }

  void toggleChapter() {
    if (mounted) {
      _showChapter = !_showChapter;
      setState(() {});
    }
  }

  @override
  void initState() {
    _lyricController = LyricController(vsync: this)
      ..addListener(() {
        if (!mounted) return;
        if (_showSelect != _lyricController.isDragging) {
          setState(() {
            _showSelect = _lyricController.isDragging;
          });
        }
      });
    searchItem = widget.searchItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_audioPage == null) {
      _audioPage = FutureBuilder<bool>(
        future: ensureInitAudioHandler(searchItem),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            try {
              audioHandler.load(
                  searchItem, Provider.of<ContentProvider>(context, listen: false));
            } catch (e) {
              audioHandler.load(searchItem);
            }
            return _buildPage();
          }
          if (snapshot.hasError) return Scaffold(body: Text(snapshot.error.toString()));
          return LandingPage();
        },
      );
    }
    return GestureDetector(
      onTap: closeChapter,
      child: Stack(
        children: [
          _audioPage,
          if (_showChapter)
            UIChapterSelect(
              searchItem: searchItem,
              color: Colors.black38,
              fontColor: Colors.white70,
              border: BorderSide(color: Colors.white10, width: Global.borderSize),
              heightScale: 0.5,
              loadChapter: (index) {
                audioHandler.loadChapter(index);
                closeChapter();
              },
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _lyricController?.dispose();
    _audioPage = null;
    super.dispose();
  }

  Widget _buildPage() {
    final chapter = audioHandler.chapter;
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            if (!Utils.empty(audioHandler.cover))
              Container(
                height: double.infinity,
                width: double.infinity,
                child: Image.network(
                  audioHandler.cover,
                  fit: BoxFit.cover,
                  headers: audioHandler.headers,
                ),
              ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withAlpha(80)),
            ),
            SafeArea(
              child: Column(
                children: <Widget>[
                  StreamBuilder<MediaItem>(
                    stream: _audioHandler.mediaItem.stream,
                    builder: (BuildContext context, AsyncSnapshot<MediaItem> snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return _buildAppBar(chapter.name, chapter.time);
                      }
                      return _buildAppBar(
                          snapshot.data.title, snapshot.data.displaySubtitle);
                    },
                  ),
                  StreamBuilder<MediaItem>(
                    stream: _audioHandler.mediaItem.stream,
                    builder: (BuildContext context, AsyncSnapshot<MediaItem> snapshot) {
                      return StatefulBuilder(builder: (BuildContext context, setState) {
                        void toggleLyric() {
                          if (mounted) {
                            _showLyric = !_showLyric;
                            setState(() {});
                          }
                        }

                        if (_showLyric) {
                          _lyricController.progress = audioHandler.position;
                          return Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: LyricWidget(
                                    size: Size(double.infinity, double.infinity),
                                    controller: _lyricController,
                                    lyrics: audioHandler.lyrics,
                                    lyricStyle:
                                        TextStyle(color: Colors.white, fontSize: 16),
                                    currLyricStyle:
                                        TextStyle(color: Colors.red, fontSize: 18),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.close_outlined,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      tooltip: '关闭歌词',
                                      onPressed: toggleLyric),
                                ),
                                Offstage(
                                  offstage: !_showSelect,
                                  child: GestureDetector(
                                    onTap: () {
                                      //点击选择器后移动歌词到滑动位置;
                                      _lyricController.draggingComplete();
                                      audioHandler
                                          .seek(_lyricController.draggingProgress);
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.green,
                                          size: 30,
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        // _lyricController.progress = AudioService.position.;
                        else {
                          return Expanded(
                            child: Tooltip(
                              message: '点击切换显示歌词',
                              child: Center(
                                child: SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: AnimationRotateView(
                                    child: InkWell(
                                      onTap: toggleLyric,
                                      child: Utils.empty(audioHandler.cover)
                                          ? Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black26,
                                              ),
                                              child: Icon(Icons.audiotrack,
                                                  color: Colors.white30, size: 200),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    audioHandler.cover,
                                                    headers: audioHandler.headers,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      });
                    },
                  ),
                  SizedBox(height: 50),
                  _buildProgressBar(),
                  SizedBox(height: 10),
                  _buildBottomController(),
                  SizedBox(height: 25),
                ],
              ),
            ),
            if (_showLyric)
              SafeArea(
                child: Center(
                  child: Container(
                    height: 300,
                    alignment: Alignment.bottomCenter,
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontFamily: ESOTheme.staticFontFamily,
                        height: 1.75,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(chapter.name, style: TextStyle(fontSize: 15)),
                          Text(Utils.link(searchItem.origin, searchItem.name,
                                  divider: ' | ')
                              .link(searchItem.chapter)
                              .value),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(String name, String author) {
    final _iconTheme = Theme.of(context).primaryIconTheme;
    final _textTheme = Theme.of(context).primaryTextTheme;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      brightness: Brightness.dark,
      iconTheme: _iconTheme.copyWith(color: Colors.white70),
      textTheme: _textTheme.copyWith(
          headline6: _textTheme.headline6.copyWith(color: Colors.white70)),
      actionsIconTheme: _iconTheme.copyWith(color: Colors.white70),
      actions: [
        StatefulBuilder(
          builder: (context, _state) {
            bool isFav =
                SearchItemManager.isFavorite(searchItem.originTag, searchItem.url);
            return IconButton(
              icon: isFav ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
              iconSize: 21,
              tooltip: isFav ? "取消收藏" : "加入收藏",
              onPressed: () async {
                await SearchItemManager.toggleFavorite(searchItem);
                _state(() => null);
              },
            );
          },
        ),
        IconButton(
          onPressed: () {
            Utils.startPageWait(
                context,
                LaunchUrlWithWebview(
                  title: Utils.link(searchItem.origin, searchItem.name, divider: ' | ')
                      .link(searchItem.durChapter)
                      .value,
                  url: searchItem.chapters[searchItem.durChapterIndex].url,
                ));
          },
          icon: Icon(FIcons.book_open),
          tooltip: "在浏览器打开",
        ),
        IconButton(
          icon: Icon(FIcons.share_2),
          tooltip: "分享",
          onPressed: audioHandler.share,
        ),
      ],
      titleSpacing: 0,
      title: author == null || author.isEmpty
          ? Text(
              '$name',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '$author',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressBar() {
    final r = (Duration position, Duration duration, Duration buffer) => Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              child: Text(Utils.formatDuration(position),
                  style: TextStyle(color: Colors.white)),
              width: 52,
            ),
            Expanded(
              child: FlutterSlider(
                rightHandler: FlutterSliderHandler(
                  child: Container(
                    width: 12,
                    height: 12,
                    alignment: Alignment.center,
                    child: Icon(Icons.audiotrack, color: Colors.red, size: 8),
                  ),
                ),
                values: [
                  position.inMilliseconds.toDouble(),
                  buffer.inMilliseconds.toDouble()
                ],
                max: duration.inMilliseconds < 1 ? 1 : duration.inMilliseconds.toDouble(),
                min: 0,
                onDragging: (handlerIndex, lowerValue, upperValue) => audioHandler
                    .seek(Duration(milliseconds: (lowerValue as double).toInt())),
                handlerHeight: 12,
                handlerWidth: 12,
                handler: FlutterSliderHandler(
                  child: Container(
                    width: 12,
                    height: 12,
                    alignment: Alignment.center,
                    child: Icon(Icons.audiotrack, color: Colors.red, size: 8),
                  ),
                ),
                trackBar: FlutterSliderTrackBar(
                  inactiveTrackBar: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white54,
                  ),
                  activeTrackBar: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white70,
                  ),
                ),
                tooltip: FlutterSliderTooltip(
                  disableAnimation: true,
                  custom: (value) => Container(
                    color: Colors.black12,
                    padding: EdgeInsets.all(4),
                    child: Text(
                      Utils.formatDuration(
                          Duration(milliseconds: (value as double).toInt())),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  positionOffset:
                      FlutterSliderTooltipPositionOffset(left: -10, right: -10, top: -10),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(Utils.formatDuration(duration),
                  style: TextStyle(color: Colors.white)),
              width: 52,
            ),
          ],
        );
    return StreamBuilder(
      stream: _audioHandler.positionStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return r(
            _audioHandler.position ?? Duration.zero,
            _audioHandler.duration ?? Duration.zero,
            _audioHandler.bufferedPosition ?? Duration.zero);
      },
    );
  }

  Widget _buildBottomController() {
    // final _repeatMode = provider.repeatMode;
    return Container(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          StreamBuilder(
            stream: _audioHandler.repeatMode,
            builder: (BuildContext context, AsyncSnapshot _) {
              final map = audioHandler.getRepeatModeName();
              return IconButton(
                icon: Icon(
                  map.value,
                  color: Colors.white,
                ),
                iconSize: 26,
                tooltip: map.key,
                padding: EdgeInsets.zero,
                onPressed: audioHandler.toggleRepeatMode,
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.skip_previous,
              color: Colors.white,
              size: 26,
            ),
            onPressed: audioHandler.skipToPrevious,
            tooltip: '上一曲',
          ),
          StreamBuilder(
            stream: _audioHandler.playbackState.map((state) => state.playing).distinct(),
            builder: (BuildContext context, AsyncSnapshot _) {
              return IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  audioHandler.playing
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  color: Colors.white,
                  size: 46,
                ),
                onPressed: audioHandler.playOrPause,
                tooltip: audioHandler.playing ? '暂停' : '播放',
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.skip_next,
              color: Colors.white,
              size: 26,
            ),
            onPressed: audioHandler.skipToNext,
            tooltip: '下一曲',
          ),
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
            iconSize: 26,
            tooltip: "播放列表",
            onPressed: toggleChapter,
          ),
        ],
      ),
    );
  }

  final String defaultImage = _defaultBackgroundImage[
      Random().nextInt(_defaultBackgroundImage.length * 3) %
          _defaultBackgroundImage.length];

  static const List<String> _defaultBackgroundImage = <String>[
    "http://api.nmb.show/xiaojiejie1.php"
  ];
}
