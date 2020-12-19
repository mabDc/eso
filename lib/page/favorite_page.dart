import 'package:eso/api/api.dart';
import 'package:eso/profile.dart';
import 'package:eso/page/setting/about_page.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:eso/ui/round_indicator.dart';
import 'package:eso/page/favorite_list_page.dart';
import '../fonticons_icons.dart';
import 'history_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key key}) : super(key: key);

  static const tabs = [
    ["文字", API.NOVEL],
    ["图片", API.MANGA],
    ["音频", API.AUDIO],
    ["视频", API.VIDEO],
  ];

  @override
  Widget build(BuildContext context) {
    if (Profile().version != Profile().lastestVersion) {
      Future.delayed(
          Duration(milliseconds: 10), () => AboutPage.showAbout(context, true));
    }
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          elevation: 0,
          title: TabBar(
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).textTheme.bodyText1.color,
            indicator: RoundTabIndicator(
                insets: EdgeInsets.only(left: 5, right: 5),
                borderSide:
                    BorderSide(width: 3.0, color: Theme.of(context).primaryColor)),
            tabs: tabs
                .map((tab) => Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: Text(
                      tab[0],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: Profile.staticFontFamily),
                    )))
                .toList(),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.history),
              tooltip: "浏览历史",
              onPressed: () => Utils.startPageWait(context, HistoryPage()),
            ),
            IconButton(
              icon: Icon(FIcons.settings),
              tooltip: "设置",
              onPressed: () => Utils.startPageWait(context, AboutPage()),
            ),
          ],
        ),
        body: TabBarView(
          children: tabs.map((tab) => FavoriteListPage(type: tab[1])).toList(),
        ),
      ),
    );
  }
}
