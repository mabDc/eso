import 'dart:ui';
import 'package:eso/ui/CurvePainter.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/search_item_manager.dart';
import '../database/search_item.dart';
import '../model/chapter_page_controller.dart';
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
            extendBodyBehindAppBar: true,
            appBar: _buildAlphaAppbar(pageController),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                      height: 300, child: _comicDetail(pageController)),
                ),
                SliverToBoxAdapter(
                    child: widget.searchItem.tags != null
                        ? Container(
                            padding: EdgeInsets.only(top: 14.0),
                            child: Wrap(
                                spacing: 8,
                                alignment: WrapAlignment.center,
                                children: widget.searchItem.tags
                                    .map((keyword) => Container(
                                        decoration: new BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                        ),
                                        child: Padding(
                                            padding:
                                                EdgeInsets.fromLTRB(8, 2, 8, 2),
                                            child: Text(
                                              keyword,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white),
                                            ))))
                                    .toList()))
                        : Container()),
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 14.0),
                  child: Text(
                    widget.searchItem.description,
                    style: TextStyle(fontSize: 12),
                  ),
                )),
                SliverToBoxAdapter(child: _sortWidget(pageController)),
                _buildChapter(pageController, context)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChapter(
      ChapterPageController pageController, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (pageController.isLoading) {
      return SliverToBoxAdapter(
          child: Container(height: 100, child: LandingPage()));
    }

    void Function(int index) onTap = (int index) {
      pageController.changeChapter(index);
      Navigator.of(context)
          .push(ContentPageRoute().route(widget.searchItem))
          .whenComplete(pageController.adjustScroll);
    };

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: (screenWidth - 2 - 16) / 50 / 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Container(
              child: _buildChapterButton(
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
                  () => onTap(index)),
            );
          },
          childCount: widget.searchItem.chapters.length,
        ),
      ),
    );
  }

  // Widget _buildChapter(
  //     ChapterPageController pageController, BuildContext context) {
  //   if (pageController.isLoading) {
  //     return LandingPage();
  //   }
  //   void Function(int index) onTap = (int index) {
  //     pageController.changeChapter(index);
  //     Navigator.of(context)
  //         .push(ContentPageRoute().route(widget.searchItem))
  //         .whenComplete(pageController.adjustScroll);
  //   };
  //   final screenWidth = MediaQuery.of(context).size.width;
  //   return Directionality(
  //     textDirection: TextDirection.ltr,
  //     child: GridView.builder(
  //       padding: const EdgeInsets.only(bottom: 25.0, top: 8.0),
  //       controller: pageController.controller,
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 4,
  //         childAspectRatio: (screenWidth - 2 - 16) / 50 / 4,
  //         mainAxisSpacing: 8,
  //         crossAxisSpacing: 8,
  //       ),
  //       itemCount: widget.searchItem.chapters.length,
  //       itemBuilder: (context, index) {
  //         if (widget.searchItem.reverseChapter) {
  //           index = widget.searchItem.chapters.length - index - 1;
  //         }
  //         return _buildChapterButton(
  //             context,
  //             widget.searchItem.durChapterIndex == index,
  //             Align(
  //               alignment: FractionalOffset.center,
  //               child: Text(
  //                 '${widget.searchItem.chapters[index].name}'.trim(),
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //                 textAlign: TextAlign.center,
  //               ),
  //             ),
  //             () => onTap(index));
  //       },
  //     ),
  //   );
  // }

  //头部
  Widget _buildAlphaAppbar(ChapterPageController pageController) {
    return AppBar(
      backgroundColor: Theme.of(context).bottomAppBarColor,
      elevation: 0,
      title: Text(
        widget.searchItem.origin,
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
    );
  }

  //排序
  Widget _sortWidget(ChapterPageController pageController) {
    return Container(
      height: 32,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 1, color: Theme.of(context).textTheme.body1.color))),
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
                  color: widget.searchItem.reverseChapter
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.body1.color),
            ),
            onTap: widget.searchItem.reverseChapter
                ? pageController.toggleReverse
                : null,
          ),
          Text(" | "),
          GestureDetector(
            child: Text(
              "降序",
              style: TextStyle(
                  color: !widget.searchItem.reverseChapter
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.body1.color),
            ),
            onTap: !widget.searchItem.reverseChapter
                ? pageController.toggleReverse
                : null,
          ),
        ],
      ),
    );
  }

  //漫画详情
  Widget _comicDetail(ChapterPageController pageController) {
    return Stack(
      children: [
        CustomPaint(
          painter: CurvePainter(drawColor: Theme.of(context).bottomAppBarColor),
          child: Container(),
        ),
        Column(children: [
          Expanded(
              flex: 3,
              child: Container(
                child: Container(
                  width: 100,
                  child: UIImageItem(
                    cover: pageController.searchItem.cover,
                  ),
                ),
                alignment: Alignment.bottomCenter,
              )),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(children: [
                Text(
                  pageController.searchItem.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      pageController.searchItem.author,
                      style: TextStyle(fontSize: 12),
                    )),
              ]),
            ),
          ),
        ])
      ],
    );
    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
    //   child: UiSearchItem(item: widget.searchItem),
    // );
  }

  Widget _buildChapterButton(BuildContext context, bool isDurIndex,
      Widget child, VoidCallback onPress) {
    return isDurIndex
        ? RaisedButton(
            padding: EdgeInsets.all(8),
            elevation: 0,
            onPressed: onPress,
            color: Theme.of(context).primaryColor,
            textColor: Theme.of(context).primaryTextTheme.title.color,
            child: child,
          )
        : RaisedButton(
            padding: EdgeInsets.all(8),
            elevation: 0,
            onPressed: onPress,
            color: Theme.of(context).bottomAppBarColor,
            textColor: Theme.of(context).textTheme.body1.color,
            child: child,
          );
  }
}
