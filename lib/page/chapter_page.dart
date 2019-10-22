import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../ui/ui_search_item.dart';
import '../model/chapter_page_controller.dart';
import '../ui/ui_big_list_chapter_item.dart';
import '../api/mankezhan.dart';
import 'content_page.dart';
import 'langding_page.dart';

class ChapterPage extends StatelessWidget {
  final SearchItem item;
  final List<ChapterItem> chapters;

  const ChapterPage({
    this.item,
    this.chapters,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ChapterPageController(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(item.title),
        ),
        body: Column(
          children: <Widget>[
            UiSearchItem(item: item),
            Container(
              height: 30,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              alignment: Alignment.center,
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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

  Widget buildChapter(List<ChapterItem> chapters) {
    return Consumer<ChapterPageController>(
        builder: (context, ChapterPageController chapterPageController, _) {
      void Function(int index) onTap = (int index) {
        chapterPageController.changeChapter(index);
        final chapter = chapters[index];
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FutureBuilder<List>(
                future: Mankezhan.content(chapter.url),
                builder: (BuildContext context, AsyncSnapshot<List> data) {
                  if (!data.hasData) {
                    return LandingPage();
                  }
                  return ContentPage(imageList: data.data);
                }))).then((value){}).whenComplete((){});
      };
      final screenWidth = MediaQuery.of(context).size.width;
      switch (chapterPageController.listStyle) {
        case ChapterPageController.BigList:
          return ListView.separated(
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 6,
              );
            },
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              return buildChapterButton(
                  context,
                  chapterPageController.durChapterIndex == index,
                  UIBigListChapterItem(chapter: chapters[index],),
                  () => onTap(index));
            },
          );
        case ChapterPageController.SmallList:
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: (screenWidth - 6) / 50 / 2,
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
                      chapters[index].title,
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
              childAspectRatio: (screenWidth - 4 * 6) / 32 / 5,
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
            color: Colors.primaries[Random().nextInt(Colors.primaries.length)]
                .withAlpha(50),
            textColor: Theme.of(context).textTheme.body1.color,
            child: child,
          );
  }
}
