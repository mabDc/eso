import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../global.dart';
import '../database/fake_data.dart';
import '../page/chapter_page.dart';
import '../ui/ui_shelf_item.dart';
import '../model/search_page_delegate.dart';
import '../model/search_history.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = FakeData.shelfItem;
    return Scaffold(
      appBar: AppBar(
        title: Text(Global.appName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: SearchPageDelegate(
                searchHistory: Provider.of<SearchHistory>(context),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ChapterPage())),
            child: UiShelfItem(
              cover: '${info["cover"]}!cover-400',
              title: '${info["title"]}',
              origin: "漫客栈💰",
              author: '${info["author_title"]}',
              chapter: '${info["chapter_title"]}',
              durChapter: '${info["durChapter"]}',
              chapterNum: info["chapterNum"],
            ),
          );
        },
      ),
    );
  }
}
