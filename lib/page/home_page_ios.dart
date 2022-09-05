import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/audio_service_handler.dart';
import 'package:eso/page/audio_page.dart';
import 'package:eso/page/audio_view.dart';
import 'package:eso/page/discover_page_ios.dart';
import 'package:eso/page/fast_cats.dart';
import 'package:eso/page/history_page.dart';
import 'package:eso/page/search_page.dart';
import 'package:eso/page/setting/about_page.dart';
import 'package:eso/page/source/editor/highlight_code_editor_theme.dart';
import 'package:eso/page/testListView.dart';
import 'package:eso/ui/widgets/animation_rotate_view.dart';
import 'package:eso/ui/widgets/icon_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../fonticons_icons.dart';
import '../global.dart';
import '../model/page_switch.dart';
import '../profile.dart';
import '../utils.dart';
import 'discover_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isLargeScreen = false;
  CupertinoTabController _tabController = CupertinoTabController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 播放下一个收藏
  void playNextAudio(SearchItem lastItem, [bool reNext]) async {
    final _searchList =
        SearchItemManager.getSearchItemByType(API.AUDIO, SortType.CREATE);
    if (_searchList == null || _searchList.isEmpty) return;
    var index = _searchList.indexOf(lastItem) + 1;
    if (index < 0) index = 0;
    if (index >= _searchList.length) {
      if (reNext == true) return;
      index = 0;
    }
    final item = _searchList[index];
    if (item.chapters.isEmpty) {
      if (SearchItemManager.isFavorite(item.originTag, item.url))
        item.chapters = SearchItemManager.getChapter(item.id);
      if (item.chapters.isEmpty) {
        // 如果还是为空，则尝试加载下一个
        playNextAudio(item, true);
        return;
      }
    }

    // AudioService().playChapter(0, searchItem: item);
  }

  @override
  Widget build(BuildContext context) {
    // return CupertinoPageScaffold(
    //   navigationBar: CupertinoNavigationBar(
    //     transitionBetweenRoutes: false,
    //     backgroundColor: CupertinoColors.systemBackground,
    //     leading: Text("data"),
    //   ),
    //   child: SizedBox.expand(
    //     child: CupertinoButton(
    //         child: Text("data"),
    //         onPressed: () {
    //           showCupertinoModalBottomSheet(
    //             expand: true,
    //             context: context,
    //             backgroundColor: Colors.transparent,
    //             builder: (context) => MyWidget(),
    //           );
    //         }),
    //   ),
    // );

    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        isLargeScreen = true;
      } else {
        isLargeScreen = false;
      }
      final child = CupertinoTabScaffold(
        controller: _tabController,
        tabBar: CupertinoTabBar(
            border: null,
            inactiveColor: CupertinoDynamicColor.withBrightness(
              color: CupertinoColors.black,
              darkColor: CupertinoColors.white,
            ),
            items: [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.heart),
                label: '收藏',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.compass),
                label: '发现',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.gear_big),
                label: '设置',
              ),
            ]),
        tabBuilder: (context, index) {
          // print("tabBuilder");
          switch (index) {
            case 0:
              return FavoritePage();
            case 1:
              return DiscoverPageWinthIOS();
            case 2:
              return AboutPage();
            default:
              return Container();
          }
          // return CupertinoTabView(
          //   builder: (context) {
          //     switch (index) {
          //       case 0:
          //         return FavoritePageWithIOS();
          //       case 1:
          //         return DiscoverPageWinthIOS();
          //       case 2:
          //         return AboutPage();
          //       default:
          //         return Container();
          //     }
          //   },
          // );
        },
      );

      return Stack(
        children: [
          child,
          AudioView(context: context),
        ],
      );
    });
  }

  Color getColor(PageSwitch pageSwitch, BuildContext context, int value) {
    return pageSwitch.currentIndex == value
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyText1.color;
  }
}
