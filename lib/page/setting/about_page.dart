import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eso/page/source/edit_source_page.dart';

import '../../global.dart';
import '../../model/profile.dart';
import 'darkmod_page.dart';
import 'color_lens_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('APP'),
        actions: <Widget>[],
      ),
      body: Consumer<Profile>(
        builder: (BuildContext context, Profile profile, Widget widget) {
          return ListView(
            children: <Widget>[
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        '管理',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('站点管理'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => EditSourcePage())),
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        '设置',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('夜间模式'),
                      subtitle: Text('切换夜间模式'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => DarkModpage())),
                    ),
                    ListTile(
                      title: Text('调色板'),
                      subtitle: Text('修改主题颜色'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ColorLensPage())),
                    ),
                    SwitchListTile(
                      title: Text('交换收藏点击和长按效果'),
                      subtitle: Text(
                          profile.switchLongPress ? '点击进入目录，长按查看内容' : '点击查看内容，长按进入目录'),
                      value: profile.switchLongPress,
                      onChanged: (value) => profile.switchLongPress = value,
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    // SwitchListTile(
                    //   title: Text('看漫画时显示系统信息'),
                    //   subtitle: Text('也可在漫画中长按切换'),
                    //   value: profile.showMangaInfo,
                    //   onChanged: (value) => profile.showMangaInfo = value,
                    //   activeColor: Theme.of(context).primaryColor,
                    // ),
                    // SwitchListTile(
                    //   title: Text('自动刷新'),
                    //   subtitle: Text('软件启动时自动更新收藏'),
                    //   value: profile.autoRefresh,
                    //   onChanged: (value) => profile.autoRefresh = value,
                    //   activeColor: Theme.of(context).primaryColor,
                    // ),
                    // ListTile(
                    //   title: Text('备份收藏'),
                    //   subtitle: Text('备份至 Android/data/com.mabdc.eso/files/backup.txt'),
                    //   onTap: () => SearchItemManager.backupItems(),
                    // ),
                    // ListTile(
                    //   title: Text('恢复收藏'),
                    //   subtitle: Text('恢复从 Android/data/com.mabdc.eso/files/backup.txt'),
                    //   onTap: () => SearchItemManager.restore(),
                    // ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        '关于',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('开源地址'),
                      subtitle: Text('https://github.com/mabDc/eso'),
                      onTap: () => launch('https://github.com/mabDc/eso'),
                    ),
                    ListTile(
                      title: Text('问题反馈'),
                      subtitle: Text('https://github.com/mabDc/eso/issues'),
                      onTap: () => launch('https://github.com/mabDc/eso/issues'),
                    ),
                    ListTile(
                      title: Text('版本 v${Global.appVersion}'),
                      subtitle: Text('https://github.com/mabDc/eso/releases'),
                      onTap: () => launch('https://github.com/mabDc/eso/releases'),
                    ),
                    Material(
                      color: Theme.of(context).primaryColor,
                      child: InkWell(
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationVersion: Global.appVersion,
                        ),
                        child: SizedBox(
                          height: 260,
                          width: double.infinity,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'ESO',
                                  style: TextStyle(
                                    fontSize: 100,
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .headline6
                                        .color,
                                  ),
                                ),
                                Text(
                                  '亦搜，亦看，亦闻',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .headline6
                                        .color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
