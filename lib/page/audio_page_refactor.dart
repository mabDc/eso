import 'dart:ui';

// import 'package:audioplayers/audioplayers.dart';
import 'package:audio_service/audio_service.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/page/photo_view_page.dart';
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

AudioHandler _audioHandler;
AudioHandler get audioHandler => _audioHandler;

Future<bool> ensureInitAudioHandler() async {
  if (_audioHandler == null) {
    _audioHandler = await AudioService.init(
      builder: () => AudioHandler(),
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
// with QueueHandler, // mix in default queue callback implementations
// mix in default seek callback implementations

  final _player = AudioPlayer();
  bool get playing => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration;

  SearchItem _searchItem;
  SearchItem get searchItem => _searchItem;
  ChapterItem get chapter => searchItem.chapters[searchItem.durChapterIndex];
  final List<Lyric> lyrics = <Lyric>[];
  var close = false;
  String cover;
  Map<String, String> headers;
  bool get emptyCover => Utils.empty(cover);
  ContentProvider _contentProvider;

  AudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  // static final _item = MediaItem(
  //   id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
  //   album: "Science Friday",
  //   title: "A Salute To Head-Scratching Science",
  //   artist: "Science Friday and WNYC Studios",
  //   duration: const Duration(milliseconds: 5739820),
  //   artUri: Uri.parse(
  //       'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
  // );

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
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
      // queueIndex: event.currentIndex,
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

  // int get currentIndex => 0;

  String get genID => "${_searchItem.id}${_searchItem.durChapterIndex}";

  void upMediaItem({Duration duration}) {
    mediaItem.add(MediaItem(
      id: genID,
      title: chapter.name,
      album: searchItem.origin,
      artist: "${searchItem.name}(${searchItem.author})",
      artUri: Uri.tryParse(cover),
      artHeaders: headers,
      duration: duration,
    ));
  }

  Future<void> load(SearchItem searchItem,
      [ContentProvider contentProvider = null]) async {
    close = false;
    if (contentProvider != null) _contentProvider = contentProvider;
    if (_searchItem?.id != searchItem.id) {
      _searchItem = searchItem;
      if (emptyCover && !Utils.empty(_searchItem.cover)) {
        final i = PhotoItem.parse(_searchItem.cover);
        cover = i.url;
        headers = i.headers;
      }
      upMediaItem();
      loadChapter(_searchItem.durChapterIndex, true);
    } else {
      loadChapter(_searchItem.durChapterIndex);
    }
  }

  Future<void> loadChapter(int index, [bool forse = false]) async {
    if (!forse && _searchItem.durChapterIndex == index) {
      play();
      return;
    }
    _searchItem.durChapterIndex = index;
    _searchItem.durChapter = chapter.name;
    final result = await _contentProvider.loadChapter(index);
    final d = await _player.setUrl(result[0]);
    upMediaItem(duration: d);
    play();
    // todo
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
  void toggleLyric() {
    if (mounted) {
      _showLyric = !_showLyric;
      _audioPage = _buildPage();
      setState(() {});
    }
  }

  void closeChapter() {
    if (_showChapter && mounted) {
      _showChapter = false;
      _audioPage = _buildPage();
      setState(() {});
    }
  }

  void toggleChapter() {
    if (mounted) {
      _showChapter = !_showChapter;
      _audioPage = _buildPage();
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
        future: ensureInitAudioHandler(),
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) return _buildPage(Provider.of<ContentProvider>(context));
          if (snapshot.hasError) return Scaffold(body: Text(snapshot.error.toString()));
          return LandingPage();
        },
      );
    }
    return _audioPage;
  }

  @override
  void dispose() {
    _lyricController?.dispose();
    _audioPage = null;
    super.dispose();
  }

  Widget _buildPage([ContentProvider contentProvider = null]) {
    audioHandler.load(searchItem, contentProvider);
    final chapter = audioHandler.chapter;
    final cover = Utils.empty(chapter.cover) ? searchItem.cover : chapter.cover;
    return Scaffold(
      body: GestureDetector(
        onTap: closeChapter,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              if (!Utils.empty(cover))
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Image.network(
                    cover,
                    fit: BoxFit.cover,
                  ),
                ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(color: Colors.black.withAlpha(80)),
              ),
              SafeArea(
                child: Column(
                  children: <Widget>[
                    _buildAppBar(chapter.name, chapter.time),
                    if (_showLyric)
                      if (audioHandler.lyrics.isEmpty)
                        Expanded(
                          child: InkWell(
                            onTap: toggleLyric,
                            child: LyricWidget(
                              size: Size(double.infinity, double.infinity),
                              controller: _lyricController,
                              lyricStyle: TextStyle(color: Colors.white),
                              lyrics: <Lyric>[
                                Lyric(
                                  '加载中...',
                                  startTime: Duration.zero,
                                  endTime: Duration.zero,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        () {
                          // _lyricController.progress = AudioService.position.;
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
                        }()
                    else
                      Expanded(
                        child: Tooltip(
                          message: '点击切换显示歌词',
                          child: Center(
                            child: SizedBox(
                              width: 300,
                              height: 300,
                              child: AnimationRotateView(
                                child: InkWell(
                                  onTap: toggleLyric,
                                  child: Utils.empty(cover)
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
                                              image: NetworkImage(cover ?? ''),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
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
                ),
            ],
          ),
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
    final r = (Duration position, Duration duration) => Row(
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              child: Text(Utils.formatDuration(position),
                  style: TextStyle(color: Colors.white)),
              width: 52,
            ),
            Expanded(
              child: FlutterSlider(
                values: [position.inSeconds.toDouble()],
                max:
                    duration.inSeconds.toDouble() < 1 ? 1 : duration.inSeconds.toDouble(),
                min: 0,
                onDragging: (handlerIndex, lowerValue, upperValue) =>
                    audioHandler.seek(Duration(seconds: (lowerValue as double).toInt())),
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
                      Utils.formatDuration(Duration(seconds: (value as double).toInt())),
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
    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return r(snapshot.data ?? Duration.zero, _audioHandler.duration ?? Duration.zero);
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
          IconButton(
              icon: Icon(
                Icons.ac_unit,
                // _repeatMode == AudioService.REPEAT_FAVORITE
                //     ? Icons.restore
                //     : _repeatMode == AudioService.REPEAT_ALL
                //         ? Icons.repeat
                //         : _repeatMode == AudioService.REPEAT_ONE
                //             ? Icons.repeat_one
                //             : Icons.label_outline,
                color: Colors.white,
              ),
              iconSize: 26,
              // tooltip: AudioService.getRepeatName(_repeatMode),
              padding: EdgeInsets.zero,
              onPressed: () {} //audioHandler.switchRepeatMode,
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
