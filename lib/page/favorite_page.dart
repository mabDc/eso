import 'package:eso/api/api.dart';
import 'package:eso/page/setting/about_page.dart';
import 'package:flutter/material.dart';
import 'package:eso/ui/round_indicator.dart';
import 'package:eso/page/favorite_list_page.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ["文字", API.NOVEL],
      ["图片", API.MANGA],
      ["音频", API.AUDIO],
      ["视频", API.VIDEO],
    ];
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )))
                .toList(),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).textTheme.bodyText1.color,
              ),
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) => AboutPage())),
            ),
          ],
        ),
        body: TabBarView(
          children: tabs
              .map((tab) => FavoriteListPage(
                    type: tab[1],
                  ))
              .toList(),
        ),
      ),
    );
  }
}
