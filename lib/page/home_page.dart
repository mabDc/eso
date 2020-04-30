import 'package:eso/page/source/edit_source_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../model/page_switch.dart';
import '../model/profile.dart';
import 'setting/about_page.dart';
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
          return CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.library_books), title: Text('收藏')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.satellite), title: Text('发现')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.edit), title: Text('图源')),
                BottomNavigationBarItem(
                    icon: Icon(Icons.info_outline), title: Text('关于')),
              ],
              activeColor: Color(Global.colors[Profile().colorName]),
              currentIndex: pageSwitch.currentIndex,
              //onTap: (index) => pageSwitch.changePage(index),
            ),
            tabBuilder: (BuildContext context, int index) {
              return [
                FavoritePage(),
                DiscoverPage(),
                EditSourcePage(),
                AboutPage(),
              ][index];
            },
          );
        },
      ),
    );
  }
}
