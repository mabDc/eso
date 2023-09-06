import 'dart:math';
import 'dart:ui';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/main.dart';
import 'package:eso/menu/menu.dart';
import 'package:eso/menu/menu_chapter.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/page/photo_view_page.dart';
import 'package:flutter/foundation.dart';
import 'package:text_composition/text_composition.dart';
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
import '../model/chapter_page_provider.dart';
import 'content_page_manager.dart';
import 'langding_page.dart';

class NextPageAnimation extends StatefulWidget {
  final String text;
  const NextPageAnimation({Key key, this.text = "加载下一页。。。"}) : super(key: key);

  @override
  State<NextPageAnimation> createState() => _NextPageAnimationState();
}

class _NextPageAnimationState extends State<NextPageAnimation> {
  int count = 0;

  @override
  void initState() {
    start();
    super.initState();
  }

  @override
  void dispose() {
    count = -1;
    super.dispose();
  }

  void start() {
    if (count == -1 || !mounted) return;
    if (kDebugMode) {
      print("播放动画 $count");
    }
    Future.delayed(const Duration(milliseconds: 200), start);
    setState(() {
      count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    return Text(text.substring(0, count % (text.length + 1)));
  }
}

class ChapterPage extends StatefulWidget {
  final SearchItem searchItem;
  final bool fromHistory;
  const ChapterPage({this.searchItem, this.fromHistory = false, Key key})
      : super(key: key);

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
      builder: (context, child) => Container(
        decoration: globalDecoration,
        child: Scaffold(
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
            ),
            buildPage(context),
          ],
        )),
      ),
    );
  }

  Widget buildPage(BuildContext context) {
    final page = Provider.of<ChapterPageProvider>(context, listen: true).page;
    print(page);
    if (page > 0)
      return Positioned(
        right: 20,
        bottom: 10,
        child: Row(
          children: [
            Text("${Provider.of<ChapterPageProvider>(context).page}"),
            NextPageAnimation(text: "页加载中")
          ],
        ),
      );
    return Positioned(
      right: 20,
      bottom: 10,
      child: Card(child: Text("${-Provider.of<ChapterPageProvider>(context).page}页")),
    );
  }

  //头部
  Widget _buildAlphaAppbar(BuildContext context) {
    final provider = Provider.of<ChapterPageProvider>(context, listen: false);

    return AppBar(
      elevation: 0.0,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor.withOpacity(opacity),
      title: Text(
        searchItem.origin,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: <Widget>[
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
        Menu<MenuChapter>(
          items: chapterMenus,
          onSelect: (value) => provider.onSelect(value, context),
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
                                        items: [PhotoItem.parse(searchItem.cover)],
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
                            fontFamily: ESOTheme.staticFontFamily,
                            fontSize: 18,
                            shadows: [Shadow(blurRadius: 2, color: Colors.grey)],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          searchItem.author,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: ESOTheme.staticFontFamily,
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
                                    fontFamily: ESOTheme.staticFontFamily,
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
          _sortWidget(context),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, String description) {
    return Container(child: LayoutBuilder(builder: (context, constrains) {
      return TextCompositionWidget(
        paragraphs: description
            .split(RegExp(r"^\s*|(\s{2,}|\n)\s*"))
            .map((s) => s.trimLeft())
            .toList(),
        config: TextCompositionConfig(
          fontSize: 12,
          paragraphPadding: 8,
          fontFamily: ESOTheme.staticFontFamily,
          fontColor: Theme.of(context).textTheme.headline6.color,
        ),
        width: constrains.maxWidth,
      );
    }));
  }

  // 排序
  Widget _sortWidget(BuildContext context) {
    return Consumer<ChapterPageProvider>(builder: (context, provider, child) {
      void Function(int index) onTap = (int index) {
        provider.changeChapter(index);
        Navigator.of(context)
            .push(ContentPageRoute().route(searchItem))
            .whenComplete(provider.adjustScroll);
      };
      if (searchItem.chapters == null || searchItem.chapters.isEmpty) {
        return Container();
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Card(
              child: TextButton(
                  onPressed: () {
                    if (searchItem.chapters.isNotEmpty)
                      onTap(searchItem.chapters.length - 1);
                  },
                  child: Text(
                    "更至（${searchItem.chapters.length}）${searchItem.chapters.isNotEmpty ? searchItem.chapters.last.name : "无"}",
                    style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
                  )),
            ),
            Card(
              child: TextButton(
                  onPressed: () {
                    onTap(searchItem.durChapterIndex);
                  },
                  child: Text(
                    "阅至（${searchItem.durChapterIndex}）${searchItem.durChapter}",
                    style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
                  )),
            ),
            Divider(),
          ],
        ),
      );
    });
    // final theme = Theme.of(context);
    // return Consumer<ChapterPageProvider>(
    //   builder: (context, provider, child) => Padding(
    //     padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
    //     child: Row(
    //       children: [
    //         Text(
    //           '全部 ${searchItem.chapters?.length ?? 0} (阅至 ${searchItem.durChapterIndex + 1}) ',
    //           style: TextStyle(fontSize: 16),
    //         ),
    //         if (searchItem.chapters != null && searchItem.chapters.isNotEmpty)
    //           () {
    //             try {
    //               final chapter = searchItem.chapters[searchItem.durChapterIndex];
    //               return Expanded(
    //                 child: OutlinedButton(
    //                   onPressed: () => Navigator.of(context)
    //                       .push(ContentPageRoute().route(searchItem))
    //                       .whenComplete(provider.adjustScroll),
    //                   child: Text(
    //                     "${chapter.name}",
    //                     textAlign: TextAlign.start,
    //                     style: TextStyle(color: Theme.of(context).primaryColor),
    //                     overflow: TextOverflow.ellipsis,
    //                     maxLines: 1,
    //                   ),
    //                   style: ButtonStyle(alignment: Alignment.centerLeft),
    //                 ),
    //               );
    //             } catch (e) {
    //               return Container();
    //             }
    //           }(),
    //       ],
    //     ),
    //   ),
    // );
  }

  List<ChapterRoad> parseChapers(List<ChapterItem> chapters) {
    currentRoad = 0;
    final roads = <ChapterRoad>[];
    if (chapters.isEmpty || !chapters.first.name.startsWith('@线路')) return roads;
    var roadName = chapters.first.name.substring(3);
    var startIndex = 1;
    for (var i = 1, len = chapters.length; i < len; i++) {
      if (chapters[i].name.startsWith('@线路')) {
        if (searchItem.durChapterIndex >= startIndex && searchItem.durChapterIndex < i) {
          currentRoad = roads.length;
        }
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

  Widget buildChapterButton(int chapterIndex, void Function(int) onTap) {
    final chapter = searchItem.chapters[chapterIndex];
    if (chapter.url == null || chapter.url.isEmpty) {
      return ListTile(
        title: Text(
          chapter.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 6),
      );
    }
    return Card(
      child: ListTile(
        onTap: () => onTap(chapterIndex),
        title: Text(
          chapter.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: chapterIndex == searchItem.durChapterIndex
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyText1.color,
          ),
        ),
        subtitle: chapter.time == null || chapter.time.isEmpty
            ? null
            : Text(
                chapter.time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chapterIndex == searchItem.durChapterIndex
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
        trailing: chapter.cover == null || chapter.cover.isEmpty
            ? null
            : UIImageItem(
                cover: chapter.cover,
                fit: BoxFit.cover,
                initHeight: 50,
                initWidth: 50,
              ),
      ),
    );
  }

  var currentRoad = 0;

  Widget _buildChapter(BuildContext context) {
    return Consumer<ChapterPageProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SliverToBoxAdapter(
            child: Container(height: 200, child: LandingPage()),
          );
        }
        // if (!widget.fromHistory &&
        //     searchItem.chapters != null &&
        //     searchItem.chapters.length > 0 &&
        //     searchItem.chapters.first.name == "正文") {
        //   Future.delayed(Duration(milliseconds: 100)).then((value) =>
        //       Navigator.of(context)
        //           .pushReplacement(ContentPageRoute().route(searchItem)));
        // }

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
                  return buildChapterButton(index, onTap);
                },
                childCount: searchItem.chapters.length,
              ),
            ),
          );
        }

        return StatefulBuilder(
          builder: (BuildContext context, setState) => SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index == 0) {
                    return Wrap(
                      spacing: 10,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < roads.length; i++)
                          TextButton(
                            onPressed: () {
                              currentRoad = i;
                              setState(() => null);
                            },
                            child: Container(
                              child: Text(
                                '${roads[i].name}(${roads[i].length})'.padRight(10),
                                maxLines: 2,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  color: i == currentRoad
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).textTheme.bodyText1.color,
                                ),
                              ),
                            ),
                          )
                      ],
                    );
                  }

                  return buildChapterButton(
                      roads[currentRoad].startIndex + index - 1, onTap);
                },
                childCount: roads[currentRoad].length + 1,
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
