import 'package:eso/database/search_item.dart';
import 'package:eso/model/video_page_controller.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:eso/ui/ui_chapter_select.dart';
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
              provider.parseFailure ||
              provider.isLoading ||
              provider.isParsing) {
            String s = '加载失败!';
            if (provider.content == null) {
              s = '初始化...';
            } else if (provider.isParsing) {
              s = '正在解析...';
            } else if (provider.isLoading) {
              s = '正在缓冲...\n\n${provider.content?.join('\n')}';
            }
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            return Scaffold(
              body: Column(
                children: <Widget>[
                  AnnotatedRegion<SystemUiOverlayStyle>(
                    value: SystemUiOverlayStyle.light,
                    child: _buildTopRow(context, provider),
                  ),
                  SizedBox(height: 30),
                  Text(s, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 30),
                  CupertinoActivityIndicator(),
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
                      aspectRatio: provider.aspectRatio,
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
        provider.panSeconds = ((details.globalPosition.dx - provider.initial) ~/ 30) * 5;
        provider.showToastText(provider.panSeconds == 0
            ? '　0　'
            : provider.panSeconds > 0
                ? '　${provider.panSeconds}►'
                : '◄${-provider.panSeconds}　');
      },
      onPanEnd: provider.onPanEnd,
      child: Column(
        children: <Widget>[
          provider.showController ? _buildTopRow(context, provider) : Container(),
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
          provider.showController ? _buildBottomRow(context, provider) : Container(),
        ],
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, VideoPageController provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(0x40000000),
            Color(0x90000000),
            Color(0xB0000000),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      padding: EdgeInsets.fromLTRB(12, 4 + MediaQuery.of(context).padding.top, 12, 4),
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
              Icons.airplay,
              color: Colors.white,
              size: 26,
            ),
            onTap: () => provider.openDLNA(context),
          ),
          SizedBox(
            width: 10,
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
    var now = provider.positionSeconds;
    if (now < 0) {
      now = 0;
    } else if (now > provider.seconds) {
      now = provider.seconds;
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Color(0x40000000),
            Color(0x90000000),
            Color(0xB0000000),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
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
            child: FlutterSlider(
              values: [now.toDouble()],
              min: 0,
              max: provider.seconds.toDouble(),
              onDragging: (handlerIndex, lowerValue, upperValue) =>
                  provider.seekTo(Duration(seconds: (lowerValue as double).toInt())),
              handlerHeight: 12,
              handlerWidth: 12,
              handler: FlutterSliderHandler(
                child: Container(
                  width: 12,
                  height: 12,
                  alignment: Alignment.center,
                  child: Icon(Icons.videocam, color: Colors.green, size: 12),
                ),
              ),
              touchSize: 30,
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
                  color: Colors.black26,
                  padding: EdgeInsets.all(4),
                  child: Text(
                    provider.getTimeString((value as double).toInt()),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                positionOffset: FlutterSliderTooltipPositionOffset(left: -10, right: -10),
              ),
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
