import 'dart:io';
import 'package:eso/page/setting/font_family_page.dart';
import 'package:eso/page/setting/home_ui_setting.dart';
import 'package:eso/page/source/edit_source_page.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global.dart';
import '../../profile.dart';
import 'auto_backup_page.dart';
import 'darkmod_page.dart';
import 'color_lens_page.dart';
import 'package:about/about.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key key}) : super(key: key);

  joinGroup([String group]) {
    final key =
        "7588a53508787a254b910d39476959823e3f36a7c894a6fc72504ac92e782ec2"; //1群key
    if (Global.isDesktop) {
      final s = "https://shang.qq.com/wpa/qunwpa?idkey=$key&source_id=1_40001";
      launch(s);
    } else {
      //Flutter 跳转(打开)QQ聊天对话和QQ群聊
      //https://www.jianshu.com/p/8dc54ef6329c
      final s =
          'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=${group ?? 1106156709}&card_type=group&source=qrcode';
      launch(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Global.appName)),
      body: Consumer<Profile>(
        builder: (BuildContext context, Profile profile, Widget widget) {
          return ListView(
            padding: const EdgeInsets.all(8.0),
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
                    ListTile(
                      title: Text('规则管理'),
                      subtitle: Text('添加、删除、修改您的数据源'),
                      onTap: () => Utils.startPageWait(context, EditSourcePage()),
                    ),
                    ListTile(
                      title: Text('自动备份与webdav'),
                      subtitle: Text('开启每日备份 开启webdav自动同步'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => AutoBackupPage())),
                    ),
                    ListTile(
                      title: Text('清理缓存'),
                      subtitle: Text('清理本地缓存的书籍等'),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            backgroundColor: Theme.of(context).canvasColor,
                            title: Text("清理缓存"),
                            content: Text("此操作将会清除小说缓存，请确定是否继续！"),
                            actions: <Widget>[
                              FlatButton(
                                  child: Text('取消',
                                      style:
                                          TextStyle(color: Theme.of(context).hintColor)),
                                  onPressed: () => Navigator.pop(context)),
                              FlatButton(
                                  child: Text('立即清理'),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await CacheUtil().clear(allCache: true);
                                    Utils.toast("缓存清理成功");
                                  }),
                            ],
                          ),
                        );
                      },
                    ),
                    SwitchListTile(
                      title: Text('交换收藏点击和长按效果'),
                      subtitle: Text(
                          profile.switchLongPress ? '点击进入目录，长按查看内容' : '点击查看内容，长按进入目录'),
                      value: profile.switchLongPress,
                      onChanged: (value) => profile.switchLongPress = value,
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        '主题',
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
                      subtitle: Text('修改主题色'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => ColorLensPage())),
                    ),
                    ListTile(
                      title: Text('字体管理'),
                      subtitle: Text('全局界面、正文字体设置'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => FontFamilyPage())),
                    ),
                    ListTile(
                      title: Text('界面与布局'),
                      subtitle: Text('全屏和按钮位置调整'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => HomeUISetting())),
                    ),
                    
                  ],
                ),
              ),
              SizedBox(height: 4),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        '联系&帮助',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('亦搜①群'),
                      subtitle: Text('1106156709'),
                      onTap: () => joinGroup(),
                    ),
                    ListTile(
                      title: Text('亦搜②群'),
                      subtitle: Text('1148443231'),
                      onTap: () => joinGroup('1148443231'),
                    ),
                    ListTile(
                      title: Text('规则获取'),
                      subtitle: Text('https://github.com/mabDc/eso_source/'),
                      onTap: () => launch('https://github.com/mabDc/eso_source/'),
                    ),
                    ListTile(
                      title: Text('规则说明'),
                      subtitle: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'https://github.com/mabDc/eso_source/blob/master/README.md'),
                      ),
                      onTap: () => launch(
                          'https://github.com/mabDc/eso_source/blob/master/README.md'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        '主要开发者',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('mabdc'),
                      subtitle: Text('https://github.com/mabDc'),
                      onTap: () => launch('https://github.com/mabDc'),
                    ),
                    ListTile(
                      title: Text('DaguDuiyuan'),
                      subtitle: Text('https://github.com/DaguDuiyuan'),
                      onTap: () => launch('https://github.com/DaguDuiyuan'),
                    ),
                    ListTile(
                      title: Text('yangyxd'),
                      subtitle: Text('https://github.com/yangyxd'),
                      onTap: () => launch('https://github.com/yangyxd'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        '项目',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Divider(),
                    MarkdownPageListTile(
                      filename: 'README.md',
                      title: Text('使用指北'),
                      // icon: Icon(Icons.info_outline),
                    ),
                    MarkdownPageListTile(
                      filename: 'CHANGELOG.md',
                      title: Text('更新日志'),
                      // icon: Icon(FIcons.list),
                    ),
                    MarkdownPageListTile(
                      filename: 'LICENSE',
                      title: Text('源代码许可'),
                      // icon: Icon(Icons.description),
                    ),
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
                      title: Text('${Global.appName} - ${Global.appVersion}'),
                      subtitle: Text('https://github.com/mabDc/eso/releases'),
                      onTap: () => launch('https://github.com/mabDc/eso/releases'),
                    ),
                  ],
                ),
              ),
              Card(
                child: Material(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                  child: InkWell(
                    onTap: () => showAbout(context),
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
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                            Text(
                              '亦搜，亦看，亦闻',
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static void showAbout(BuildContext context, [bool showClose = false]) =>
      showAboutDialog(
        applicationLegalese:
            '版本 ${Global.appVersion}\n版号 ${Global.appBuildNumber}\n包名 ${Global.appPackageName}',
        applicationIcon: Image.asset(
          Global.logoPath,
          width: 50,
          height: 50,
        ),
        context: context,
        applicationVersion: '亦搜，亦看，亦闻',
        children: <Widget>[
          MarkdownPageListTile(
            filename: 'README.md',
            title: Text('使用指北'),
            icon: Icon(Icons.info_outline),
          ),
          MarkdownPageListTile(
            filename: 'CHANGELOG.md',
            title: Text('更新日志'),
            icon: Icon(Icons.history),
          ),
          MarkdownPageListTile(
            filename: 'LICENSE',
            title: Text('源代码许可'),
            icon: Icon(Icons.description),
          ),
          if (Platform.isWindows)
            ListTile(
              title: Text("SQLite 链接库"),
              // subtitle: Text(SQFLiteWinUtil.dllPath()),
              leading: Icon(Icons.link),
            ),
          if (Platform.isLinux)
            ListTile(
              title: Text("libsqlite3-dev"),
              // subtitle: Text(SQFLiteWinUtil.dllPath()),
              leading: Icon(Icons.link),
            ),
          if (showClose)
            InkWell(
              child: ListTile(
                leading: Icon(Icons.close),
                title: Text("不再显示"),
              ),
              onTap: () {
                Provider.of<Profile>(context, listen: false).updateVersion();
                Utils.toast("在设置中可再次查看");
                Navigator.of(context).pop();
              },
            ),
        ],
      );
}
