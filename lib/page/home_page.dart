import 'dart:async';

import 'package:eso/page/search_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../fonticons_icons.dart';
import '../global.dart';
import '../model/page_switch.dart';
import '../model/profile.dart';
import '../utils.dart';
import 'discover_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription stream;
  bool lastAudioPlaying = false;
  StateSetter _audioState;

  @override
  void dispose() {
    stream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => PageSwitch(Global.currentHomePage),
      child: Consumer<PageSwitch>(
        builder: (BuildContext context, PageSwitch pageSwitch, Widget widget) {
          Global.currentHomePage = pageSwitch.currentIndex;
          pageSwitch.updatePageController();
          final _pageView = PageView(
            controller: pageSwitch.pageController,
            children: <Widget>[
              FavoritePage(),
              DiscoverPage(),
            ],
            onPageChanged: (index) => pageSwitch.changePage(index, false),
            physics: NeverScrollableScrollPhysics(), //禁止主页左右滑动
          );
          return Scaffold(
            body: _pageView,
            bottomNavigationBar: Consumer<Profile>(
              builder: (BuildContext context, Profile profile, Widget widget) {
                //bool isDark = Theme.of(context).brightness == Brightness.dark;
                return BottomAppBar(
                  color: Theme.of(context).canvasColor,
                  shape: CircularNotchedRectangle(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            onPressed: () => pageSwitch.changePage(0),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  FIcons.heart,
                                  color: getColor(pageSwitch, context, 0),
                                ),
                                Text(
                                  "收藏",
                                  style:
                                      TextStyle(color: getColor(pageSwitch, context, 0)),
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () => pageSwitch.changePage(1),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(FIcons.compass,
                                    color: getColor(pageSwitch, context, 1)),
                                Text("发现",
                                    style: TextStyle(
                                        color: getColor(pageSwitch, context, 1)))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              elevation: 1,
              tooltip: "搜索",
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () => Utils.startPageWait(context, SearchPage())
                  .whenComplete(() => pageSwitch.refreshList()),
              child: Icon(FIcons.search, color: Theme.of(context).canvasColor),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }

  Color getColor(PageSwitch pageSwitch, BuildContext context, int value) {
    return pageSwitch.currentIndex == value
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyText1.color;
  }
}
