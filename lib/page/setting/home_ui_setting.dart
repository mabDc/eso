import 'package:eso/profile.dart';
import 'package:flutter/material.dart';

import '../../fonticons_icons.dart';

class HomeUISetting extends StatelessWidget {
  const HomeUISetting({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = Profile();
    return Scaffold(
      appBar: AppBar(
        title: Text('界面与布局'),
      ),
      body: ListView(
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    '正文信息显示',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                Divider(),
                SwitchListTile(
                  title: Text('文字-顶部'),
                  subtitle: Text('文字正文 (状态栏)'),
                  value: profile.showMangaInfo,
                  onChanged: (value) => profile.showMangaInfo = value,
                  activeColor: Theme.of(context).primaryColor,
                ),
                SwitchListTile(
                  title: Text('文字-底部'),
                  subtitle: Text('文字正文 (信息栏)'),
                  value: profile.mangaFullScreen,
                  onChanged: (value) => profile.mangaFullScreen = value,
                  activeColor: Theme.of(context).primaryColor,
                ),
                SwitchListTile(
                  title: Text('图片-顶部'),
                  subtitle: Text('图片正文 (状态栏)'),
                  value: profile.showMangaInfo,
                  onChanged: (value) => profile.showMangaInfo = value,
                  activeColor: Theme.of(context).primaryColor,
                ),
                SwitchListTile(
                  title: Text('图片-底部'),
                  subtitle: Text('图片正文(信息栏)'),
                  value: profile.mangaFullScreen,
                  onChanged: (value) => profile.mangaFullScreen = value,
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    '布局选择',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                Divider(),
                RadioListTile<int>(
                  title: Text('TV模式(并没有)'),
                  value: 1,
                  groupValue: 1,
                  onChanged: null,
                ),
                Divider(),
                AspectRatio(
                  aspectRatio: 0.8,
                  child: Card(
                    elevation: 20,
                    margin: EdgeInsets.all(6),
                    shadowColor: Colors.grey,
                    child: Scaffold(
                      appBar: AppBar(
                        centerTitle: false,
                        elevation: 0,
                        leading: Text(''),
                        actions: [
                          IconButton(icon: Icon(Icons.history), onPressed: null),
                          IconButton(icon: Icon(Icons.settings), onPressed: null),
                        ],
                      ),
                      bottomNavigationBar: BottomAppBar(
                        color: Theme.of(context).canvasColor,
                        shape: CircularNotchedRectangle(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  FIcons.heart,
                                  color: Theme.of(context).primaryColor,
                                ),
                                Text(
                                  "收藏",
                                  style: TextStyle(color: Theme.of(context).primaryColor),
                                )
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[Icon(FIcons.compass), Text("发现")],
                            ),
                          ],
                        ),
                      ),
                      floatingActionButton: FloatingActionButton(
                        elevation: 1,
                        tooltip: "搜索",
                        backgroundColor: Theme.of(context).primaryColor,
                        onPressed: () {},
                        child: Icon(FIcons.search, color: Theme.of(context).canvasColor),
                      ),
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.centerDocked,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
