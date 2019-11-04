import 'package:eso/database/search_item.dart';
import 'package:eso/model/video_page_controller.dart';
import 'package:eso/page/langding_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chewie/chewie.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart';
import 'package:video_player/video_player.dart';
import '../model/custom_chewie_provider.dart';

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
  VideoPageController __pageController;
  @override
  Widget build(BuildContext context) {
    if (page == null) {
      page = buildPage();
    }
    return page;
  }

  @override
  void dispose() {
    __pageController?.dispose();
    super.dispose();
  }

  Widget buildPage() {
    return ChangeNotifierProvider<VideoPageController>.value(
      value: VideoPageController(searchItem: widget.searchItem),
      child: Consumer<VideoPageController>(
        builder: (BuildContext context, VideoPageController pageController, _) {
          __pageController = pageController;
          if (pageController.content == null) {
            return LandingPage();
          }
          if (pageController.controller == null) {
            return Scaffold(
              body: Text(
                '加载失败',
                style: TextStyle(fontSize: 30),
              ),
            );
          }
          return Scaffold(
            body: Column(
              children: <Widget>[
                Chewie(controller: pageController.controller),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CustomChewieController extends StatelessWidget {
  final VideoPlayerController controller;
  final VideoPlayerController audioController;
  final SearchItem searchItem;
  final Function(int index) loadChapter;
  CustomChewieController({
    @required this.controller,
    this.audioController,
    this.searchItem,
    this.loadChapter,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: CustomChewieProvider(
        controller: controller,
        audioController: audioController,
      ),
      child: Consumer<CustomChewieProvider>(
        builder: (BuildContext context, CustomChewieProvider provider, _) {
          return _buildControllers(context, provider);
        },
      ),
    );
  }

  Widget _buildControllers(
      BuildContext context, CustomChewieProvider provider) {
    return GestureDetector(
      onTap: () => provider.showController = !provider.showController,
      onDoubleTap: provider.playOrpause,
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
      onPanEnd: (DragEndDetails details) {
        provider.initial = 0.0;
        if (provider.panSeconds.abs() > 1) {
          provider.seekTo(provider.positionSeconds + provider.panSeconds);
        }
      },
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              ChewieController.of(context).isFullScreen
                  ? Container()
                  : SizedBox(height: MediaQuery.of(context).padding.top),
              provider.showController
                  ? Container(
                      width: double.infinity,
                      color: Colors.black.withAlpha(25),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: _buildTopRow(context, provider),
                    )
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
                              color: Colors.white70,
                              letterSpacing: 3,
                            ),
                          ),
                        )
                      : null,
                  color: Colors.transparent,
                ),
              ),
              provider.showController
                  ? Container(
                      width: double.infinity,
                      color: Colors.black.withAlpha(25),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: _buildBottomRow(context, provider),
                    )
                  : Container(),
            ],
          ),
          provider.showChapter
              ? UIChapterSelect(
                  loadChapter: (int index) {
                    if (ChewieController.of(context).isFullScreen) {
                      ChewieController.of(context).toggleFullScreen();
                    }
                    loadChapter(index);
                  },
                  searchItem: searchItem,
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, CustomChewieProvider provider) {
    return Row(
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
          width: 6,
        ),
        Expanded(
          child: Text(
            '${searchItem.durChapter}'.trim(),
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
            Icons.more_vert,
            color: Colors.white,
            size: 26,
          ),
          onTap: () => provider.showChapter = !provider.showChapter,
        ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context, CustomChewieProvider provider) {
    return Row(
      children: <Widget>[
        InkWell(
          child: Icon(
            provider.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 26,
          ),
          onTap: provider.playOrpause,
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          child: SeekBar(
            value: provider.positionSeconds.toDouble(),
            max: provider.seconds.toDouble(),
            backgroundColor: Colors.white54,
            progresseight: 4,
            afterDragShowSectionText: true,
            onValueChanged: (value) => provider.seekTo(value.value.toInt()),
            indicatorRadius: 5,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          '${provider.positionDuration}/${provider.duration}',
          style: TextStyle(color: Colors.white),
        ),
        InkWell(
          child: Icon(
            ChewieController.of(context).isFullScreen
                ? Icons.fullscreen_exit
                : Icons.fullscreen,
            color: Colors.white,
            size: 26,
          ),
          onTap: ChewieController.of(context).toggleFullScreen,
        ),
      ],
    );
  }
}
