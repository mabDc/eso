import 'dart:io';

import 'package:dlna/dlna.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/audio_service.dart';
import 'package:eso/utils/dlna_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../utils.dart';

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
          final controller =
              context.select((VideoPageProvider provider) => provider.controller);
          return Stack(
            children: [
              _buildPlayer(context),
              controller == null
                  ? Align(
                      alignment: Alignment.center,
                      child: _buildLoading(context),
                    )
                  : Container(),
              controller == null
                  ? Positioned(
                      left: 30,
                      bottom: 80,
                      right: 30,
                      child: _buildLoadingText(context),
                    )
                  : Container(),
              Container(
                padding: EdgeInsets.fromLTRB(
                    10, 10 + MediaQuery.of(context).padding.top, 10, 10),
                color: Color(0x20000000),
                child: _buildTopBar(context),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
                  color: Color(0x20000000),
                  child: _buildBottomBar(context),
                ),
              ),
            ],
          );
        },
      ),
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

  Widget _buildPlayer(BuildContext context) {
    final controller =
        context.select((VideoPageProvider provider) => provider.controller);
    if (controller == null ||
        controller.value == null ||
        controller.value.aspectRatio == null) return Container();
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
        final controller = provider.controller;
        var text = "--:-- / --:--";
        if (controller != null && controller.value != null) {
          text =
              "${Utils.formatDuration(controller.value.position)} / ${Utils.formatDuration(controller.value.duration)}";
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            controller == null || controller.value == null
                ? Container()
                : VideoProgressIndicator(
                    controller,
                    allowScrubbing: true,
                  ),
            Text(
              text,
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
                    controller != null && controller.value.isPlaying
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
                  icon: Icon(Icons.airplay),
                  onPressed: () => provider.openDLNA(context),
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

  VideoPageProvider({@required this.searchItem}) {
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    _titleText = "${searchItem.name} - ${searchItem.durChapter}";
    _disposed = false;
    _showController = true;
    setHorizontal();
    parseContent(null);
  }

  bool _isLoading;
  bool get isLoading => _isLoading;

  void parseContent(int chapterIndex) async {
    if (chapterIndex != null &&
        (_isLoading ||
            chapterIndex < 0 ||
            chapterIndex >= searchItem.chaptersCount ||
            chapterIndex == searchItem.durChapterIndex)) {
      return;
    }
    _isLoading = true;
    loadingText.clear();
    loadingText.add("开始解析...");
    notifyListeners();
    if (_disposed) return;
    try {
      _content = await APIManager.getContent(searchItem.originTag,
          searchItem.chapters[chapterIndex ?? searchItem.durChapterIndex].url);
      if (_disposed) return;
      loadingText.add("得到地址 ${_content[0]}");
      loadingText.add("初始化播放器...");
      notifyListeners();

      if (chapterIndex != null) {
        searchItem.durChapterIndex = chapterIndex;
        searchItem.durChapter = searchItem.chapters[chapterIndex].name;
        searchItem.durContentIndex = 1;
      }
      searchItem.lastReadTime = DateTime.now().microsecondsSinceEpoch;
      await SearchItemManager.saveSearchItem();
      _controller?.removeListener(listener);
      _controller?.dispose();
      if (_disposed) return;
      _controller = VideoPlayerController.network(_content[0]);
      _isLoading = false;
      AudioService.stop();
      await _controller.initialize();
      _controller.seekTo(Duration(milliseconds: searchItem.durContentIndex));
      _controller.addListener(listener);
      if (_disposed) _controller.dispose();
      _controller.play();
      loadingText.add("开始缓冲...");
    } catch (e, st) {
      loadingText.add("错误 $e");
      loadingText.addAll("$st".split("\n").take(5));
      notifyListeners();
    }
  }

  DateTime _lastNotifyTime;
  listener() {
    if (_lastNotifyTime == null) {
      _lastNotifyTime = DateTime.now();
      notifyListeners();
    } else if (DateTime.now().difference(_lastNotifyTime).inMicroseconds > 1000) {
      _lastNotifyTime = DateTime.now();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    controller?.dispose();
    loadingText.clear();
    if (Platform.isIOS) {
      setVertical();
    }
    reset();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  void reset() {
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
    launch(_content[0]);
  }

  Widget _hint;
  Widget get hint => _hint;

  void _pause() {
    _hint = Text(
      "暂停",
      style: TextStyle(color: Colors.white),
    );
    controller.pause();
  }

  void _play() {
    _hint = Text(
      "播放",
      style: TextStyle(color: Colors.white),
    );
    controller.play();
  }

  void playOrPause() {
    if (_disposed || _content == null || controller == null || controller.value == null)
      return;
    if (controller.value.isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  bool _showController;
  bool get showController => _showController;

  void toggleControllerBar() {
    if (_showController) {
      _showController = false;
      SystemChrome.setEnabledSystemUIOverlays([]);
    } else {
      _showController = true;
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    }
    notifyListeners();
  }
}
