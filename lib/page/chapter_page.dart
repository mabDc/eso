import 'dart:math';
import 'dart:ui';
import 'package:eso/api/api.dart';
import 'package:eso/global.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/page/photo_view_page.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:eso/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:eso/ui/widgets/draggable_scrollbar_sliver.dart';
import '../database/search_item_manager.dart';
import '../database/search_item.dart';
import '../fonticons_icons.dart';
import '../model/chapter_page_provider.dart';
import 'content_page_manager.dart';
import 'langding_page.dart';

class ChapterPage extends StatefulWidget {
  final SearchItem searchItem;
  const ChapterPage({this.searchItem, Key key}) : super(key: key);

  @override
  _ChapterPageState createState() => _ChapterPageState(searchItem);
}

class _ChapterPageState extends State<ChapterPage> {
  _ChapterPageState(this.searchItem) : super();

  double opacity = 0.0;
  StateSetter state;
  final SearchItem searchItem;
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    _controller = ScrollController();

    return ChangeNotifierProvider<ChapterPageProvider>(
      create: (context) => ChapterPageProvider(searchItem: searchItem, size: size),
      builder: (context, child) => Scaffold(
          body: Stack(
        children: [
          NotificationListener(
            child: DraggableScrollbar.semicircle(
              child: CustomScrollView(
                physics: ClampingScrollPhysics(),
                controller: _controller,
                slivers: <Widget>[
                  _comicDetail(context),
                  _buildChapter(context),
                ],
              ),
              controller: _controller,
              padding: const EdgeInsets.only(top: 100, bottom: 8),
            ),
            onNotification: ((ScrollUpdateNotification n) {
              if (n.depth == 0 && n.metrics.pixels <= 200.0) {
                opacity = min(n.metrics.pixels, 100.0) / 100.0;
                if (opacity < 0) opacity = 0;
                if (opacity > 1) opacity = 1;
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
                //color: Theme.of(context).primaryColor.withOpacity(opacity),
                height: topHeight,
              );
            },
          )
        ],
      )),
    );
  }

  //头部
  Widget _buildAlphaAppbar(BuildContext context) {
    final provider = Provider.of<ChapterPageProvider>(context, listen: false);
    final _textTheme = Theme.of(context).primaryTextTheme;
    final _iconTheme = Theme.of(context).primaryIconTheme;

    return AppBar(
      elevation: 0.0,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(opacity),
      textTheme: _textTheme.copyWith(
          headline6: _textTheme.headline6.copyWith(color: Colors.white70)),
      iconTheme: _iconTheme.copyWith(color: Colors.white70),
      actionsIconTheme: _iconTheme.copyWith(color: Colors.white70),
      title: Text(
        searchItem.origin,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      brightness: Brightness.dark,
      titleSpacing: 0.0,
      actions: <Widget>[
        IconButton(
          icon: Icon(FIcons.rotate_cw),
          tooltip: "刷新",
          onPressed: provider.updateChapter,
        ),
        // 加入收藏时需要刷新图标，其他不刷新
        Consumer<ChapterPageProvider>(
          builder: (context, provider, child) => IconButton(
            icon: SearchItemManager.isFavorite(searchItem.originTag, searchItem.url)
                ? Icon(Icons.favorite)
                : Icon(Icons.favorite_border),
            iconSize: 21,
            onPressed: provider.toggleFavorite,
          ),
        ),
        IconButton(
          icon: Icon(FIcons.share_2),
          onPressed: provider.share,
        ),
      ],
    );
  }

  static double lastTopHeight = 0.0;

  //漫画详情
  Widget _comicDetail(BuildContext context) {
    double _top = MediaQuery.of(context).padding.top;
    if (_top <= 0) {
      _top = lastTopHeight;
    } else {
      lastTopHeight = _top;
    }
    final _hero = Utils.empty(searchItem.cover)
        ? null
        : '${searchItem.name}.${searchItem.cover}.${searchItem.id}';

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Stack(
            children: [
              ArcBannerImage(searchItem.cover),
              SizedBox(
                height: 300 + _top,
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: EdgeInsets.only(top: _top),
                    child: Column(
                      children: [
                        SizedBox(height: 45),
                        Expanded(
                          child: Container(
                            child: GestureDetector(
                              child: UIImageItem(cover: searchItem.cover, hero: _hero),
                              onTap: () {
                                Utils.startPageWait(
                                    context,
                                    PhotoViewPage(
                                        items: [PhotoItem(searchItem.cover)],
                                        heroTag: _hero));
                              },
                            ),
                            decoration: BoxDecoration(boxShadow: [
                              BoxShadow(blurRadius: 8, color: Colors.white70)
                            ]),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          searchItem.name,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText1.color,
                            fontWeight: FontWeight.w700,
                            fontFamily: Profile.fontFamily,
                            fontSize: 18,
                            shadows: [Shadow(blurRadius: 2, color: Colors.grey)],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          searchItem.author,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: Profile.fontFamily,
                            color: Theme.of(context).textTheme.bodyText1.color,
                          ),
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
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: searchItem.tags
                        .map(
                          (tag) => Container(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                              child: Text(
                                tag,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: Profile.fontFamily,
                                    fontSize: 10,
                                    color: Colors.white,
                                    height: 1.0),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
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
    final style =
        TextStyle(fontSize: fontSize, color: fontColor, fontFamily: Profile.fontFamily);
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
                  fontFamily: Profile.fontFamily,
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
              fontFamily: Profile.fontFamily,
              color: fontColor,
              letterSpacing: (width - tp.width) / text.length,
            )));
      }
    }
    if (spans.length > 1) {
      spans.removeLast();
    }
    if (spans.length == 0) return SizedBox(height: 16);
    return Container(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 12,
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
      builder: (context, provider, child) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '全部(${searchItem.chapters?.length ?? 0})',
                style: TextStyle(fontSize: 16),
              ),
            ),
            GestureDetector(
              child: Row(
                children: [
                  searchItem.reverseChapter
                      ? SizedBox()
                      : Transform.rotate(
                          child: Icon(Icons.sort, color: theme.primaryColor, size: 18),
                          angle: pi,
                        ),
                  Text(
                    searchItem.reverseChapter ? "倒序" : "顺序",
                    style: TextStyle(color: theme.primaryColor),
                  ),
                  searchItem.reverseChapter
                      ? Icon(Icons.sort, color: theme.primaryColor, size: 18)
                      : SizedBox(),
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
          padding: EdgeInsets.symmetric(
            horizontal: searchItem.ruleContentType == API.NOVEL ? 8 : 20,
            vertical: 8,
          ),
          sliver: searchItem.ruleContentType == API.NOVEL
              ? _buildListView(context, onTap)
              : _buildGridView(context, onTap),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, Function(int index) onTap) {
    return SliverFixedExtentList(
      itemExtent: 50,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final showIndex =
              searchItem.reverseChapter ? searchItem.chaptersCount - index - 1 : index;
          return ListTile(
            title: Text('${searchItem.chapters[showIndex].name}',
                style: TextStyle(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            dense: true,
            selected: showIndex == searchItem.durChapterIndex,
            onTap: () => onTap(showIndex),
          );
        },
        childCount: searchItem.chapters.length,
        addAutomaticKeepAlives: false,
      ),
    );
  }

  Widget _buildGridView(BuildContext context, Function(int index) onTap) {
    final screenWidth = MediaQuery.of(context).size.width;
    var countOfLine = screenWidth ~/ 180;
    if (countOfLine < 2) {
      countOfLine = 2;
    } else if (countOfLine > 6) {
      countOfLine = 6;
    }
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: countOfLine,
        childAspectRatio: (screenWidth - 2 - 16) / 50 / countOfLine,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final showIndex =
              searchItem.reverseChapter ? searchItem.chaptersCount - index - 1 : index;
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
            textColor: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Theme.of(context).primaryColorDark, width: Global.borderSize),
                borderRadius: BorderRadius.circular(3.0)),
            child: child,
          )
        : RaisedButton(
            padding: EdgeInsets.all(4),
            elevation: 0,
            onPressed: onPress,
            color: Theme.of(context).canvasColor,
            textColor: Theme.of(context).textTheme.bodyText1.color,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Theme.of(context).dividerColor, width: Global.borderSize),
                borderRadius: BorderRadius.circular(3.0)),
            child: child,
          );
  }
}

class ArcBannerImage extends StatelessWidget {
  ArcBannerImage(this.imageUrl, {this.arcH = 30.0, this.height = 335.0});
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
              color: Theme.of(context).bottomAppBarColor.withOpacity(0.8),
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
    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy, firstPoint.dx, firstPoint.dy);

    var secondControlPoint = Offset(size.width - (size.width / 4), size.height);
    var secondPoint = Offset(size.width, size.height - widget.arcH);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy, secondPoint.dx, secondPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
