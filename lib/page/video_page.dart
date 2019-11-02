import 'package:chewie/chewie.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/model/video_page_controller.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          return Scaffold(
            appBar: AppBar(
              title: Text(pageController.searchItem.durChapter),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.open_in_new),
                  onPressed: pageController.openWith,
                ),
                IconButton(
                  icon: Icon(Icons.dns),
                  onPressed: () =>
                      pageController.showChapter = !pageController.showChapter,
                ),
              ],
            ),
            body: _buildBody(pageController),
          );
        },
      ),
    );
  }

  Widget _buildBody(VideoPageController pageController) {
    if (pageController.content == null) {
      return LandingPage();
    }
    if (pageController.controller == null) {
      return Text('加载失败', style: TextStyle(fontSize: 30));
    }
    return GestureDetector(
      child: Container(
        color: Colors.transparent,
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Chewie(controller: pageController.controller),
            pageController.showChapter
                ? UIChapterSelect(
                    searchItem: pageController.searchItem,
                    loadChapter: pageController.loadChapter,
                  )
                : Container(),
          ],
        ),
      ),
      onTapUp: (TapUpDetails details) {
        final size = MediaQuery.of(context).size;
        if (details.globalPosition.dx > size.width * 3 / 8 &&
            details.globalPosition.dx < size.width * 5 / 8 &&
            details.globalPosition.dy > size.height * 3 / 8 &&
            details.globalPosition.dy < size.height * 5 / 8) {
          //pageController.showChapter = true;
        } else {
          pageController.showChapter = false;
        }
      },
    );
  }
}
