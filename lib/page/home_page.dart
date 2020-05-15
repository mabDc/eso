import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../model/page_switch.dart';
import '../model/profile.dart';
import 'discover_page.dart';
import 'favorite_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: PageSwitch(Global.currentHomePage),
      child: Consumer<PageSwitch>(
        builder: (BuildContext context, PageSwitch pageSwitch, Widget widget) {
          Global.currentHomePage = pageSwitch.currentIndex;
          return Scaffold(
            body: PageView(
              controller: pageSwitch.pageController,
              children: <Widget>[
                FavoritePage(),
                DiscoverPage(),
              ],
              onPageChanged: (index) => pageSwitch.changePage(index, false),
              physics: new NeverScrollableScrollPhysics(), //禁止主页左右滑动
            ),
            bottomNavigationBar: Consumer<Profile>(
              builder: (BuildContext context, Profile profile, Widget widget) {
                //bool isDark = Theme.of(context).brightness == Brightness.dark;
                return BottomAppBar(
                  color: Theme.of(context).canvasColor,
                  shape: CircularNotchedRectangle(),
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                            onTap: () => pageSwitch.changePage(0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.library_books,
                                  color: getColor(pageSwitch, context, 0),
                                ),
                                Text(
                                  "收藏",
                                  style: TextStyle(
                                      color: getColor(pageSwitch, context, 0)),
                                )
                              ],
                            )),
                        GestureDetector(
                            onTap: () => pageSwitch.changePage(1),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.satellite,
                                    color: getColor(pageSwitch, context, 1)),
                                Text("发现",
                                    style: TextStyle(
                                        color:
                                            getColor(pageSwitch, context, 1)))
                              ],
                            )),
                      ],
                    ),
                  ),

                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {},
              child: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
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