import 'dart:io';
import 'dart:ui';

import 'package:dlna/dlna.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: ChangeNotifierProvider<VideoPageProvider>(
          create: (context) => VideoPageProvider(searchItem: searchItem),
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
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 120),
                          child: _buildLoading(context),
                        ),
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
                            10, 10 + MediaQuery.of(context).padding.top, 0, 10),
                        color: Color(0x20000000),
                        child: _buildTopBar(context),
                      )
                    : Container(),
                showController
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
                          color: Color(0x20000000),
                          child: _buildBottomBar(context),
                        ),
                      )
                    : Container(),
                hint == null
                    ? Container()
                    : Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0x20000000),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: hint,
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context) {
    final controller =
        context.select((VideoPageProvider provider) => provider.controller);
    final provider = Provider.of<VideoPageProvider>(context, listen: false);
    return GestureDetector(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
      onDoubleTap: provider.playOrPause,
      onTap: provider.toggleControllerBar,
      onHorizontalDragStart: provider.onHorizontalDragStart,
      onHorizontalDragUpdate: provider.onHorizontalDragUpdate,
      onHorizontalDragEnd: provider.onHorizontalDragEnd,
      onVerticalDragStart: provider.onVerticalDragStart,
      onVerticalDragUpdate: provider.onVerticalDragUpdate,
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
            tooltip: "返回",
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
            provider.screenAxis == Axis.horizontal
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        color: Colors.white,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.open_in_new),
                        onPressed: provider.openInNew,
                        tooltip: "使用其他播放器打开",
                      ),
                      IconButton(
                        color: Colors.white,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.airplay),
                        onPressed: () => provider.openDLNA(context),
                        tooltip: "DLNA",
                      ),
                      IconButton(
                        color: Colors.white,
                        iconSize: 40,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.skip_previous),
                        onPressed: () =>
                            provider.parseContent(searchItem.durChapterIndex - 1),
                        tooltip: "上一集",
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
                        tooltip: !provider.isLoading && provider.isPlaying ? "暂停" : "播放",
                      ),
                      IconButton(
                        color: Colors.white,
                        iconSize: 40,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.skip_next),
                        onPressed: () =>
                            provider.parseContent(searchItem.durChapterIndex + 1),
                        tooltip: "下一集",
                      ),
                      IconButton(
                        color: Colors.white,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.screen_rotation),
                        onPressed: provider.screenRotation,
                        tooltip: "旋转",
                      ),
                      IconButton(
                        color: Colors.white,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.zoom_out_map),
                        onPressed: provider.zoom,
                        tooltip: "缩放",
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        color: Colors.white,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.airplay),
                        onPressed: () => provider.openDLNA(context),
                        tooltip: "DLNA",
                      ),
                      IconButton(
                        color: Colors.white,
                        iconSize: 40,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.skip_previous),
                        onPressed: () =>
                            provider.parseContent(searchItem.durChapterIndex - 1),
                        tooltip: "上一集",
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
                        tooltip: !provider.isLoading && provider.isPlaying ? "暂停" : "播放",
                      ),
                      IconButton(
                        color: Colors.white,
                        iconSize: 40,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.skip_next),
                        onPressed: () =>
                            provider.parseContent(searchItem.durChapterIndex + 1),
                        tooltip: "下一集",
                      ),
                      IconButton(
                        color: Colors.white,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.screen_rotation),
                        onPressed: provider.screenRotation,
                        tooltip: "旋转",
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
    _hint = null;
    _controller?.removeListener(listener);
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
      if (_content.isEmpty) {
        _content = null;
        _isLoading = null;
        loadingText.add("错误 内容为空！");
        _controller?.dispose();
        notifyListeners();
        return;
      }
      if (_disposed) return;
      loadingText.add("播放地址 ${_content[0].split("").join("\u200B")}");
      loadingText.add("获取视频信息...");
      notifyListeners();
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
      _controllerTime = DateTime.now();
      _isLoading = false;
      if (_disposed) _controller.dispose();
    } catch (e, st) {
      loadingText.add("错误 $e");
      loadingText.addAll("$st".split("\n").take(5));
      _isLoading = null;
      notifyListeners();
      _controller?.dispose();
    }
  }

  DateTime _lastNotifyTime;
  listener() {
    if (_lastNotifyTime == null ||
        DateTime.now().difference(_lastNotifyTime).inMicroseconds > 1000) {
      _lastNotifyTime = DateTime.now();
      if (showController &&
          DateTime.now().difference(_controllerTime).compareTo(_controllerDelay) >= 0) {
        hideController();
      }
      searchItem.durContentIndex = _controller.value.position.inMilliseconds;
      searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
      SearchItemManager.saveSearchItem();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    controller.pause();
    Screen.keepOn(false);
    Screen.setBrightness(-1);
    searchItem.durContentIndex = _controller.value.position.inMilliseconds;
    searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
    SearchItemManager.saveSearchItem();
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
    _controllerTime = DateTime.now();
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
    _controllerTime = DateTime.now();
    launch(_content[0]);
  }

  Widget _hint;
  Widget get hint => _hint;
  DateTime _hintTime;
  final _hintDelay = Duration(seconds: 1);
  void autoHideHint() {
    Future.delayed(_hintDelay, () {
      if (DateTime.now().difference(_hintTime).compareTo(_hintDelay) >= 0) {
        _hint = null;
        notifyListeners();
      }
    });
  }

  void setHintText(String text) {
    _hint = Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        height: 1.5,
      ),
    );
    _hintTime = DateTime.now();
    notifyListeners();
    autoHideHint();
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
    if (_isLoading == null) {
      parseContent(null);
    }
    if (_disposed || isLoading) return;
    _controllerTime = DateTime.now();
    if (isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  bool _showController;
  bool get showController => _showController != false;
  DateTime _controllerTime;
  final _controllerDelay = Duration(seconds: 4);

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
    _controllerTime = DateTime.now();
  }

  void hideController() {
    _showController = false;
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  void zoom() {
    // if (_disposed || isLoading) return;
    _controllerTime = DateTime.now();
    setHintText("暂无功能");
  }

  Axis _screenAxis;
  Axis get screenAxis => _screenAxis;
  void screenRotation() {
    _controllerTime = DateTime.now();
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

  /// 手势处理
  double _dragStartPosition;
  Duration _gesturePosition;
  bool _draging;

  void setHintTextWithIcon(num value, IconData icon) {
    _hint = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.7),
              size: 18,
            ),
            SizedBox(width: 10),
            Container(
              width: 100,
              child: LinearProgressIndicator(
                value: value,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0x8FFF2020)),
                backgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
        Text(
          (value * 100).toStringAsFixed(0),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            height: 1.5,
          ),
        )
      ],
    );
    _hintTime = DateTime.now();
    notifyListeners();
    autoHideHint();
  }

  void onHorizontalDragStart(DragStartDetails details) =>
      _dragStartPosition = details.globalPosition.dx;

  void onHorizontalDragEnd(DragEndDetails details) {
    _controller.seekTo(_gesturePosition);
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    final d = Duration(seconds: (details.globalPosition.dx - _dragStartPosition) ~/ 10);
    _gesturePosition = _controller.value.position + d;
    final prefix = d.compareTo(Duration.zero) < 0 ? "-" : "+";
    setHintText(
        "${Utils.formatDuration(_gesturePosition)} / $duration\n[ $prefix ${Utils.formatDuration(d)} ]");
  }

  void onVerticalDragStart(DragStartDetails details) =>
      _dragStartPosition = details.globalPosition.dy;

  void onVerticalDragUpdate(DragUpdateDetails details) async {
    if (_draging == true) return;
    _draging = true;
    double number = (_dragStartPosition - details.globalPosition.dy) / 200;
    if (details.globalPosition.dx < (_screenAxis == Axis.horizontal ? 400 : 200)) {
      IconData icon = OMIcons.brightnessLow;
      var brightness = await Screen.brightness;
      if (brightness > 1) {
        brightness = 0.5;
      }
      brightness += number;
      if (brightness < 0) {
        brightness = 0.0;
      } else if (brightness > 1) {
        brightness = 1.0;
      }
      if (brightness <= 0.25) {
        icon = Icons.brightness_low;
      } else if (brightness < 0.5) {
        icon = Icons.brightness_medium;
      } else {
        icon = Icons.brightness_high;
      }
      setHintTextWithIcon(brightness, icon);
      await Screen.setBrightness(brightness);
    } else {
      IconData icon = OMIcons.volumeMute;
      var vol = _controller.value.volume + number;
      if (vol <= 0) {
        icon = OMIcons.volumeOff;
        vol = 0.0;
      } else if (vol < 0.2) {
        icon = OMIcons.volumeMute;
      } else if (vol < 0.7) {
        icon = OMIcons.volumeDown;
      } else {
        icon = OMIcons.volumeUp;
      }
      if (vol > 1) {
        vol = 1;
      }
      setHintTextWithIcon(vol, icon);
      await _controller.setVolume(vol);
    }

    /// 手势调节正常运作核心代码就是这句了
    _dragStartPosition = details.globalPosition.dy;
    _draging = false;
  }
}
