import 'package:url_launcher/url_launcher.dart';

import '../global.dart';
import '../model/profile.dart';
import 'color_lens_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        '设置',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Divider(),
                    SwitchListTile(
                      title: Text('自动刷新'),
                      subtitle: Text('软件启动时自动更新收藏'),
                      value: profile.autoRefresh,
                      onChanged: (value) => profile.autoRefresh = value,
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    SwitchListTile(
                      title: Text('夜间模式'),
                      subtitle: Text('暗色背景'),
                      value: profile.darkMode,
                      onChanged: (value) => profile.darkMode = value,
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    ListTile(
                      title: Text('调色板'),
                      subtitle: Text('修改主题色'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ColorLensPage())),
                    ),
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
                      onTap: () =>
                          launch('https://github.com/mabDc/eso/issues'),
                    ),
                    ListTile(
                      title: Text('版本 v${Global.appVersion}'),
                      subtitle: Text('https://github.com/mabDc/eso/releases'),
                      onTap: () =>
                          launch('https://github.com/mabDc/eso/releases'),
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
                                        .title
                                        .color,
                                  ),
                                ),
                                Text(
                                  '亦搜，亦看，亦闻',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .title
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
