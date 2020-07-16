import 'dart:io';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/page/audio_page.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/page/manga_page.dart';
import 'package:eso/page/novel_page.dart';
import 'package:eso/global.dart';
// import 'package:eso/page/rss_page.dart';
import 'package:eso/page/video_page_refactor.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

class ContentPageRoute {
  MaterialPageRoute route(SearchItem searchItem) {
    return MaterialPageRoute(
      builder: (context) {
        switch (searchItem.ruleContentType) {
          case API.NOVEL:
            return NovelPage(searchItem: searchItem);
          case API.MANGA:
            return MangaPage(searchItem: searchItem);
          // case API.RSS:
          //   return RSSPage(searchItem: searchItem);
          case API.VIDEO:
            // 更新系统亮度
            Global.updateSystemBrightness();
            if (Platform.isIOS) {
              return FutureBuilder<List<String>>(
                future: APIManager.getContent(searchItem.originTag,
                    searchItem.chapters[searchItem.durChapterIndex].url),
                initialData: null,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) return LandingPage();
                  return VideoScreen(url: snapshot.data[0]);
                },
              );
            }
            return VideoPage(searchItem: searchItem);
          case API.AUDIO:
            return AudioPage(searchItem: searchItem);
          default:
            throw ('${searchItem.ruleContentType} not support !');
        }
      },
    );
  }
}

class VideoScreen extends StatefulWidget {
  final String url;

  VideoScreen({@required this.url});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final FijkPlayer player = FijkPlayer();

  _VideoScreenState();

  @override
  void initState() {
    super.initState();
    player.setDataSource(widget.url, autoPlay: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Fijkplayer Example")),
        body: Container(
          alignment: Alignment.center,
          child: FijkView(
            player: player,
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
  }
}
