import 'dart:io';

import 'package:dlna/dlna.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screen/screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../api/api_manager.dart';
import '../database/search_item.dart';
import '../database/search_item_manager.dart';
import '../model/audio_service.dart';
import '../utils.dart';
import '../utils/dlna_util.dart';

class VideoPage extends StatelessWidget {
  final SearchItem searchItem;
  const VideoPage({this.searchItem, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: ChangeNotifierProvider<VideoPageProvider>(
        create: (context) => VideoPageProvider(searchItem: searchItem),
        child: null,
        builder: (BuildContext context, child) {
          final isLoading =
              context.select((VideoPageProvider provider) => provider.isLoading);
          final showController =
              context.select((VideoPageProvider provider) => provider.showController);
          final hint = context.select((VideoPageProvider provider) => provider.hint);
          return Stack(
            children: [
              isLoading ? Container() : _buildPlayer(context),
              isLoading
                  ? Align(
                      alignment: Alignment.center,
                      child: _buildLoading(context),
                    )
                  : Container(),
              isLoading
                  ? Positioned(
                      left: 30,
                      bottom: 80,
                      right: 30,
                      child: _buildLoadingText(context),
                    )
                  : Container(),
              showController
                  ? Container(
                      padding: EdgeInsets.fromLTRB(
                          10, 10 + MediaQuery.of(context).padding.top, 10, 10),
                      color: Color(0x20000000),
                      child: _buildTopBar(context),
                    )
                  : Container(),
              showController
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                        color: Color(0x20000000),
                        child: _buildBottomBar(context),
                      ),
                    )
                  : Container(),
              hint == null
                  ? Container()
                  : Align(
                      alignment: Alignment.center,
                      child: hint,
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayer(BuildContext context) {
    final controller =
        context.select((VideoPageProvider provider) => provider.controller);
    final provider = Provider.of<VideoPageProvider>(context, listen: false);
    return GestureDetector(
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
      onDoubleTap: provider.playOrPause,
      onTap: provider.toggleControllerBar,
      onHorizontalDragStart: (details) => null,
      onHorizontalDragUpdate: (details) => null,
      onHorizontalDragEnd: (details) => null,
      onVerticalDragStart: (details) => null,
      onVerticalDragUpdate: (details) => null,
      onVerticalDragEnd: (details) => null,
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 20,
          width: 20,
          margin: EdgeInsets.only(bottom: 10),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(const Color(0xA0FFFFFF)),
            strokeWidth: 2,
          ),
        ),
        Text(
          context.select((VideoPageProvider provider) => provider.titleText),
          style: const TextStyle(
            color: const Color(0xD0FFFFFF),
            fontWeight: FontWeight.bold,
            fontSize: 12,
            height: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingText(BuildContext context) {
    context.select((VideoPageProvider provider) => provider.loadingText.length);
    const style = TextStyle(
      color: Color(0xB0FFFFFF),
      fontSize: 12,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: context
          .select((VideoPageProvider provider) => provider.loadingText)
          .map((s) => Text(
                s,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ))
          .toList(),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 20,
          child: IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Expanded(
          child: Text(
            context.select((VideoPageProvider provider) => provider.titleText),
            style: TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Consumer<VideoPageProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            provider.isLoading
                ? LinearProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(VideoProgressColors().playedColor),
                    backgroundColor: VideoProgressColors().backgroundColor,
                  )
                : VideoProgressIndicator(
                    provider.controller,
                    allowScrubbing: true,
                  ),
            Text(
              provider.isLoading
                  ? "--:-- / --:--"
                  : "${provider.position} / ${provider.duration}",
              style: TextStyle(fontSize: 10, color: Colors.white),
              textAlign: TextAlign.end,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  color: Colors.white,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.open_in_new),
                  onPressed: provider.openInNew,
                ),
                IconButton(
                  color: Colors.white,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.airplay),
                  onPressed: () => provider.openDLNA(context),
                ),
                IconButton(
                  color: Colors.white,
                  iconSize: 40,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.skip_previous),
                  onPressed: () => provider.parseContent(searchItem.durChapterIndex - 1),
                ),
                IconButton(
                  color: Colors.white,
                  iconSize: 40,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    !provider.isLoading && provider.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  onPressed: provider.playOrPause,
                ),
                IconButton(
                  color: Colors.white,
                  iconSize: 40,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.skip_next),
                  onPressed: () => provider.parseContent(searchItem.durChapterIndex + 1),
                ),
                IconButton(
                  color: Colors.white,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.screen_rotation),
                  onPressed: provider.screenRotation,
                ),
                IconButton(
                  color: Colors.white,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.zoom_out_map),
                  onPressed: provider.zoom,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class VideoPageProvider with ChangeNotifier {
  final SearchItem searchItem;
  String _titleText;
  String get titleText => _titleText;
  List<String> _content;
  List<String> get content => _content;

  final loadingText = <String>[];
  bool _disposed;

  VideoPlayerController _controller;
  VideoPlayerController get controller => _controller;
  bool get isPlaying => _controller.value.isPlaying;
  String get position => Utils.formatDuration(_controller.value.position);
  String get duration => Utils.formatDuration(_controller.value.duration);

  VideoPageProvider({@required this.searchItem}) {
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _titleText = "${searchItem.name} - ${searchItem.durChapter}";
    _screenAxis = Axis.horizontal;
    _disposed = false;
    setHorizontal();
    parseContent(null);
  }

  bool _isLoading;
  bool get isLoading => _isLoading != false;
  void parseContent(int chapterIndex) async {
    if (chapterIndex != null &&
        (_isLoading == true ||
            chapterIndex < 0 ||
            chapterIndex >= searchItem.chaptersCount ||
            chapterIndex == searchItem.durChapterIndex)) {
      return;
    }
    _isLoading = true;
    loadingText.clear();
    if (chapterIndex != null) {
      searchItem.durChapterIndex = chapterIndex;
      searchItem.durChapter = searchItem.chapters[chapterIndex].name;
      searchItem.durContentIndex = 1;
      _titleText = "${searchItem.name} - ${searchItem.durChapter}";
    }
    loadingText.add("开始解析...");
    await controller?.pause();
    notifyListeners();
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    SearchItemManager.saveSearchItem();
    if (_disposed) return;
    try {
      _content = await APIManager.getContent(searchItem.originTag,
          searchItem.chapters[chapterIndex ?? searchItem.durChapterIndex].url);
      if (_disposed) return;
      loadingText.add("播放地址 ${_content[0]}");
      loadingText.add("获取视频信息...");
      notifyListeners();

      _controller?.removeListener(listener);
      _controller?.dispose();
      if (_disposed) return;
      _controller = VideoPlayerController.network(_content[0]);
      notifyListeners();
      AudioService.stop();
      await _controller.initialize();
      _controller.seekTo(Duration(milliseconds: searchItem.durContentIndex));
      _controller.play();
      Screen.keepOn(true);
      _controller.addListener(listener);
      _lastShowControllerTime = DateTime.now();
      _isLoading = false;
      if (_disposed) _controller.dispose();
    } catch (e, st) {
      loadingText.add("错误 $e");
      loadingText.addAll("$st".split("\n").take(5));
      _isLoading = null;
      notifyListeners();
    }
  }

  DateTime _lastNotifyTime;
  listener() {
    if (_lastNotifyTime == null ||
        DateTime.now().difference(_lastNotifyTime).inMicroseconds > 1000) {
      _lastNotifyTime = DateTime.now();
      if (!isLoading) {
        if (showController &&
            DateTime.now()
                    .difference(_lastShowControllerTime)
                    .compareTo(_controllerDelay) >=
                0) {
          hideController();
        }
        if (_hint != null &&
            DateTime.now().difference(_lastShowHintTime).compareTo(_hintDelay) >= 0) {
          _hint = null;
        }
        searchItem.durContentIndex = _controller.value.position.inMilliseconds;
        searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
        SearchItemManager.saveSearchItem();
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    Screen.keepOn(false);
    controller?.dispose();
    loadingText.clear();
    if (Platform.isIOS) {
      setVertical();
    }
    resetRotation();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  void resetRotation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void setHorizontal() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void setVertical() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void openDLNA(BuildContext context) {
    if (_disposed || _content == null) return;
    _lastShowControllerTime = DateTime.now();
    DLNAUtil.instance.start(
      context,
      title: _titleText,
      url: _content[0],
      videoType: VideoObject.VIDEO_MP4,
      onPlay: playOrPause,
    );
  }

  void openInNew() {
    if (_disposed || _content == null) return;
    _lastShowControllerTime = DateTime.now();
    launch(_content[0]);
  }

  Widget _hint;
  Widget get hint => _hint;
  DateTime _lastShowHintTime;
  Duration _hintDelay = Duration(seconds: 1);
  void setHintText(String text) {
    _hint = Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
    _lastShowHintTime = DateTime.now();
    notifyListeners();
  }

  void _pause() async {
    await Screen.keepOn(false);
    await controller.pause();
    setHintText("已暂停");
  }

  void _play() async {
    setHintText("播放");
    await Screen.keepOn(true);
    await controller.play();
  }

  void playOrPause() {
    if (_disposed || isLoading) return;
    _lastShowControllerTime = DateTime.now();
    if (isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  bool _showController;
  bool get showController => _showController != false;
  DateTime _lastShowControllerTime;
  Duration _controllerDelay = Duration(seconds: 3);

  void toggleControllerBar() {
    if (showController) {
      hideController();
    } else {
      displayController();
    }
    notifyListeners();
  }

  void displayController() {
    _showController = true;
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _lastShowControllerTime = DateTime.now();
  }

  void hideController() {
    _showController = false;
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  void zoom() {
    // if (_disposed || isLoading) return;
    _lastShowControllerTime = DateTime.now();
    setHintText("暂无功能");
  }

  Axis _screenAxis;
  void screenRotation() {
    _lastShowControllerTime = DateTime.now();
    if (_screenAxis == Axis.horizontal) {
      setHintText("纵向");
      _screenAxis = Axis.vertical;
      setVertical();
    } else {
      setHintText("横向");
      _screenAxis = Axis.horizontal;
      setHorizontal();
    }
  }
}
