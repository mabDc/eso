import 'package:eso/database/search_item.dart';
import 'package:eso/model/video_page_controller.dart';
import 'package:eso/page/langding_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chewie/chewie.dart';

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
