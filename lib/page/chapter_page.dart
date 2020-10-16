import 'dart:math';
import 'dart:ui';
import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
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
                            fontFamily: Profile.staticFontFamily,
                            fontSize: 18,
                            shadows: [Shadow(blurRadius: 2, color: Colors.grey)],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          searchItem.author,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: Profile.staticFontFamily,
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
                                    fontFamily: Profile.staticFontFamily,
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
    final style = TextStyle(
        fontSize: fontSize, color: fontColor, fontFamily: Profile.staticFontFamily);
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
                  fontFamily: Profile.staticFontFamily,
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
              fontFamily: Profile.staticFontFamily,
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
    // final theme = Theme.of(context);
    return Consumer<ChapterPageProvider>(
      builder: (context, provider, child) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        child: Text(
          '全部(${searchItem.chapters?.length ?? 0})',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  List<ChapterRoad> parseChapers(List<ChapterItem> chapters) {
    final roads = <ChapterRoad>[];
    if (chapters.isEmpty || !chapters.first.name.startsWith('@线路')) return roads;
    var roadName = chapters.first.name.substring(3);
    var startIndex = 1;
    for (var i = 1, len = chapters.length; i < len; i++) {
      if (chapters[i].name.startsWith('@线路')) {
        // 上一个线路
        roads.add(ChapterRoad(roadName, startIndex, i - startIndex));
        roadName = chapters[i].name.substring(3);
        startIndex = i + 1;
      }
    }
    // 最后一个线路
    roads.add(ChapterRoad(roadName, startIndex, chapters.length - startIndex));
    return roads;
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

        final roads = parseChapers(searchItem.chapters);
        if (roads.isEmpty) {
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final chapter = searchItem.chapters[index];
                  if (chapter.url == null || chapter.url.isEmpty) {
                    return Card(child: ListTile(title: Text(chapter.name)));
                  }
                  return Card(
                    child: ListTile(
                      onTap: () => onTap(index),
                      title: Text(
                        chapter.name,
                        style: TextStyle(
                          color: index == searchItem.durChapterIndex
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodyText1.color,
                        ),
                      ),
                    ),
                  );
                },
                childCount: searchItem.chapters.length,
              ),
            ),
          );
        }

        var currentRoad = 0;
        return StatefulBuilder(
          builder: (BuildContext context, setState) => SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index == 0) {
                    return Row(
                      children: [
                        Container(
                          height: 40,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 10),
                          child: Text('线路(${roads.length}):'),
                        ),
                        Expanded(
                          child: Container(
                            height: 40,
                            alignment: Alignment.centerLeft,
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              separatorBuilder: (context, index) => Container(
                                  alignment: Alignment.center, child: Text('|')),
                              scrollDirection: Axis.horizontal,
                              itemCount: roads.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    currentRoad = index;
                                    setState(() => null);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${roads[index].name}(${roads[index].length})',
                                      style: TextStyle(
                                        color: index == currentRoad
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).textTheme.bodyText1.color,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  if (index == 1) {
                    return Divider();
                  }

                  final road = roads[currentRoad];
                  final chapterIndex = road.startIndex + index - 2;
                  final chapter = searchItem.chapters[chapterIndex];
                  if (chapter.url == null || chapter.url.isEmpty) {
                    return Card(child: ListTile(title: Text(chapter.name)));
                  }
                  return Card(
                    child: ListTile(
                      onTap: () => onTap(road.startIndex + index),
                      title: Text(
                        searchItem.chapters[chapterIndex].name,
                        style: TextStyle(
                          color: chapterIndex == searchItem.durChapterIndex
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).textTheme.bodyText1.color,
                        ),
                      ),
                    ),
                  );
                },
                childCount: roads[currentRoad].length + 2,
              ),
            ),
          ),
        );
      },
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

class ChapterRoad {
  final String name;
  final int startIndex;
  final int length;
  ChapterRoad(this.name, this.startIndex, this.length);
}
