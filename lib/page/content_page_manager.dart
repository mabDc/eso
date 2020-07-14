import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/page/audio_page.dart';
import 'package:eso/page/manga_page.dart';
import 'package:eso/page/novel_page.dart';
import 'package:eso/global.dart';
// import 'package:eso/page/rss_page.dart';
import 'package:eso/page/video_page_refactor.dart';
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
