import 'package:eso/api/api.dart';
import 'package:eso/page/setting/auto_backup_page.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/page/setting/about_page.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:eso/ui/round_indicator.dart';
import 'package:eso/page/favorite_list_page.dart';
import '../fonticons_icons.dart';
import '../global.dart';
import '../main.dart';
import '../menu/menu.dart';
import '../menu/menu_favorite.dart';
import 'add_local_item_page.dart';
import 'history_page.dart';
import 'search_page.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  var isLargeScreen = false;
  Widget detailPage;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        isLargeScreen = true;
      } else {
        isLargeScreen = false;
      }

      return Row(children: <Widget>[
        Expanded(
          child: FavoritePage2(invokeTap: (Widget detailPage) {
            if (isLargeScreen) {
              this.detailPage = detailPage;
              setState(() {});
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => detailPage,
                  ));
            }
          }),
        ),
        SizedBox(
          height: double.infinity,
          width: 2,
          child: Material(
            color: Colors.grey.withAlpha(123),
          ),
        ),
        isLargeScreen ? Expanded(child: detailPage ?? Scaffold()) : Container(),
      ]);
    });
  }
}

class FavoritePage2 extends StatelessWidget {
  final void Function(Widget) invokeTap;
  const FavoritePage2({Key key, this.invokeTap}) : super(key: key);

  static const tabs = [
    ["文字", API.NOVEL],
    ["图片", API.MANGA],
    ["音频", API.AUDIO],
    ["视频", API.VIDEO],
  ];

  @override
  Widget build(BuildContext context) {
    final profile = ESOTheme();
    if (Global.needShowAbout) {
      Global.needShowAbout = false;
      if (profile.version != profile.lastestVersion) {
        Future.delayed(
            Duration(milliseconds: 10), () => AboutPage2.showAbout(context, true));
      }
      AutoBackupPage.backup(true);
      AutoBackupPage.shareRule(true);
    }
    return DefaultTabController(
      length: tabs.length,
      child: Container(
        decoration: globalDecoration,
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
                            fontFamily: ESOTheme.staticFontFamily),
                      )))
                  .toList(),
            ),
            actions: <Widget>[
              // IconButton(
              //     icon: Icon(Icons.add_to_photos_outlined),
              //     tooltip: "导入本地txt或epub",
              //     onPressed: () => Utils.startPageWait(context, AddLocalItemPage())),
              if (profile.searchPostion == ESOTheme.searchAction)
                IconButton(
                    icon: Icon(Icons.search),
                    tooltip: "搜索",
                    onPressed: () => Utils.startPageWait(context, SearchPage())),
              Menu<MenuFavorite>(
                  // color: Theme.of(context).iconTheme.color,
                  tooltip: "选项",
                  items: favoriteMenus,
                  onSelect: (value) {
                    switch (value) {
                      case MenuFavorite.addItem:
                        Utils.startPageWait(context, AddLocalItemPage());
                        break;
                      case MenuFavorite.history:
                        Utils.startPageWait(context, HistoryPage());
                        break;
                      case MenuFavorite.more_settings:
                        Utils.startPageWait(context, AboutPage());
                        break;
                      default:
                    }
                  }),
              // if (profile.showHistoryOnFavorite)
              //   IconButton(
              //     icon: Icon(Icons.history),
              //     tooltip: "浏览历史",
              //     onPressed: () => invokeTap(HistoryPage()),
              //   ),
              // if (profile.bottomCount != 4)
              //   IconButton(
              //     icon: Icon(FIcons.settings),
              //     tooltip: "设置",
              //     onPressed: () => invokeTap(AboutPage()),
              //   ),
            ],
          ),
          body: TabBarView(
            children: tabs
                .map((tab) => FavoriteListPage(type: tab[1], invokeTap: invokeTap))
                .toList(),
          ),
        ),
      ),
    );
  }
}
