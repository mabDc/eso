import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/search_item_manager.dart';
import '../database/search_item.dart';
import '../model/chapter_page_controller.dart';
import '../ui/ui_big_list_chapter_item.dart';
import '../ui/ui_search_item.dart';
import 'content_page_manager.dart';
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
  ChapterPageController __pageController;

  @override
  void dispose() {
    __pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_page == null) {
      _page = _buildPage(MediaQuery.of(context).size);
    }
    return _page;
  }

  Widget _buildPage(Size size) {
    return ChangeNotifierProvider.value(
      value: ChapterPageController(searchItem: widget.searchItem, size: size),
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
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: pageController.share,
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                  child: UiSearchItem(item: widget.searchItem),
                ),
                Container(
                  height: 32,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border(
                      bottom: BorderSide(width: 1,color: Theme.of(context).textTheme.body1.color)
                  )),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          '全部章节(${widget.searchItem.chapters?.length ?? 0})',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      GestureDetector(
                        child: Text(
                          "升序",
                          style: TextStyle(
                              color: widget.searchItem.reverseChapter?
                              Theme.of(context).primaryColor:
                              Theme.of(context).textTheme.body1.color
                          ),
                        ),
                        onTap:widget.searchItem.reverseChapter?
                        pageController.toggleReverse:null,
                      ),
                      Text(" | "),
                      GestureDetector(
                        child: Text(
                          "降序",
                          style: TextStyle(
                              color: !widget.searchItem.reverseChapter?
                              Theme.of(context).primaryColor:
                              Theme.of(context).textTheme.body1.color
                          ),
                        ),
                        onTap:!widget.searchItem.reverseChapter?
                        pageController.toggleReverse:null,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildChapter(pageController, context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChapter(
      ChapterPageController pageController, BuildContext context) {
    if (pageController.isLoading) {
      return LandingPage();
    }
    void Function(int index) onTap = (int index) {
      pageController.changeChapter(index);
      Navigator.of(context)
          .push(ContentPageRoute().route(widget.searchItem))
          .whenComplete(pageController.adjustScroll);
    };
    final screenWidth = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 25.0,top: 8.0),
        controller: pageController.controller,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: (screenWidth - 2 - 16) / 50 / 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: widget.searchItem.chapters.length,
        itemBuilder: (context, index) {
          if (widget.searchItem.reverseChapter) {
            index = widget.searchItem.chapters.length - index - 1;
          }
          return _buildChapterButton(
              context,
              widget.searchItem.durChapterIndex == index,
              Align(
                alignment: FractionalOffset.center,
                child: Text(
                  '${widget.searchItem.chapters[index].name}'.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
                  () => onTap(index));
        },
      ),
    );
  }

  Widget _buildChapterButton(BuildContext context, bool isDurIndex,
      Widget child, VoidCallback onPress) {
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
      color: Theme.of(context).bottomAppBarColor,
      textColor: Theme.of(context).textTheme.body1.color,
      child: child,
    );
  }
}
