import 'dart:math';

import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/search_item.dart';
import '../ui/ui_search_item.dart';
import '../model/chapter_page_controller.dart';
import '../ui/ui_big_list_chapter_item.dart';
import 'content_page.dart';
import 'langding_page.dart';

class ChapterPage extends StatelessWidget {
  final SearchItem searchItem;

  const ChapterPage({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ChapterPageController(searchItem: searchItem),
      child: Consumer<ChapterPageController>(
        builder: (context, ChapterPageController pageController, _) {
          if (searchItem.chapters == null) {
            return LandingPage();
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(
                searchItem.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: <Widget>[
                IconButton(
                  icon: SearchItemManager.isFavorite(searchItem.url)
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border),
                  onPressed: pageController.toggleFavorite,
                ),
                IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: () {},
                )
              ],
            ),
            body: RefreshIndicator(
              onRefresh: pageController.updateChapter,
              child: Column(
                children: <Widget>[
                  UiSearchItem(item: searchItem),
                  Container(
                    height: 32,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    alignment: Alignment.center,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '章节(${searchItem.chapters.length})',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        buildButton(pageController, context,
                            ChapterPageController.BigList),
                        buildButton(pageController, context,
                            ChapterPageController.SmallList),
                        buildButton(pageController, context,
                            ChapterPageController.Grid),
                        SizedBox(
                          width: 26,
                          child: IconButton(
                            padding: EdgeInsets.only(left: 6),
                            iconSize: 20,
                            icon: Icon(Icons.arrow_upward),
                            onPressed: pageController.scrollerToTop,
                          ),
                        ),
                        SizedBox(
                          width: 26,
                          child: IconButton(
                            padding: EdgeInsets.only(left: 6),
                            iconSize: 20,
                            icon: Icon(Icons.arrow_downward),
                            onPressed: pageController.scrollerToBottom,
                          ),
                        ),
                        SizedBox(
                          width: 26,
                          child: IconButton(
                            padding: EdgeInsets.only(left: 6),
                            iconSize: 20,
                            icon: Icon(Icons.all_inclusive),
                            onPressed: pageController.switchReverseChapter,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: buildChapter(pageController, context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildButton(ChapterPageController pageController, BuildContext context,
      ChapterListStyle listStyle) {
    return MaterialButton(
      onPressed: () {
        pageController.changeListStyle(listStyle);
      },
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).primaryColor,
          width: 1,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      minWidth: 0,
      child: Text(
        pageController.getListStyleName(listStyle),
        style: TextStyle(
          color: searchItem.chapterListStyle == listStyle
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.body1.color,
        ),
      ),
    );
  }

  Widget buildChapter(
      ChapterPageController pageController, BuildContext context) {
    void Function(int index) onTap = (int index) {
      pageController.changeChapter(index);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => FutureBuilder<List>(
              future: APIManager.getContent(
                  searchItem.originTag, searchItem.chapters[index].url),
              builder: (BuildContext context, AsyncSnapshot<List> data) {
                if (!data.hasData) {
                  return LandingPage();
                }
                return ContentPage(
                  content: data.data,
                  searchItem: searchItem,
                );
              })));
    };
    final screenWidth = MediaQuery.of(context).size.width;
    switch (searchItem.chapterListStyle) {
      case ChapterPageController.BigList:
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 8.0),
          controller: pageController.controller,
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 6,
            );
          },
          itemCount: searchItem.chapters.length,
          itemBuilder: (context, index) {
            if(searchItem.reverseChapter){
              index = searchItem.chapters.length - index - 1;
            }
            return buildChapterButton(
                context,
                searchItem.durChapterIndex == index,
                UIBigListChapterItem(
                  chapter: searchItem.chapters[index],
                ),
                () => onTap(index));
          },
        );
      case ChapterPageController.SmallList:
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 8.0),
          controller: pageController.controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: (screenWidth - 6) / 50 / 2,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: searchItem.chapters.length,
          itemBuilder: (context, index) {
            if(searchItem.reverseChapter){
              index = searchItem.chapters.length - index - 1;
            }
            return buildChapterButton(
                context,
                searchItem.durChapterIndex == index,
                Align(
                  alignment: FractionalOffset.centerLeft,
                  child: Text(
                    searchItem.chapters[index].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                () => onTap(index));
          },
        );
      case ChapterPageController.Grid:
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 8.0),
          controller: pageController.controller,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: (screenWidth - 4 * 6) / 45 / 5,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemCount: searchItem.chapters.length,
          itemBuilder: (context, index) {
            if(searchItem.reverseChapter){
              index = searchItem.chapters.length - index - 1;
            }
            return buildChapterButton(
                context,
                searchItem.durChapterIndex == index,
                Text('${index + 1}'),
                () => onTap(index));
          },
        );
      default:
        throw ("chapter page style not support");
    }
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
