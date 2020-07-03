import 'dart:async';

import 'package:eso/database/search_item.dart';
import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/page/novel/novel_drag_view.dart';
import 'package:eso/page/novel/novel_one_page_view.dart';
import 'package:eso/ui/route/empty_page_route.dart';
import 'package:eso/ui/route/fade_page_route.dart';
import 'package:eso/ui/route/pop_route.dart';
import 'package:flutter/material.dart';

/// 导航翻页模式
class NovelRoteView extends StatelessWidget {
  final NovelPageProvider provider;
  final Profile profile;
  final SearchItem searchItem;

  const NovelRoteView({Key key, this.profile, this.provider, this.searchItem})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    final _spans = provider.didUpdateReadSetting(profile)
        ? provider.updateSpans(NovelPageProvider.buildSpans(
            profile, provider.searchItem, provider.paragraphs))
        : provider.spans;

    return NovelDragView(
      provider: provider,
      profile: profile,
      child: Navigator(
          initialRoute: '/',
          onGenerateRoute: (settings) {
            WidgetBuilder builder;
            bool isNext = true;
            switch (settings.name) {
              case '/':
                builder = (context) => _CoverPage(owner: this, spans: _spans);
                break;
              case '/up':
                builder = (context) => _CoverPage(owner: this, spans: _spans);
                isNext = false;
                break;
            }
            if (profile.novelPageSwitch == Profile.novelFade) {
              return FadePageRoute(builder: builder, milliseconds: 350, isNext: isNext);
            }
            if (profile.novelPageSwitch == Profile.novelCover) {
              return EmptyPageRoute(builder: builder);
            }
            return MaterialPageRoute(builder: builder);
          }),
    );
  }
}

class _CoverPage extends StatefulWidget {
  final NovelRoteView owner;
  final List<List<TextSpan>> spans;
  const _CoverPage({Key key, this.owner, this.spans}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _CoverPageState();
}

class _CoverPageState extends State<_CoverPage> with SingleTickerProviderStateMixin {
  NovelRoteView owner;
  Widget lastPage;
  int lastPageIndex, lastChapterIndex;

  AnimationController _controller;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    owner = widget.owner;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isChangePage = (!owner.provider.showMenu &&
        (lastPageIndex != owner.provider.currentPage ||
            lastChapterIndex != owner.searchItem.durChapterIndex));
    if (lastPage != null) {
      if (isChangePage) {
        if (owner.profile.novelPageSwitch == Profile.novelCover) {

          if (_controller == null) {
            _controller = AnimationController(
              vsync: this,
              duration: Duration(milliseconds: 350),
            );
            _animation = CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInToLinear,
            );
          }

          bool _isNext = isNext;
          var _last = lastPage;
          lastPage = buildPage();
          if (_isNext)
            _controller.forward(from: 0.0);
          else
            _controller.forward(from: -1.2);
          return Stack(
            children: _isNext ? [
              lastPage,
              SlideTransition(position: _animation.drive(
                  Tween(end: Offset(-1.2, 0.0), begin: Offset.zero)
                      .chain(CurveTween(curve: Curves.ease))), child: _last),
            ] : [
              _last,
              SlideTransition(position: _animation.drive(
                  Tween(begin: Offset(-1.2, 0.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.ease))), child: lastPage),
            ],
          );
        } else {
          changePage();
        }
      }
      return lastPage;
    }
    lastPage = buildPage();
    return lastPage;
  }

  Widget buildPage() {
    lastPageIndex = owner.provider.currentPage;
    lastChapterIndex = owner.searchItem.durChapterIndex;
    return Material(
      elevation: 20,
      child: NovelOnePageView(
        provider: owner.provider,
        profile: owner.profile,
        spans: widget.spans[owner.provider.currentPage - 1],
        fontColor: Color(owner.profile.novelFontColor),
        pageInfo: '${owner.provider.currentPage}/${widget.spans.length}',
        chapterName: owner.searchItem.durChapter,
      ),
    );
  }

  int get curChapterIndex => owner.searchItem.durChapterIndex;

  // 是否进入下一页
  bool get isNext => !(curChapterIndex < lastChapterIndex ||
      (curChapterIndex == lastChapterIndex &&
          lastPageIndex > owner.provider.currentPage
      ));

  changePage() async {
    Timer(Duration(milliseconds: 20), () {
      Navigator.pushReplacementNamed(context, isNext ? '/' : '/up');
    });
  }
}
