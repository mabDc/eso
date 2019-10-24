import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../global.dart';
import '../model/page_switch.dart';
import '../model/profile.dart';
import '../parse_test.dart';
import 'favorite_page.dart';
import 'discover_page.dart';
import 'about_page.dart';

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
                // TestPage(),
                FavoritePage(),
                DiscoverPage(),
                AboutPage(),
              ],
              onPageChanged: (index) => pageSwitch.changePage(index, false),
            ),
            bottomNavigationBar: Consumer<Profile>(
              builder: (BuildContext context, Profile profile, Widget widget) {
                return BottomNavigationBar(
                  selectedItemColor: Theme.of(context).primaryColor,
                  unselectedItemColor: profile.darkMode
                      ? Colors.white.withOpacity(0.6)
                      : Colors.black.withOpacity(0.6),
                  backgroundColor:
                      profile.darkMode ? Colors.black12 : Colors.white,
                  items: [
                    // BottomNavigationBarItem(
                    //     icon: Icon(Icons.weekend), title: Text('测试')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.library_books), title: Text('收藏')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.satellite), title: Text('发现')),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.info_outline), title: Text('关于')),
                  ],
                  currentIndex: pageSwitch.currentIndex,
                  onTap: (index) => pageSwitch.changePage(index),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String s = '点击测试开始解析';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('测试'),
              onPressed: () {
                if(isLoading) return;
                s = '加载中...';
                isLoading = true;
                setState(() {});
                (() async {
                  String jsonString = await DefaultAssetBundle.of(context)
                      .loadString('lib/assets/chapterlist.json');
                  String htmlString = await DefaultAssetBundle.of(context)
                      .loadString('lib/assets/iqiwx.html');
                  await Future.delayed(Duration(milliseconds: 500)); //让子弹飞？
                  s = await compute(Chapter.parseJson, jsonString);
                  setState(() {});
                  await Future.delayed(Duration(milliseconds: 500));
                  s += '\n\n' + await compute(Chapter.parseHTML, htmlString);
                  isLoading = false;
                  setState(() {});
                })();
              }
            ),
            Text("$s"),
            isLoading ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
    );
  }
}