import 'dart:math';
import 'dart:ui';
import 'package:eso/ui/CurvePainter.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/search_item_manager.dart';
import '../database/search_item.dart';
import '../model/chapter_page_provider.dart';
import 'content_page_manager.dart';
import 'langding_page.dart';

class ChapterPage extends StatelessWidget {
  final SearchItem searchItem;
  const ChapterPage({this.searchItem, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider<ChapterPageProvider>(
      create: (context) => ChapterPageProvider(searchItem: searchItem, size: size),
      builder: (context, child) => Scaffold(
        appBar: _buildAlphaAppbar(context),
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              _comicDetail(context),
              _buildChapter(context),
            ],
          ),
        ),
      ),
    );
  }

  //头部
  Widget _buildAlphaAppbar(BuildContext context) {
    final provider = Provider.of<ChapterPageProvider>(context, listen: false);
    return AppBar(
      titleSpacing: 0,
      backgroundColor: Theme.of(context).bottomAppBarColor,
      elevation: 0,
      title: Text(
        searchItem.origin,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: provider.updateChapter,
        ),
        // 加入收藏时需要刷新图标，其他不刷新
        Consumer<ChapterPageProvider>(
          builder: (context, provider, child) => IconButton(
            icon: SearchItemManager.isFavorite(searchItem.url)
                ? Icon(Icons.favorite)
                : Icon(Icons.favorite_border),
            onPressed: provider.toggleFavorite,
          ),
        ),
        IconButton(
          icon: Icon(Icons.share),
          onPressed: provider.share,
        ),
      ],
    );
  }

  //漫画详情
  Widget _comicDetail(BuildContext context) {
    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
    //   child: UiSearchItem(item: searchItem),
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
                          child: UIImageItem(cover: searchItem.cover),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        searchItem.name,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        searchItem.author,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          searchItem.tags != null && searchItem.tags.join().isNotEmpty
              ? Container(
                  padding: EdgeInsets.only(
                    top: 14.0,
                  ),
                  child: Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: searchItem.tags
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
              searchItem.description,
              style: TextStyle(fontSize: 12),
            ),
          ),
          _sortWidget(context)
        ],
      ),
    );
  }

  //排序
  Widget _sortWidget(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ChapterPageProvider>(
      builder: (context, provider, child) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '全部章节(${searchItem.chapters?.length ?? 0})',
                style: TextStyle(fontSize: 16),
              ),
            ),
            GestureDetector(
              child: Row(
                children: [
                  searchItem.reverseChapter
                      ? Container()
                      : Transform.rotate(
                          child: Icon(
                            Icons.sort,
                            color: theme.primaryColor,
                          ),
                          angle: pi,
                        ),
                  Text(
                    searchItem.reverseChapter ? "倒序" : "顺序",
                    style: TextStyle(color: theme.primaryColor),
                  ),
                  searchItem.reverseChapter
                      ? Icon(Icons.sort, color: theme.primaryColor)
                      : Container(),
                ],
              ),
              onTap: provider.toggleReverse,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapter(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    var countOfLine = screenWidth ~/ 180;
    if (countOfLine < 2) {
      countOfLine = 2;
    } else if (countOfLine > 6) {
      countOfLine = 6;
    }
    return Consumer<ChapterPageProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SliverToBoxAdapter(
            child: Container(height: 200, child: LandingPage()),
          );
        }
        void Function(int index) onTap = (int index) {
          provider.changeChapter(index);
          Navigator.of(context)
              .push(ContentPageRoute().route(searchItem))
              .whenComplete(provider.adjustScroll);
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
                final showIndex = searchItem.reverseChapter
                    ? searchItem.chaptersCount - index - 1
                    : index;
                return Container(
                  child: _buildChapterButton(
                      context,
                      searchItem.durChapterIndex == index,
                      Align(
                        alignment: FractionalOffset.center,
                        child: Text(
                          '${searchItem.chapters[showIndex].name}'.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      () => onTap(showIndex)),
                );
              },
              childCount: searchItem.chapters.length,
            ),
          ),
        );
      },
    );
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