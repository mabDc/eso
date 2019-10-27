import 'dart:math';
import 'dart:ui';

import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/search_item.dart';
import '../model/chapter_page_controller.dart';
import '../ui/ui_big_list_chapter_item.dart';
import '../ui/ui_search_item.dart';
import 'content_page.dart';
import 'langding_page.dart';

class ChapterPage extends StatefulWidget {
  final SearchItem searchItem;

  const ChapterPage({
    this.searchItem,
    Key key,
  }) : super(key: key);

  @override
  _ChapterPageState createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  Widget _page;

  @override
  Widget build(BuildContext context) {
    if (_page == null) {
      _page = _buildPage();
    }
    return _page;
  }

  Widget _buildPage() {
    return ChangeNotifierProvider.value(
      value: ChapterPageController(searchItem: widget.searchItem),
      child: Consumer<ChapterPageController>(
        builder: (context, ChapterPageController pageController, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.searchItem.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: pageController.updateChapter,
                ),
                IconButton(
                  icon: SearchItemManager.isFavorite(widget.searchItem.url)
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border),
                  onPressed: pageController.toggleFavorite,
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                UiSearchItem(item: widget.searchItem),
                Container(
                  height: 32,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '章节(${widget.searchItem.chapters?.length ?? 0})',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      buildButton(pageController, context,
                          ChapterPageController.BigList),
                      buildButton(pageController, context,
                          ChapterPageController.SmallList),
                      buildButton(
                          pageController, context, ChapterPageController.Grid),
                      SizedBox(
                        width: 30,
                        child: IconButton(
                          padding: EdgeInsets.only(left: 6),
                          icon: Icon(Icons.arrow_upward),
                          onPressed: pageController.scrollerToTop,
                        ),
                      ),
                      SizedBox(
                        width: 30,
                        child: IconButton(
                          padding: EdgeInsets.only(left: 6),
                          icon: Icon(Icons.arrow_downward),
                          onPressed: pageController.scrollerToBottom,
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
      minWidth: 60,
      child: Text(
        pageController.getListStyleName(listStyle),
        style: TextStyle(
          color: widget.searchItem.chapterListStyle == listStyle
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.body1.color,
        ),
      ),
    );
  }

  Widget buildChapter(
      ChapterPageController pageController, BuildContext context) {
    if (pageController.isLoading) {
      return LandingPage();
    }
    void Function(int index) onTap = (int index) {
      pageController.changeChapter(index);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ContentPage(searchItem: widget.searchItem)));
    };
    final screenWidth = MediaQuery.of(context).size.width;
    switch (widget.searchItem.chapterListStyle) {
      case ChapterPageController.BigList:
        return ListView.separated(
          reverse: widget.searchItem.reverseChapter,
          padding: const EdgeInsets.only(bottom: 8.0),
          controller: pageController.controller,
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 6,
            );
          },
          itemCount: widget.searchItem.chapters.length,
          itemBuilder: (context, index) {
            if (widget.searchItem.reverseChapter) {
              index = widget.searchItem.chapters.length - index - 1;
            }
            return buildChapterButton(
                context,
                widget.searchItem.durChapterIndex == index,
                UIBigListChapterItem(
                  chapter: widget.searchItem.chapters[index],
                  chapterNum: index + 1,
                ),
                () => onTap(index));
          },
        );
      case ChapterPageController.SmallList:
        return Directionality(
          textDirection: widget.searchItem.reverseChapter
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: GridView.builder(
            reverse: widget.searchItem.reverseChapter,
            padding: const EdgeInsets.only(bottom: 8.0),
            controller: pageController.controller,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: (screenWidth - 6) / 50 / 2,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: widget.searchItem.chapters.length,
            itemBuilder: (context, index) {
              if (widget.searchItem.reverseChapter) {
                index = widget.searchItem.chapters.length - index - 1;
              }
              return buildChapterButton(
                  context,
                  widget.searchItem.durChapterIndex == index,
                  Align(
                    alignment: FractionalOffset.centerLeft,
                    child: Text(
                      '${widget.searchItem.chapters[index].name}'.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                  () => onTap(index));
            },
          ),
        );
      case ChapterPageController.Grid:
        return Directionality(
          textDirection: widget.searchItem.reverseChapter
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: GridView.builder(
            reverse: widget.searchItem.reverseChapter,
            padding: const EdgeInsets.only(bottom: 8.0),
            controller: pageController.controller,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: (screenWidth - 4 * 6) / 45 / 5,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: widget.searchItem.chapters.length,
            itemBuilder: (context, index) {
              if (widget.searchItem.reverseChapter) {
                index = widget.searchItem.chapters.length - index - 1;
              }
              return buildChapterButton(
                  context,
                  widget.searchItem.durChapterIndex == index,
                  Text(
                    '${index + 1}',
                    textDirection: TextDirection.ltr,
                  ),
                  () => onTap(index));
            },
          ),
        );
      default:
        throw ("chapter page style not support");
    }
  }

  Widget buildChapterButton(BuildContext context, bool isDurIndex, Widget child,
      VoidCallback onPress) {
    return isDurIndex
        ? RaisedButton(
            padding: EdgeInsets.all(8),
            onPressed: onPress,
            color: Theme.of(context).primaryColor,
            textColor: Theme.of(context).primaryTextTheme.title.color,
            child: child,
          )
        : RaisedButton(
            padding: EdgeInsets.all(8),
            onPressed: onPress,
            color: Colors.primaries[Random().nextInt(Colors.primaries.length)]
                .withAlpha(50),
            textColor: Theme.of(context).textTheme.body1.color,
            child: child,
          );
  }
}
