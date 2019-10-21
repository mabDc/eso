import 'dart:math';

import 'package:eso/ui/ui_big_list_chapter_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/fake_data.dart';
import '../global.dart';
import '../ui/ui_search_item.dart';
import 'content_page.dart';
import '../model/chapter_page_controller.dart';

class ChapterPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final item = FakeData.shelfItem;
    final chapters = FakeData.chapterList;
    return ChangeNotifierProvider.value(
      value: ChapterPageController(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${item["title"]}'),
        ),
        body: Column(
          children: <Widget>[
            UiSearchItem(
              cover: '${item["cover"]}!cover-400',
              title: '${item["title"]}',
              origin: "漫客栈💰",
              author: '${item["author_title"]}',
              chapter: '${item["chapter_title"]}',
              description: '${item["feature"]}',
            ),
            Container(
              height: 30,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              alignment: Alignment(0, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '章节',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  buildButton(context, ChapterPageController.BigList),
                  buildButton(context, ChapterPageController.SmallList),
                  buildButton(context, ChapterPageController.Grid),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildChapter(chapters),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, listStyle) {
    return Consumer<ChapterPageController>(
      builder: (context, ChapterPageController chapterPageController, _) {
        return MaterialButton(
          onPressed: () {
            chapterPageController.changeListStyle(listStyle);
          },
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          minWidth: 8,
          child: Text(
            chapterPageController.getListStyleName(listStyle),
            style: TextStyle(
              color: chapterPageController.listStyle == listStyle
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).textTheme.body1.color,
            ),
          ),
        );
      },
    );
  }

  Widget buildChapter(List chapters) {
    return Consumer<ChapterPageController>(
        builder: (context, ChapterPageController chapterPageController, _) {

      void Function(int index) onTap = (int index) {
        chapterPageController.changeChapter(index);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ContentPage()));
      };

      switch (chapterPageController.listStyle) {
        case ChapterPageController.BigList:
          return ListView.separated(
            separatorBuilder: (context, index){
              return SizedBox(height: 6,);
            },
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              final time = DateTime.fromMillisecondsSinceEpoch(
                  int.parse(chapter["start_time"]) * 1000);
              return buildChapterButton(
                  context,
                  chapterPageController.durChapterIndex == index,
                  UIBigListChapterItem(
                      cover: chapter["cover"] == null
                          ? null
                          : '${chapter["cover"]}!cover-400',
                      title: chapter["title"],
                      subtitle:'$time'.trim().substring(0, 16)),
                  () => onTap(index));
            },
          );
        case ChapterPageController.SmallList:
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              return buildChapterButton(
                  context,
                  chapterPageController.durChapterIndex == index,
                  Align(
                    alignment: FractionalOffset.centerLeft,
                    child: Text(
                      chapters[index]["title"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  () => onTap(index));
            },
          );
        case ChapterPageController.Grid:
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.5,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              return buildChapterButton(
                  context,
                  chapterPageController.durChapterIndex == index,
                  Text('${index + 1}'),
                  () => onTap(index));
            },
          );
        default:
          throw ("chapter page style not support");
      }
    });
  }

  Widget buildChapterButton(BuildContext context, bool isDurIndex, Widget child,
      VoidCallback onPress) {
    return isDurIndex
        ? RaisedButton(
            onPressed: onPress,
            color: Theme.of(context).primaryColor,
            textColor: Theme.of(context).primaryTextTheme.title.color,
            child: child,
          )
        : RaisedButton(
            onPressed: onPress,
            color: Colors.primaries[Random().nextInt(Colors.primaries.length)].withAlpha(50),
            textColor: Theme.of(context).textTheme.body1.color,
            child: child,
          );
  }
}
