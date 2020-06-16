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
    final topHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    StateSetter state;
    double opacity = 0.0;

    return ChangeNotifierProvider<ChapterPageProvider>(
      create: (context) => ChapterPageProvider(searchItem: searchItem, size: size),
      builder: (context, child) => Scaffold(
        body: Stack(
          children: [
            NotificationListener(
              child: CustomScrollView(
                slivers: <Widget>[
                  _comicDetail(context),
                  _buildChapter(context),
                ],
              ),
              onNotification: ((ScrollUpdateNotification n) {
                if (n.depth == 0 && n.metrics.pixels <= 200.0) {
                  opacity = min(n.metrics.pixels, 100.0) / 100.0;
                  if (state != null) state(() => null);
                }
                return true;
              }),
            ),
            StatefulBuilder(
              builder: (context, _state) {
                state = _state;
                return Container(
                  child: _buildAlphaAppbar(context),
                  color: Theme.of(context).primaryColor.withOpacity(opacity),
                  height: topHeight,
                );
              },
            )
          ],
        )
      ),
    );
  }

  //头部
  Widget _buildAlphaAppbar(BuildContext context) {
    final provider = Provider.of<ChapterPageProvider>(context, listen: false);
    final _theme = Theme.of(context).appBarTheme;
    final _textTheme = Theme.of(context).primaryTextTheme;
    final _iconTheme = Theme.of(context).primaryIconTheme;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      textTheme: _textTheme.copyWith(headline6: _textTheme.headline6.copyWith(color: _theme.color)),
      iconTheme: _iconTheme.copyWith(color: _theme.color),
      actionsIconTheme: _iconTheme.copyWith(color: _theme.color),
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
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Stack(
            children: [
              ArcBannerImage(searchItem.cover),
              SizedBox(
                height: 290,
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: SafeArea(
                    child: Column(
                      children: [
                        SizedBox(height: 45),
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: Container(
                              child: UIImageItem(cover: searchItem.cover),
                              decoration: BoxDecoration(
                                boxShadow: [BoxShadow(blurRadius: 8, color: Colors.white70)]
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(searchItem.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18,
                            shadows: [Shadow(blurRadius: 5, color: Colors.white)])),
                        SizedBox(height: 4),
                        Text(
                          searchItem.author,
                          style: TextStyle(fontSize: 12, color: Theme.of(context).appBarTheme.color.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
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
          _buildDescription(context, searchItem.description),
          _sortWidget(context)
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, String description) {
    const horizontalPadding = 20.0;
    final fontSize = 12.0;
    final paragraphPadding = 10.0;
    final width = MediaQuery.of(context).size.width - 2 * horizontalPadding;
    final offset = Offset(width, 6);
    final fontColor = Theme.of(context).textTheme.bodyText1.color.withOpacity(0.8);
    final style = TextStyle(fontSize: fontSize, color: fontColor);
    final paragraphs =
        description.split(RegExp(r"^\s*|\n\s*")).map((s) => s.trimLeft()).toList();
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    final spans = <TextSpan>[];
    final newLine = TextSpan(text: "\n");
    for (var paragraph in paragraphs) {
      while (paragraph.isNotEmpty) {
        tp.text = TextSpan(text: paragraph, style: style);
        tp.layout(maxWidth: width);
        final pos = tp.getPositionForOffset(offset).offset;
        final text = paragraph.substring(0, pos);
        paragraph = paragraph.substring(pos);
        if (paragraph.isEmpty) {
          // 最后一行调整宽度保证单行显示
          if (width - tp.width - fontSize < 0) {
            spans.add(TextSpan(
                text: text,
                style: TextStyle(
                  fontSize: fontSize,
                  color: fontColor,
                  letterSpacing: (width - tp.width) / text.length,
                )));
          } else {
            spans.add(TextSpan(text: text, style: style));
          }
          spans.add(newLine);
          spans.add(TextSpan(
              text: " ", style: TextStyle(height: 1, fontSize: paragraphPadding)));
          spans.add(newLine);
          break;
        }
        tp.text = TextSpan(text: text, style: style);
        tp.layout();
        spans.add(TextSpan(
            text: text,
            style: TextStyle(
              fontSize: fontSize,
              color: fontColor,
              letterSpacing: (width - tp.width) / text.length,
            )));
      }
    }
    if (spans.length > 1) {
      spans.removeLast();
    }
    return Container(
      padding: const EdgeInsets.only(
        top: 14.0,
        left: horizontalPadding,
        right: horizontalPadding - 5,
      ),
      child: RichText(text: TextSpan(children: spans)),
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
            textColor: Theme.of(context).cardColor,
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

class ArcBannerImage extends StatelessWidget {
  ArcBannerImage(this.imageUrl, {this.arcH = 30.0, this.height = 300.0});
  final String imageUrl;
  final double height, arcH;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ArcClipper(this),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: height,
            child: UIImageItem(cover: imageUrl, radius: null, fit: BoxFit.cover),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withOpacity(0.25),
              height: height,
            ),
          ),
        ],
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  final ArcBannerImage widget;
  ArcClipper(this.widget);

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height - widget.arcH);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - widget.arcH);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}