import 'package:eso/eso_theme.dart';
import 'package:eso/main.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../fonticons_icons.dart';

class UISetting extends StatelessWidget {
  const UISetting({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = ESOTheme();
    return Container(
      decoration: globalDecoration,
      child: Container(
        decoration: globalDecoration,
        child: Scaffold(
          appBar: AppBar(
            title: Text('界面与布局'),
          ),
          body: ValueListenableBuilder<Box<dynamic>>(
              valueListenable: globalConfigBox.listenable(),
              builder: (BuildContext context, Box<dynamic> _, Widget child) {
                return ListView(
                  children: [
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
                            subtitle: Text(profile.switchLongPress
                                ? '点击进入目录，长按查看内容'
                                : '点击查看内容，长按进入目录'),
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
                            title: Text('横屏模式 平板 TV'),
                            subtitle: Text('请开启自动旋转 宽度大于600时自动启用'),
                            value: MediaQuery.of(context).size.width > 600,
                            onChanged: (value) {
                              Utils.toast("不需要手动设置");
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
                            title: Text('收藏-发现'),
                            value: 2,
                            groupValue: profile.bottomCount,
                            onChanged: (int value) => profile.bottomCount = value,
                          ),
                          RadioListTile<int>(
                            title: Text('收藏-发现-历史-关于'),
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
                            value: ESOTheme.searchDocker,
                            groupValue: profile.searchPostion,
                            onChanged: (int value) => profile.searchPostion = value,
                          ),
                          RadioListTile<int>(
                            title: Text('浮动'),
                            value: ESOTheme.searchFloat,
                            groupValue: profile.searchPostion,
                            onChanged: (int value) => profile.searchPostion = value,
                          ),
                          RadioListTile<int>(
                            title: Text('顶部'),
                            value: ESOTheme.searchAction,
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
                              child: Container(
                                decoration: globalDecoration,
                                child: Scaffold(
                                  appBar: AppBar(
                                    centerTitle: false,
                                    elevation: 0,
                                    leading: Text(''),
                                    actions: [
                                      if (profile.searchPostion == ESOTheme.searchAction)
                                        IconButton(
                                            icon: Icon(Icons.search), onPressed: null),
                                      if (profile.showHistoryOnFavorite)
                                        IconButton(
                                            icon: Icon(Icons.history), onPressed: null),
                                      if (profile.bottomCount != 4)
                                        IconButton(
                                            icon: Icon(Icons.settings), onPressed: null),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
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
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Icon(FIcons.compass),
                                                  Text("发现")
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (profile.searchPostion ==
                                                ESOTheme.searchDocker &&
                                            profile.bottomCount == 4)
                                          Spacer(),
                                        if (profile.bottomCount == 4)
                                          Expanded(
                                            flex: 3,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
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
                                  floatingActionButton: profile.searchPostion ==
                                          ESOTheme.searchAction
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
                                      profile.searchPostion == ESOTheme.searchAction
                                          ? null
                                          : profile.searchPostion == ESOTheme.searchFloat
                                              ? FloatingActionButtonLocation.endFloat
                                              : FloatingActionButtonLocation.centerDocked,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
