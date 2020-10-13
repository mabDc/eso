import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/page/manga_page.dart';
import 'package:eso/page/novel_page.dart';
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
          default:
            throw ('${searchItem.ruleContentType} not support !');
        }
      },
    );
  }
}
