import 'dart:io';
import 'dart:ui';

import 'package:dlna/dlna.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/utils/flutter_slider.dart';
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
import '../global.dart';
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
            final provider = Provider.of<VideoPageProvider>(context, listen: false);
            final isLoading =
                context.select((VideoPageProvider provider) => provider.isLoading);
            final showController =
                context.select((VideoPageProvider provider) => provider.showController);
            final hint = context.select((VideoPageProvider provider) => provider.hint);
            final showChapter =
                context.select((VideoPageProvider provider) => provider.showChapter);
            return Stack(
              children: [
                if (!isLoading) _buildPlayer(context),
                if (isLoading)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 120),
                      child: _buildLoading(context),
                    ),
                  ),
                if (isLoading)
                  Positioned(
                    left: 30,
                    bottom: 80,
                    right: 30,
                    child: _buildLoadingText(context),
                  ),
                if (showController)
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        10, 10 + MediaQuery.of(context).padding.top, 10, 10),
                    color: Color(0x20000000),
                    child: _buildTopBar(context),
                  ),
                if (showController)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                      color: Color(0x20000000),
                      child: _buildBottomBar(context),
                    ),
                  ),
                if (showChapter)
                  UIChapterSelect(
                    loadChapter: (index) => provider.loadChapter(index),
                    searchItem: searchItem,
                    color: Colors.black45,
                    fontColor: Colors.white70,
                    border: BorderSide(color: Colors.white12, width: Global.borderSize),
                    heightScale: 0.6,
                  ),
                if (hint != null)
                  Align(
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
    context.select((VideoPageProvider provider) => provider.aspectRatio);
    final provider = Provider.of<VideoPageProvider>(context, listen: false);
    return GestureDetector(
      child: Container(
        // 增加color才能使全屏手势生效
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: provider.aspectRatio == VideoAspectRatio.full ||
                provider.getAspectRatio() == 0
            ? VideoPlayer(controller)
            : AspectRatio(
                aspectRatio: provider.getAspectRatio(),
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
    final provider = Provider.of<VideoPageProvider>(context, listen: false);
    final vertical = context
        .select((VideoPageProvider provider) => provider.screenAxis == Axis.vertical);
    return Row(
      children: [
        Container(
          height: 20,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.white,
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
        Consumer<VideoPageProvider>(
          builder: (context, provider, child) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "后台播放",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
              Container(
                height: 20,
                child: Switch(
                  activeColor: Colors.redAccent,
                  activeTrackColor: Colors.red,
                  inactiveTrackColor: Colors.grey,
                  value: provider.allowPlaybackground,
                  onChanged: (value) => provider.allowPlaybackground = value,
                ),
              ),
            ],
          ),
        ),
        if (vertical)
          IconButton(
            color: Colors.white,
            iconSize: 20,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.airplay),
            onPressed: () => provider.openDLNA(context),
            tooltip: "DLNA投屏",
          ),
        if (vertical)
          IconButton(
            color: Colors.white,
            iconSize: 20,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.zoom_out_map),
            onPressed: provider.zoom,
            tooltip: "缩放",
          ),
        Container(
          height: 20,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.format_list_bulleted, size: 20),
            onPressed: () => provider.toggleChapterList(),
            color: Colors.white,
            tooltip: "节目列表",
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Consumer<VideoPageProvider>(
      builder: (context, provider, child) {
        final value = provider.isLoading ? 0 : provider.position.inSeconds.toDouble();
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              provider.isLoading
                  ? LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          VideoProgressColors().playedColor),
                      backgroundColor: VideoProgressColors().backgroundColor,
                    )
                  : FlutterSlider(
                      values: [value > 0 ? value : 0],
                      min: 0,
                      max: provider.duration.inSeconds.toDouble(),
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        provider.setHintText(
                            "跳转至  " +
                                Utils.formatDuration(
                                    Duration(seconds: (lowerValue as double).toInt())),
                            true);
                        provider.controller
                            .seekTo(Duration(seconds: (lowerValue as double).toInt()));
                      },
                      handlerHeight: 12,
                      handlerWidth: 12,
                      handler: FlutterSliderHandler(
                        child: Container(
                          width: 12,
                          height: 12,
                          alignment: Alignment.center,
                          child: Icon(Icons.videocam, color: Colors.red, size: 8),
                        ),
                      ),
                      touchSize: 20,
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
                      tooltip: FlutterSliderTooltip(disabled: true),
                    ),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  provider.isLoading
                      ? "" //"--:-- / --:--"
                      : "${provider.positionString} / ${provider.durationString}",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                  textAlign: TextAlign.end,
                ),
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
                    tooltip: "使用其他播放器打开",
                  ),
                  if (provider.screenAxis == Axis.horizontal)
                    IconButton(
                      color: Colors.white,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.airplay),
                      onPressed: () => provider.openDLNA(context),
                      tooltip: "DLNA投屏",
                    ),
                  IconButton(
                    color: Colors.white,
                    iconSize: 25,
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
                    iconSize: 25,
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.skip_next),
                    onPressed: () =>
                        provider.parseContent(searchItem.durChapterIndex + 1),
                    tooltip: "下一集",
                  ),
                  if (provider.screenAxis == Axis.horizontal)
                    IconButton(
                      color: Colors.white,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.zoom_out_map),
                      onPressed: provider.zoom,
                      tooltip: "缩放",
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
              )
            ],
          ),
        );
      },
    );
  }
}

class VideoPageProvider with ChangeNotifier, WidgetsBindingObserver {
  bool _allowPlaybackground;
  bool get allowPlaybackground => _allowPlaybackground == true;
  set allowPlaybackground(bool value) {
    if (_allowPlaybackground != value) {
      _allowPlaybackground = value;
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final isPlaying = _controller?.value?.isPlaying;
    switch (state) {
      case AppLifecycleState.paused:
        if (allowPlaybackground && isPlaying == true) {
          (() async {
            for (final _ in List.generate(10, (index) => index)) {
              await Future.delayed(Duration(milliseconds: 50));
              if (_controller?.value?.isPlaying != true) {
                await _controller?.play();
              }
            }
          })();
        }
        break;
      default:
    }
  }

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
  Duration get position => _controller.value.position;
  String get positionString => Utils.formatDuration(_controller.value.position);
  Duration get duration => _controller.value.duration;
  String get durationString => Utils.formatDuration(_controller.value.duration);

  VideoPageProvider({@required this.searchItem}) {
    WidgetsBinding.instance.addObserver(this);
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _titleText = "${searchItem.name} - ${searchItem.durChapter}";
    _screenAxis = Axis.horizontal;
    _disposed = false;
    _aspectRatio = VideoAspectRatio.uninit;
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
    _controller?.removeListener(_listener);
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
    () async {
      searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
      await SearchItemManager.saveSearchItem();
      HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
      await HistoryItemManager.saveHistoryItem();
    }();
    if (_disposed) return;
    try {
      _content = await APIManager.getContent(searchItem.originTag,
          searchItem.chapters[chapterIndex ?? searchItem.durChapterIndex].url);
      if (_content.isEmpty || _content.first.isEmpty) {
        _content = null;
        _isLoading = null;
        loadingText.add("错误 内容为空！");
        _controller?.dispose();
        notifyListeners();
        return;
      }
      if (_disposed) return;
      if (Global.isDesktop) {
        loadingText.add("播放地址 ${_content[0].split("").join("\u200B")}");
        loadingText.add("window或macos下将自动跳转浏览器播放，也可以手动点击左下角[使用其他播放器打开]");
        notifyListeners();
        launch("http://www.m3u8player.top/?play=${content[0]}");
        _isLoading = null;
        return;
      }
      loadingText.add("播放地址 ${_content[0].split("").join("\u200B")}");
      loadingText.add("获取视频信息...");
      notifyListeners();
      _controller?.dispose();
      if (_disposed) return;
      _controller = VideoPlayerController.network(_content[0]);
      if (_aspectRatio == VideoAspectRatio.uninit) {
        _aspectRatio = VideoAspectRatio.auto;
      }
      notifyListeners();
      AudioService.stop();
      await _controller.initialize();
      _controller.seekTo(Duration(milliseconds: searchItem.durContentIndex));
      _controller.play();
      Screen.keepOn(true);
      _controller.addListener(_listener);
      _controllerTime = DateTime.now();
      _isLoading = false;
      if (_disposed) _controller?.dispose();
    } catch (e, st) {
      loadingText.add("错误 $e");
      loadingText.addAll("$st".split("\n").take(6));
      _isLoading = null;
      notifyListeners();
      _controller?.dispose();
      _content = null;
      return;
    }
  }

  DateTime _lastNotifyTime;
  _listener() {
    if (_lastNotifyTime == null ||
        DateTime.now().difference(_lastNotifyTime).inMicroseconds > 1000) {
      _lastNotifyTime = DateTime.now();
      if (showController &&
          DateTime.now().difference(_controllerTime).compareTo(_controllerDelay) >= 0) {
        hideController();
        _showChapter = false;
      }
      searchItem.durContentIndex = _controller.value.position.inMilliseconds;
      searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
      SearchItemManager.saveSearchItem();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isIOS) {
      setVertical();
    }
    resetRotation();
    _disposed = true;
    if (controller != null) {
      searchItem.durContentIndex = _controller.value.position.inMilliseconds;
      controller.removeListener(_listener);
      controller.pause();
      controller.dispose();
    }
    () async {
      searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
      await SearchItemManager.saveSearchItem();
      HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
      await HistoryItemManager.saveHistoryItem();
    }();
    if (Platform.isIOS || Platform.isAndroid) {
      Screen.keepOn(false);
      if (Platform.isAndroid) {
        Screen.setBrightness(-1);
      }
    }
    loadingText.clear();
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
    if (Global.isDesktop) {
      launch("http://www.m3u8player.top/?play=${content[0]}");
      return;
    }
    _controllerTime = DateTime.now();
    launch(_content[0]);
  }

  Widget _hint;
  Widget get hint => _hint;
  DateTime _hintTime;
  void autoHideHint() {
    _hintTime = DateTime.now();
    const _hintDelay = Duration(seconds: 2);
    Future.delayed(_hintDelay, () {
      if (DateTime.now().difference(_hintTime).compareTo(_hintDelay) >= 0) {
        _hint = null;
        notifyListeners();
      }
    });
  }

  void setHintText(String text, [bool updateControllerTime = false]) {
    _hint = Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        height: 1.5,
      ),
    );
    if (updateControllerTime) {
      _controllerTime = DateTime.now();
    }
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
  bool _showChapter;
  bool get showChapter => _showChapter ?? false;
  DateTime _controllerTime;
  final _controllerDelay = Duration(seconds: 4);

  void toggleControllerBar() {
    if (showChapter == true) {
      hideController();
      toggleChapterList();
      return;
    }
    if (showController) {
      hideController();
    } else {
      displayController();
    }
    notifyListeners();
  }

  void toggleChapterList() {
    if (showChapter) {
      _showChapter = false;
    } else {
      hideController();
      _showChapter = true;
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

  VideoAspectRatio _aspectRatio;
  VideoAspectRatio get aspectRatio => _aspectRatio;
  double getAspectRatio() {
    switch (_aspectRatio) {
      case VideoAspectRatio.auto:
        return controller?.value?.aspectRatio ?? 16 / 9;
      case VideoAspectRatio.a169:
        return 16 / 9;
      case VideoAspectRatio.a43:
        return 4 / 3;
      case VideoAspectRatio.a916:
        return 9 / 16;
      default:
        return 0;
    }
  }

  void zoom() {
    // if (_disposed || isLoading) return;
    _controllerTime = DateTime.now();
    switch (_aspectRatio) {
      case VideoAspectRatio.auto:
        _aspectRatio = VideoAspectRatio.full;
        setHintText('充满');
        break;
      case VideoAspectRatio.full:
        _aspectRatio = VideoAspectRatio.a169;
        setHintText('16 : 9');
        break;
      case VideoAspectRatio.a169:
        _aspectRatio = VideoAspectRatio.a43;
        setHintText('4 : 3');
        break;
      case VideoAspectRatio.a43:
        _aspectRatio = VideoAspectRatio.a916;
        setHintText('9 : 16');
        break;
      case VideoAspectRatio.a916:
        _aspectRatio = VideoAspectRatio.auto;
        setHintText('自动');
        break;
      default:
        break;
    }
  }

  void loadChapter(int index) {
    parseContent(index);
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
    _gesturePosition = position + d;
    final prefix = d.compareTo(Duration.zero) < 0 ? "-" : "+";
    setHintText(
        "${Utils.formatDuration(_gesturePosition)} / $positionString\n[ $prefix ${Utils.formatDuration(d)} ]");
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

enum VideoAspectRatio {
  uninit, // 未初始化
  auto, // 自动
  full, // 充满
  a43, // 4：3
  a169, // 16：9
  a916, // 9：16
}
