import 'dart:ui';

import 'package:eso/database/search_item.dart';
import 'package:eso/model/novel_page_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/page/novel/novel_route_view.dart';
import 'package:eso/page/novel/novel_none_view.dart';
import 'package:eso/page/novel/novel_scroll_view.dart';
import 'package:eso/ui/ui_chapter_select.dart';
import 'package:eso/ui/ui_novel_menu.dart';
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
            return RawKeyboardListener(
              focusNode: _backNode,
              onKey: (event) {
                if (event.runtimeType.toString() != provider.enPress) {
                  provider.enPress = event.runtimeType.toString();
                  // 按下时触发
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
                      provider.switchChapter(profile, searchItem.durChapterIndex - 1);
                    } else if (logicalKey == LogicalKeyboardKey.bracketRight ||
                        logicalKey == LogicalKeyboardKey.numpadAdd ||
                        logicalKey == LogicalKeyboardKey.delete) {
                      provider.switchChapter(profile, searchItem.durChapterIndex + 1);
                    } else if (logicalKey == LogicalKeyboardKey.enter ||
                        logicalKey == LogicalKeyboardKey.numpadEnter) {
                      provider.showMenu = !provider.showMenu;
                    }
                  }
                }
              },
              child: GestureDetector(
                child: Stack(
                  children: <Widget>[
                    AnnotatedRegion<SystemUiOverlayStyle>(
                      value: SystemUiOverlayStyle.light,
                      child: _buildContent(provider, profile),
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
                        loadChapter: (index) {
                          provider.switchChapter(profile, index);
                        },
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
                  if (provider.showMenu || provider.showSetting) {
                    provider.showMenu = false;
                    provider.showSetting = false;
                    return;
                  }

                  final size = MediaQuery.of(context).size;
                  final _centerX = size.width * (1 / 4);
                  final _centerR = size.width - _centerX;
                  final _centerY = 100;
                  final _centerB = size.height - size.height * (1 / 3);

                  if (details.globalPosition.dx > _centerX &&
                      details.globalPosition.dx < _centerR &&
                      details.globalPosition.dy > _centerY &&
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

  Widget _buildContent(NovelPageProvider provider, Profile profile) {
    switch (profile.novelPageSwitch) {
      case Profile.novelScroll:
        return NovelScrollView(
            profile: profile, provider: provider, searchItem: searchItem);
      case Profile.novelNone:
        return NovelNoneView(
            profile: profile, provider: provider, searchItem: searchItem);
      case Profile.novelCover:
      case Profile.novelFade:
        return NovelRoteView(
            profile: profile, provider: provider, searchItem: searchItem);
      default:
        return Center(child: Text("换页方式暂不支持\n请选择其他方式"));
    }
  }
}
