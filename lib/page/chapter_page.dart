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
  final SearchItem searchItem;
  final List<ChapterItem> chapters;

  const ChapterPage({
    this.searchItem,
    this.chapters,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ChapterPageController(
        durChapterIndex: searchItem.durChapterIndex,
        chapterListStyle: searchItem.chapterListStyle,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            searchItem.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.favorite_border),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.file_download),
              onPressed: () {},
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(Duration(seconds: 1));
            return;
          },
          child: Column(
            children: <Widget>[
              UiSearchItem(item: searchItem),
              Container(
                height: 30,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                alignment: Alignment.center,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '章节(${chapters.length})',
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
                  child: buildChapter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, ChapterListStyle listStyle) {
    return Consumer<ChapterPageController>(
      builder: (context, ChapterPageController chapterPageController, _) {
        return MaterialButton(
          onPressed: () {
            searchItem.chapterListStyle = listStyle;
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

  Widget buildChapter() {
    return Consumer<ChapterPageController>(
        builder: (context, ChapterPageController chapterPageController, _) {
      void Function(int index) onTap = (int index) {
        final chapter = chapters[index];
        chapterPageController.changeChapter(index);
        searchItem.durChapterIndex = index;
        searchItem.durChapter = chapter.name;
        searchItem.durContentIndex = 1;
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => FutureBuilder<List>(
                    future: Mankezhan.content(chapter.url),
                    builder: (BuildContext context, AsyncSnapshot<List> data) {
                      if (!data.hasData) {
                        return LandingPage();
                      }
                      return ContentPage(
                        urls: data.data,
                        chapters: chapters,
                        searchItem: searchItem,
                      );
                    }))).whenComplete((){
          chapterPageController.changeChapter(searchItem.durChapterIndex);
        });
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
                  UIBigListChapterItem(
                    chapter: chapters[index],
                  ),
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
                      chapters[index].name,
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
