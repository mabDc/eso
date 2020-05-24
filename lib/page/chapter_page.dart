import 'dart:math';
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
            appBar: _buildAlphaAppbar(pageController),
            body: SafeArea(
              child: CustomScrollView(
                slivers: <Widget>[
                  _comicDetail(pageController),
                  _buildChapter(pageController, context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //头部
  Widget _buildAlphaAppbar(ChapterPageController pageController) {
    return AppBar(
      titleSpacing: 0,
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

  //漫画详情
  Widget _comicDetail(ChapterPageController pageController) {
    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
    //   child: UiSearchItem(item: widget.searchItem),
    // );
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            height: 250,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CustomPaint(
                  painter: CurvePainter(drawColor: Theme.of(context).bottomAppBarColor),
                  child: Container(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: UIImageItem(cover: pageController.searchItem.cover),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        pageController.searchItem.name,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        pageController.searchItem.author,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          pageController.searchItem.tags != null &&
                  pageController.searchItem.tags.join().isNotEmpty
              ? Container(
                  padding: EdgeInsets.only(
                    top: 14.0,
                  ),
                  child: Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: pageController.searchItem.tags
                        .map(
                          (tag) => Material(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.all(Radius.circular(15.0)),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                              child: Text(
                                tag,
                                style: TextStyle(fontSize: 10, color: Colors.white),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
              : Container(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Text(
              widget.searchItem.description,
              style: TextStyle(fontSize: 12),
            ),
          ),
          _sortWidget(pageController)
        ],
      ),
    );
  }

  //排序
  Widget _sortWidget(ChapterPageController pageController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '全部章节(${widget.searchItem.chapters?.length ?? 0})',
              style: TextStyle(fontSize: 16),
            ),
          ),
          GestureDetector(
            child: Row(
              children: [
                widget.searchItem.reverseChapter
                    ? Container()
                    : Transform.rotate(
                        child: Icon(
                          Icons.sort,
                          color: Theme.of(context).primaryColor,
                        ),
                        angle: pi,
                      ),
                Text(
                  widget.searchItem.reverseChapter ? "倒序" : "顺序",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                widget.searchItem.reverseChapter
                    ? Icon(Icons.sort, color: Theme.of(context).primaryColor)
                    : Container(),
              ],
            ),
            onTap: pageController.toggleReverse,
          ),
        ],
      ),
    );
  }

  Widget _buildChapter(ChapterPageController pageController, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var countOfLine = screenWidth ~/ 180;
    if(countOfLine < 2){
      countOfLine = 2;
    }else if(countOfLine > 6){
      countOfLine = 6;
    }
    if (pageController.isLoading) {
      return SliverToBoxAdapter(
        child: Container(height: 200, child: LandingPage()),
      );
    }

    void Function(int index) onTap = (int index) {
      pageController.changeChapter(index);
      Navigator.of(context)
          .push(ContentPageRoute().route(widget.searchItem))
          .whenComplete(pageController.adjustScroll);
    };
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: countOfLine,
          childAspectRatio: (screenWidth - 2 - 16) / 50 / countOfLine,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final showIndex = widget.searchItem.reverseChapter
                ? widget.searchItem.chaptersCount - index - 1
                : index;
            return Container(
              child: _buildChapterButton(
                  context,
                  widget.searchItem.durChapterIndex == index,
                  Align(
                    alignment: FractionalOffset.center,
                    child: Text(
                      '${widget.searchItem.chapters[showIndex].name}'.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  () => onTap(showIndex)),
            );
          },
          childCount: pageController.searchItem.chapters.length,
        ),
      ),
    );

    // return GridView.builder(
    //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    //   physics: NeverScrollableScrollPhysics(),
    //   shrinkWrap: true,
    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: 4,
    //     childAspectRatio: (screenWidth - 2 - 16) / 50 / 4,
    //     mainAxisSpacing: 8,
    //     crossAxisSpacing: 8,
    //   ),
    //   itemBuilder: (BuildContext context, int index) {
    //     return Container(
    //       child: _buildChapterButton(
    //           context,
    //           widget.searchItem.durChapterIndex == index,
    //           Align(
    //             alignment: FractionalOffset.center,
    //             child: Text(
    //               '${widget.searchItem.chapters[index].name}'.trim(),
    //               maxLines: 1,
    //               overflow: TextOverflow.ellipsis,
    //               textAlign: TextAlign.center,
    //             ),
    //           ),
    //           () => onTap(index)),
    //     );
    //   },
    //   itemCount: widget.searchItem.chapters.length,
    // );
  }

  Widget _buildChapterButton(
      BuildContext context, bool isDurIndex, Widget child, VoidCallback onPress) {
    return isDurIndex
        ? RaisedButton(
            padding: EdgeInsets.all(4),
            elevation: 0,
            onPressed: onPress,
            color: Theme.of(context).primaryColor,
            textColor: Theme.of(context).primaryTextTheme.headline6.color,
            child: child,
          )
        : RaisedButton(
            padding: EdgeInsets.all(4),
            elevation: 0,
            onPressed: onPress,
            color: Theme.of(context).bottomAppBarColor,
            textColor: Theme.of(context).textTheme.bodyText1.color,
            child: child,
          );
  }
}
