import 'package:eso/profile.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';

import '../../fonticons_icons.dart';

class UISetting extends StatelessWidget {
  const UISetting({Key key}) : super(key: key);

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
                    '正文信息显示设置',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                Divider(),
                SwitchListTile(
                  title: Text('文字-顶部'),
                  subtitle: Text('(状态栏) (启用为显示，禁用为隐藏)'),
                  value: profile.showNovelStatus,
                  onChanged: (value) => profile.showNovelStatus = value,
                ),
                SwitchListTile(
                  title: Text('文字-底部'),
                  subtitle: Text('(信息栏)'),
                  value: profile.showNovelInfo,
                  onChanged: (value) => profile.showNovelInfo = value,
                  activeColor: Theme.of(context).primaryColor,
                ),
                SwitchListTile(
                  title: Text('图片-顶部'),
                  subtitle: Text('(状态栏)'),
                  value: profile.showMangaStatus,
                  onChanged: (value) => profile.showMangaStatus = value,
                ),
                SwitchListTile(
                  title: Text('图片-底部'),
                  subtitle: Text('(信息栏)'),
                  value: profile.showMangaInfo,
                  onChanged: (value) => profile.showMangaInfo = value,
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    '入口和功能',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                Divider(),
                SwitchListTile(
                  title: Text('交换收藏点击和长按效果'),
                  subtitle:
                      Text(profile.switchLongPress ? '点击进入目录，长按查看内容' : '点击查看内容，长按进入目录'),
                  value: profile.switchLongPress,
                  onChanged: (value) => profile.switchLongPress = value,
                ),
                SwitchListTile(
                  title: Text('历史按钮'),
                  subtitle: Text('在关于页中显示历史浏览入口'),
                  value: profile.showHistoryOnAbout,
                  onChanged: (value) => profile.showHistoryOnAbout = value,
                ),
                SwitchListTile(
                  title: Text('TV模式'),
                  subtitle: Text('(并没有)'),
                  value: false,
                  onChanged: (value) {
                    Utils.toast("...");
                  },
                ),
              ],
            ),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    '主界面布局按钮设置',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text('底部按钮'),
                ),
                Divider(),
                RadioListTile<int>(
                  title: Text('搜藏-发现'),
                  value: 2,
                  groupValue: profile.bottomCount,
                  onChanged: (int value) => profile.bottomCount = value,
                ),
                RadioListTile<int>(
                  title: Text('搜藏-发现-历史-关于'),
                  value: 4,
                  groupValue: profile.bottomCount,
                  onChanged: (int value) => profile.bottomCount = value,
                ),
                Divider(),
                ListTile(
                  title: Text('搜索按钮位置'),
                ),
                Divider(),
                RadioListTile<int>(
                  title: Text('凹陷'),
                  value: Profile.searchDocker,
                  groupValue: profile.searchPostion,
                  onChanged: (int value) => profile.searchPostion = value,
                ),
                RadioListTile<int>(
                  title: Text('浮动'),
                  value: Profile.searchFloat,
                  groupValue: profile.searchPostion,
                  onChanged: (int value) => profile.searchPostion = value,
                ),
                RadioListTile<int>(
                  title: Text('顶部'),
                  value: Profile.searchAction,
                  groupValue: profile.searchPostion,
                  onChanged: (int value) => profile.searchPostion = value,
                ),
                Divider(),
                SwitchListTile(
                  title: Text('顶部历史按钮'),
                  value: profile.showHistoryOnFavorite,
                  onChanged: (value) => profile.showHistoryOnFavorite = value,
                ),
                AspectRatio(
                  aspectRatio: 0.8,
                  child: Card(
                    elevation: 20,
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    shadowColor: Colors.grey,
                    child: Scaffold(
                      appBar: AppBar(
                        centerTitle: false,
                        elevation: 0,
                        leading: Text(''),
                        actions: [
                          if (profile.searchPostion == Profile.searchAction)
                            IconButton(icon: Icon(Icons.search), onPressed: null),
                          if (profile.showHistoryOnFavorite)
                            IconButton(icon: Icon(Icons.history), onPressed: null),
                            if (profile.bottomCount != 4)
                          IconButton(icon: Icon(Icons.settings), onPressed: null),
                        ],
                      ),
                      bottomNavigationBar: BottomAppBar(
                        color: Theme.of(context).canvasColor,
                        shape: CircularNotchedRectangle(),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
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
                                        style: TextStyle(
                                            color: Theme.of(context).primaryColor),
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
                            if (profile.searchPostion == Profile.searchDocker && profile.bottomCount == 4) Spacer(),
                            if (profile.bottomCount == 4)
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.history),
                                        Text("历史")
                                      ],
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.info_outline_rounded),
                                        Text("关于")
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      floatingActionButton: profile.searchPostion == Profile.searchAction
                          ? null
                          : FloatingActionButton(
                              elevation: 1,
                              tooltip: "搜索",
                              backgroundColor: Theme.of(context).primaryColor,
                              onPressed: () {},
                              child: Icon(FIcons.search,
                                  color: Theme.of(context).canvasColor),
                            ),
                      floatingActionButtonLocation:
                          profile.searchPostion == Profile.searchAction
                              ? null
                              : profile.searchPostion == Profile.searchFloat
                                  ? FloatingActionButtonLocation.endFloat
                                  : FloatingActionButtonLocation.centerDocked,
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
