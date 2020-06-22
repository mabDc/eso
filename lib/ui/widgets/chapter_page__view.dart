import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final ChapterPageController _defaultPageController = ChapterPageController();
const PageScrollPhysics _kPagePhysics = PageScrollPhysics();

/// 开始页
const int _beginPage = 0x6fffffff;

/// 加载章节事件
/// [isCurChapter] 是否是当前章节
typedef OnLoadChapterEvent = Future<List<String>> Function(int chapter, bool isCurChapter);
/// 加载章节段落
typedef OnBuildSpans = Future<List<List<TextSpan>>> Function(int chapter, List<String> paragraphs);

typedef ChapterWidgetBuilder = Widget Function(BuildContext context, int chapter, int page, int maxPage, List<TextSpan> spans);

class ChapterPageController extends PageController {
  ChapterPageController({
    int initialPage = 0,
    this.chapter = 0,
    this.maxChapter = 1,
    @required this.onLoadChapter,
    @required this.onBuildSpans,
    double viewportFraction = 1.0,
  }) :
    _initialPage = initialPage,
    super(
      keepPage: true,
      viewportFraction: viewportFraction,
      initialPage: _beginPage
    );

  int chapter;
  final int maxChapter;
  final OnLoadChapterEvent onLoadChapter;
  final OnBuildSpans onBuildSpans;

  final int _initialPage;

  List<List<TextSpan>> spans;

  List<List<TextSpan>> _prev = [];
  List<List<TextSpan>> _next = [];

  int get pageCount => spans?.length ?? 0;
  int get curPage => initialPage == 0 ? page.round() : page.round() - initialPage;

  _cacheChapter(int chapter) async {
    if (chapter < 0) return;
    if (chapter >= maxChapter) return;
    final _data = await onLoadChapter(chapter, false);
    final _spans = await onBuildSpans(chapter, _data);
    if (_spans == null || _spans.isEmpty)
      return;
    if (chapter == this.chapter - 1) {
      _prev = _spans ?? [];
    } else if (chapter == this.chapter + 1) {
      _next = _spans ?? [];
    }
  }

  int _loadingChapter = -1;

  Future<bool> toChapter(int chapter, {bool toFirst}) async {
    if (_loadingChapter == chapter) return false;
    if (chapter == this.chapter && spans != null) return false;
    if (chapter < 0 || chapter >= maxChapter) return false;
    _loadingChapter = chapter;
    final _data = await onLoadChapter(chapter, true);
    spans = await onBuildSpans(chapter, _data);
    this.chapter = chapter;
    _loadingChapter = -1;
    if (toFirst == true && curPage != 0)
      this.jumpToPage(initialPage);
    return true;
  }

  initChapter() async {
    await toChapter(chapter);
    // 缓存
    if (_prev == null || _prev.isEmpty)
      _cacheChapter(chapter - 1);
    if (_next == null || _next.isEmpty)
      _cacheChapter(chapter + 1);
    if (_initialPage > 0)
      this.jumpToPage(initialPage + _initialPage);
  }

  toPrevChapter() async {
    var _tmpPrev = _prev;
    var _tmpNext = _next;
    _next = spans;
    _prev = [];
    if (!await toChapter(chapter - 1)) {
      _prev = _tmpPrev;
      _next = _tmpNext;
      animateToPage(initialPage, duration: Duration(milliseconds: 800), curve: Curves.easeOut);
      return;
    }
    if (_prev == null || _prev.isEmpty)
      _cacheChapter(chapter - 1);
    this.jumpToPage(initialPage + pageCount - 1);
  }

  toNextChapter() async {
    var _tmpPrev = _prev;
    var _tmpNext = _next;
    _prev = spans;
    _next = [];
    if (!await toChapter(chapter + 1)) {
      _prev = _tmpPrev;
      _next = _tmpNext;
      animateToPage(initialPage + pageCount - 1, duration: Duration(milliseconds: 800), curve: Curves.easeIn);
      return;
    }
    if (_next == null || _next.isEmpty)
      _cacheChapter(chapter + 1);
    this.jumpToPage(initialPage);
  }
}

/// 章节 PageView
class ChapterPageView extends StatefulWidget {
  ChapterPageView({
    Key key,
    this.scrollDirection = Axis.horizontal,
    ChapterPageController controller,
    @required this.builder,
    this.dragStartBehavior = DragStartBehavior.start,
    this.reverse = false,
    this.onPageChanged,
  }): controller = controller ?? _defaultPageController,
      super(key: key);

  final ChapterPageController controller;
  final bool reverse;
  final Axis scrollDirection;
  final ChapterWidgetBuilder builder;
  final ValueChanged<int> onPageChanged;
  final DragStartBehavior dragStartBehavior;

  @override
  State<StatefulWidget> createState() => _ChapterPageViewState();
}

class _ChapterPageViewState extends State<ChapterPageView> {
  int _lastReportedPage = 0;

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.controller.initialPage;
    widget.controller.initChapter();
  }

  AxisDirection _getDirection(BuildContext context) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection = textDirectionToAxisDirection(textDirection);
        return widget.reverse ? flipAxisDirection(axisDirection) : axisDirection;
      case Axis.vertical:
        return widget.reverse ? AxisDirection.up : AxisDirection.down;
    }
    return null;
  }

  double abs(double v) {
    if (v < 0) return -v;
    return v;
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics physics = _kPagePhysics.applyTo(BouncingScrollPhysics());
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.depth == 0 && widget.onPageChanged != null && notification is ScrollUpdateNotification) {
          final PageMetrics metrics = notification.metrics as PageMetrics;
          final int currentPage = metrics.page.round();
          if (currentPage != _lastReportedPage) {
            _lastReportedPage = currentPage;
            final _realPage = widget.controller.initialPage == 0 ? currentPage : currentPage - widget.controller.initialPage;
            widget.onPageChanged(_realPage);
            if (_realPage < 0)
              widget.controller.toPrevChapter();
            else if (_realPage >= widget.controller.pageCount)
              widget.controller.toNextChapter();
          }
        }
        return false;
      },
      child: Scrollable(
        dragStartBehavior: widget.dragStartBehavior,
        axisDirection: axisDirection,
        controller: widget.controller,
        physics: physics,
        viewportBuilder: (BuildContext context, ViewportOffset position) {
          return Viewport(
            cacheExtent: 0.0,
            cacheExtentStyle: CacheExtentStyle.viewport,
            axisDirection: axisDirection,
            offset: position,
            slivers: <Widget>[
              SliverFillViewport(
                viewportFraction: widget.controller.viewportFraction,
                delegate: SliverChildBuilderDelegate((context, index) {
                  final _page = widget.controller.initialPage == 0 ? index : index - widget.controller.initialPage;
                  if (_page < 0 && widget.controller.chapter <= 0) {
                    return Container();
                  }
                  if (_page >= widget.controller.pageCount && widget.controller.chapter >= widget.controller.maxChapter) {
                    return Container();
                  }

                  if (_page < 0) {
                    return widget.builder(context, widget.controller.chapter - 1,
                        widget.controller._prev.length - 1,
                        widget.controller._prev.length,
                        widget.controller._prev.isEmpty ? null : widget
                            .controller._prev.last);
                  }
                  if (_page >= widget.controller.pageCount) {
                    return widget.builder(context, widget.controller.chapter + 1,
                        0,
                        widget.controller._next.length,
                        widget.controller._next.isEmpty ? null : widget
                            .controller._next.first);
                  }
                  return widget.builder(context,
                      widget.controller.chapter,
                      _page,
                      widget.controller.pageCount,
                      _page >= widget.controller.pageCount ? null : widget
                          .controller.spans[_page]);
                }, childCount: null),
              ),
            ],
          );
        }
      ),
    );
  }
}
