import 'package:dlna/dlna.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/utils/dlna_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awsome_video_player/awsome_video_player.dart';
import 'package:video_player/video_player.dart';

import '../utils.dart';

class VideoPage extends StatelessWidget {
  final SearchItem searchItem;

  const VideoPage({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => VideoProvider(searchItem: searchItem),
        builder: (context, child) {
          final videoUrl = context.select((VideoProvider p) => p.videoUrl);
          final provider = Provider.of<VideoProvider>(context, listen: false);
          if (videoUrl == null || videoUrl.trim().isEmpty) {
            return LandingPage(
                title: Text(Utils.link(searchItem.name, searchItem.durChapter,
                        divider: ' - ')
                    .value),
                color: Colors.black54,
                brightness: Brightness.dark);
          }
          return AwsomeVideoPlayer(
            videoUrl,
            oninit: provider.setController,

            /// 视频播放配置
            playOptions: VideoPlayOptions(
              seekSeconds: 10,
              startPosition: Duration(milliseconds: searchItem.durContentIndex),
            ),

            /// 自定义视频样式
            videoStyle: VideoStyle(
              /// 自定义视频暂停时视频中部的播放按钮
              playIcon: Icon(
                Icons.play_circle_outline,
                size: 80,
                color: Colors.white,
              ),

              /// 暂停时是否显示视频中部播放按钮
              showPlayIcon: true,

              videoLoadingStyle: VideoLoadingStyle(
                /// 重写部分（二选一）
                // 重写Loading的widget
                customLoadingIcon: CupertinoActivityIndicator(
                  radius: 8,
                ),
                // 重写Loading 下方的Text widget
                customLoadingText:
                    Text("加载中...", style: TextStyle(color: Colors.white)),
              ),

              /// 自定义顶部控制栏
              videoTopBarStyle: VideoTopBarStyle(
                height: 50,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                popIcon: Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: Colors.white,
                ),
                contents: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        searchItem.durChapter,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  )
                ], //自定义顶部控制栏中间显示区域
                actions: [
                  GestureDetector(
                    onTap: () {
                      provider.openDLNA(context);
                    },
                    child: Icon(
                      Icons.airplay,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ], //自定义顶部控制栏右侧显示区域
              ),

              /// 自定义底部控制栏
              videoControlBarStyle: VideoControlBarStyle(
                /// 自定义颜色
                // barBackgroundColor: Colors.blue,

                ///添加边距
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),

                ///设置控制拦的高度，默认为30，如果图标设置过大但是高度不够就会出现图标被裁剪的现象
                height: 50,

                /// 更改进度栏的播放按钮
                playIcon: Icon(Icons.play_arrow, color: Colors.white, size: 16),

                /// 更改进度栏的暂停按钮
                pauseIcon: Icon(
                  Icons.pause,
                  color: Colors.white,
                  size: 16,
                ),

                /// 更改进度栏的快退按钮
                rewindIcon: Icon(
                  Icons.replay_10,
                  size: 16,
                  color: Colors.white,
                ),

                /// 更改进度栏的快进按钮
                forwardIcon: Icon(
                  Icons.forward_10,
                  size: 16,
                  color: Colors.white,
                ),

                /// 更改进度栏的全屏按钮
                fullscreenIcon: Icon(
                  Icons.fullscreen,
                  size: 20,
                  color: Colors.white,
                ),

                /// 更改进度栏的退出全屏按钮
                fullscreenExitIcon: Icon(
                  Icons.fullscreen_exit,
                  size: 20,
                  color: Colors.white,
                ),

                /// 决定控制栏的元素以及排序，示例见上方图3
                itemList: [
                  "rewind",
                  "play",
                  "forward",
                  // "position-time", //当前播放时间
                  "progress", //线条形进度条（与‘basic-progress’二选一）
                  // "basic-progress",//矩形进度条（与‘progress’二选一）
                  // "duration-time", //视频总时长
                  "time", //格式：当前时间/视频总时长
                  "fullscreen"
                ],
              ),
            ),

            /// 自定义拓展元素
            children: [
              /// 提示文本
              Consumer<VideoProvider>(
                builder: (context, provider, child) {
                  if (provider.hint == null || provider.hint.isEmpty) {
                    return Container();
                  }
                  return Center(
                    child: Material(
                      color: const Color.fromRGBO(0, 0, 0, 0.2),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Text(
                          provider.hint,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: Profile.fontFamily),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],

            /// 视频暂停回调
            onpause: (value) {
              provider.hint = "暂停";
            },

            /// 视频播放回调
            onplay: (value) {
              provider.hint = "播放";
            },

            /// 视频播放结束回调
            onended: (value) {
              provider.hint = "播放结束";
            },

            /// 视频播放进度回调
            /// 可以用来匹配字幕
            ontimeupdate: (value) {
              // print("timeupdate ${value}");
              // var position = value.position.inMilliseconds / 1000;
              //根据 position 来判断当前显示的字幕
            },

            onprogressdrag: (position, duration) {
              provider.hint =
                  "${Utils.formatDuration(position)} / ${Utils.formatDuration(duration)}";
              print("进度条拖拽的时间节点： ${position}");
              print("进度条总时长： ${duration}");
            },

            onvolume: (value) {
              provider.hint = "音量 ${value.toStringAsFixed(2)}";
            },

            onbrightness: (value) {
              provider.hint = "亮度 ${value.toStringAsFixed(2)}";
            },

            onfullscreen: (fullscreen) {
              provider.hint = fullscreen ? "进入全屏" : "退出全屏";
            },

            /// 顶部控制栏点击返回按钮
            onpop: (value) {
              print("返回上一页");
            },
          );
        },
      ),
    );
  }
}

class VideoProvider with ChangeNotifier {
  final SearchItem searchItem;
  final hintDelay = Duration(seconds: 1);
  List<String> _content;
  List<String> get content => _content;
  String _videoUrl;
  String get videoUrl => _videoUrl;
  String _hint;
  String get hint => _hint;
  set hint(String value) {
    if (value.isEmpty) return;
    _hint = value;
    _lastShowTime = DateTime.now();
    notifyListeners();
    Future.delayed(hintDelay, () {
      if (DateTime.now().difference(_lastShowTime).compareTo(hintDelay) >= 0) {
        _hint = "";
        notifyListeners();
      }
    });
  }

  DateTime _lastShowTime;

  VideoPlayerController _controller;
  // VideoPlayerController get controller => _controller;
  VideoProvider({
    @required this.searchItem,
  }) {
    if (searchItem.chapters?.length == 0 &&
        SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)) {
      searchItem.chapters = SearchItemManager.getChapter(searchItem.id);
    }
    init();
  }

  init() async {
    _content = await APIManager.getContent(searchItem.originTag,
        searchItem.chapters[searchItem.durChapterIndex].url);
    if (_content.isNotEmpty && _content[0].isNotEmpty) {
      _videoUrl = content[0];
    }
    notifyListeners();
  }

  void openDLNA(BuildContext context) {
    if (_content == null || _content.isEmpty) return;
    DLNAUtil.instance.start(context,
        title: searchItem.name + ' - ' + searchItem.durChapter,
        url: _content[0],
        videoType: VideoObject.VIDEO_MP4, onPlay: () {
      if (_controller.value.isPlaying) _controller.pause();
    });
  }

  void setController(VideoPlayerController controller) {
    _controller = controller;
  }

  @override
  void dispose() {
    // _controller.dispose();
    _lastShowTime = null;
    _content?.clear();
    super.dispose();
  }
}
