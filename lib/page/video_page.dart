import 'package:eso/database/search_item.dart';
import 'package:eso/model/video_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  final SearchItem searchItem;

  const VideoPage({
    this.searchItem,
    Key key,
  }) : super(key: key);
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  Widget page;
  VideoPageController __provider;
  @override
  Widget build(BuildContext context) {
    if (page == null) {
      page = buildPage();
    }
    return page;
  }

  @override
  void dispose() {
    __provider?.dispose();
    super.dispose();
  }

  Widget buildPage() {
    return ChangeNotifierProvider<VideoPageController>.value(
      value: VideoPageController(searchItem: widget.searchItem),
      child: Consumer<VideoPageController>(
        builder: (BuildContext context, VideoPageController provider, _) {
          __provider = provider;
          if (provider.content == null ||
              provider.controller == null ||
              provider.isLoading ||
              provider.isParsing) {
            String s = '加载失败!';
            if (provider.content == null) {
              s = '初始化';
            } else if (provider.isParsing) {
              s = '解析中';
            } else if (provider.isLoading) {
              s = '缓冲中';
            }
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            return Scaffold(
              body: Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  _buildTopRow(context, provider),
                  SizedBox(height: 30),
                  Text(s, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 30),
                  CircularProgressIndicator(),
                ],
              ),
            );
          }
          return Scaffold(
            body: Container(
              color: Colors.black,
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: AspectRatio(
                      aspectRatio: provider.asaspectRatiop,
                      child: VideoPlayer(provider.controller),
                    ),
                  ),
                  _buildControllers(context, provider),
                  provider.showChapter
                      ? UIChapterSelect(
                          loadChapter: provider.loadChapter,
                          searchItem: widget.searchItem,
                        )
                      : Container(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControllers(BuildContext context, VideoPageController provider) {
    if (provider.showController) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    } else {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
    return GestureDetector(
      onTap: () => provider.showController = !provider.showController,
      onDoubleTap: provider.playOrPause,
      onPanStart: (DragStartDetails details) {
        provider.initial = details.globalPosition.dx;
      },
      onPanUpdate: (DragUpdateDetails details) {
        provider.panSeconds =
            ((details.globalPosition.dx - provider.initial) ~/ 30) * 5;
        provider.showToastText(provider.panSeconds == 0
            ? '　0　'
            : provider.panSeconds > 0
                ? '　${provider.panSeconds}►'
                : '◄${-provider.panSeconds}　');
      },
      onPanEnd: provider.onPanEnd,
      child: Column(
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).padding.top),
          provider.showController
              ? _buildTopRow(context, provider)
              : Container(),
          Expanded(
            child: Container(
              child: provider.showToast
                  ? Center(
                      child: Text(
                        provider.toastText,
                        style: TextStyle(
                          fontSize: 60,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          letterSpacing: 3,
                          shadows: <Shadow>[
                            Shadow(
                              color: Colors.blue,
                              blurRadius: 1,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
              color: Colors.transparent,
            ),
          ),
          provider.showController
              ? _buildBottomRow(context, provider)
              : Container(),
        ],
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, VideoPageController provider) {
    return Container(
      width: double.infinity,
      color: Colors.black.withAlpha(25),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: <Widget>[
          InkWell(
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 26,
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              '${widget.searchItem.durChapter}'.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          InkWell(
            child: Icon(
              Icons.open_in_new,
              color: Colors.white,
              size: 26,
            ),
            onTap: provider.openWith,
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            child: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 26,
            ),
            onTap: () => provider.showChapter = !provider.showChapter,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context, VideoPageController provider) {
    return Container(
      width: double.infinity,
      color: Colors.black.withAlpha(25),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: <Widget>[
          InkWell(
            child: Icon(
              provider.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 26,
            ),
            onTap: provider.playOrPause,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: SeekBar(
              value: provider.positionSeconds.toDouble(),
              max: provider.seconds.toDouble(),
              backgroundColor: Colors.white54,
              progresseight: 4,
              afterDragShowSectionText: true,
              onValueChanged: (progress) =>
                  provider.seekTo(Duration(seconds: progress.value.toInt())),
              indicatorRadius: 5,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            '${provider.positionDuration}/${provider.duration}',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            child: Icon(
              Icons.screen_rotation,
              color: Colors.white,
              size: 26,
            ),
            onTap: provider.toggleRotation,
          ),
        ],
      ),
    );
  }
}
