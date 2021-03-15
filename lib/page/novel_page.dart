import 'dart:ui';

import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/profile.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_novel_menu.dart';
import 'package:eso/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// 文字阅读页面
class NovelPage extends StatefulWidget {
  final SearchItem searchItem;
  const NovelPage({this.searchItem, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NovelPageState(this.searchItem);
}

class _NovelPageState extends State<NovelPage> {
  final SearchItem searchItem;
  _NovelPageState(this.searchItem) : super();

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<Profile>(context, listen: false);
    final FocusNode _backNode = new FocusNode();
    final height = MediaQuery.of(context).size.height - 100;
    return ChangeNotifierProvider<NovelPageProvider>(
      create: (BuildContext context) => NovelPageProvider(
        searchItem: searchItem,
        keepOn: profile.novelKeepOn,
        profile: profile,
        height: height,
      ),
      builder: (context, child) => Scaffold(
        body: Consumer2<NovelPageProvider, Profile>(
          builder:
              (BuildContext context, NovelPageProvider provider, Profile profile, _) {
            if (provider.paragraphs == null) {
              return LandingPage();
            }
            updateSystemChrome(provider.showMenu, profile);
            return RawKeyboardListener(
              focusNode: _backNode,
              autofocus: true,
              onKey: (event) {
                if (event.runtimeType.toString() == 'RawKeyUpEvent') return;
                if (event.data is RawKeyEventDataMacOs ||
                    event.data is RawKeyEventDataLinux ||
                    event.data is RawKeyEventDataWindows) {
                  final logicalKey = event.data.logicalKey;
                  print(logicalKey);
                  if (logicalKey == LogicalKeyboardKey.arrowUp ||
                      logicalKey == LogicalKeyboardKey.arrowLeft ||
                      logicalKey == LogicalKeyboardKey.pageUp) {
                    provider.tapLastPage();
                  } else if (logicalKey == LogicalKeyboardKey.arrowDown ||
                      logicalKey == LogicalKeyboardKey.arrowRight ||
                      logicalKey == LogicalKeyboardKey.pageDown) {
                    provider.tapNextPage();
                  } else if (logicalKey == LogicalKeyboardKey.bracketLeft ||
                      logicalKey == LogicalKeyboardKey.minus ||
                      logicalKey == LogicalKeyboardKey.insert) {
                    provider.loadChapter(searchItem.durChapterIndex - 1);
                  } else if (logicalKey == LogicalKeyboardKey.bracketRight ||
                      logicalKey == LogicalKeyboardKey.numpadAdd ||
                      logicalKey == LogicalKeyboardKey.delete) {
                    provider.loadChapter(searchItem.durChapterIndex + 1);
                  } else if (logicalKey == LogicalKeyboardKey.enter ||
                      logicalKey == LogicalKeyboardKey.numpadEnter) {
                    provider.showMenu = !provider.showMenu;
                  } else if (logicalKey == LogicalKeyboardKey.escape) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: GestureDetector(
                child: Stack(
                  children: <Widget>[
                    AnnotatedRegion<SystemUiOverlayStyle>(
                      value: Global.novelLightOrDark(),
                      child: Container(
                        decoration: Utils.getNovelBackground(),
                        child: _buildContent(provider, profile),
                      ),
                    ),
                    if (provider.showChapter || provider.showMenu || provider.showSetting)
                      WillPopScope(
                        onWillPop: () async {
                          provider.showChapter = false;
                          provider.showSetting = false;
                          provider.showMenu = false;
                          return false;
                        },
                        child: SizedBox(),
                      ),
                    if (provider.showMenu)
                      UINovelMenu(searchItem: searchItem, profile: profile),
                    if (provider.showChapter)
                      UIChapterSelect(
                        searchItem: searchItem,
                        loadChapter: provider.loadChapter,
                      ),
                    if (provider.isLoading)
                      Opacity(
                        opacity: 0.8,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context).canvasColor,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 42, vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CupertinoActivityIndicator(),
                                SizedBox(height: 20),
                                Text(
                                  "加载中...",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onTapUp: (TapUpDetails details) {
                  final size = MediaQuery.of(context).size;
                  final _centerL = size.width * (1 / 3);
                  final _centerR = size.width - _centerL;
                  final _centerT = size.height * (1 / 3);
                  final _centerB = size.height - _centerT;

                  if (details.globalPosition.dx > _centerL &&
                      details.globalPosition.dx < _centerR &&
                      details.globalPosition.dy > _centerT &&
                      details.globalPosition.dy < _centerB) {
                    provider.showMenu = !provider.showMenu;
                    provider.showSetting = false;
                  } else {
                    provider.showChapter = false;
                    if (!provider.showSetting && !provider.showMenu) {
                      if (details.globalPosition.dx > size.width * 0.5) {
                        provider.tapNextPage();
                      } else if (details.globalPosition.dx < size.width * 0.5) {
                        provider.tapLastPage();
                      }
                    }
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }

  bool lastShowMenu;

  updateSystemChrome(bool showMenu, Profile profile) {
    if (showMenu == lastShowMenu) return;
    lastShowMenu = showMenu;
    if (showMenu) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    } else if (!profile.showNovelStatus) {
      SystemChrome.setEnabledSystemUIOverlays([]);
    }
  }

  Widget _buildContent(NovelPageProvider provider, Profile profile) {
    final size = MediaQuery.of(context).size;
    if (provider.didUpdateReadSetting(profile, size))
      provider.buildTextComposition(profile);

    var scrollDirection = Axis.horizontal;
    var pageSnapping = true;

    final info = SizedBox(
      height: 32,
      child: Center(
        child:
            Text("${searchItem.durChapter}   共 ${provider.textComposition.pageCount} 页"),
      ),
    );

    switch (profile.novelPageSwitch) {
      case Profile.novelNone:
        return Column(
          children: [
            Expanded(child: provider.getTextCompositionPage()),
            if (profile.showNovelInfo) info
          ],
        );
      case Profile.novelScroll:
        scrollDirection = Axis.vertical;
        pageSnapping = false;
        break;
      case Profile.novelCover:
        break;
      case Profile.novelHorizontalSlide:
      case Profile.novelVerticalSlide:
      case Profile.novelFade:
        break;
      default:
        return Center(child: Text("换页方式暂不支持\n请选择其他方式"));
    }
    final page = PageView.builder(
      controller: provider.controller,
      onPageChanged: (value) => provider.currentPage = value,
      pageSnapping: pageSnapping,
      scrollDirection: scrollDirection,
      physics: BouncingScrollPhysics(),
      itemCount: provider.textComposition.pageCount,
      itemBuilder: (BuildContext context, int position) {
        if (scrollDirection == Axis.horizontal && profile.showNovelInfo) {
          return Column(
            children: [Expanded(child: provider.getTextCompositionPage(position)), info],
          );
        }
        return provider.getTextCompositionPage(position);
      },
    );
    if (scrollDirection == Axis.vertical && profile.showNovelInfo) {
      return Column(
        children: [Expanded(child: page), info],
      );
    }
    return page;
  }
}
