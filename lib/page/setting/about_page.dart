import 'package:eso/database/search_item_manager.dart';
import 'package:eso/evnts/restore_event.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/page/source/edit_source_page.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global.dart';
import '../../model/profile.dart';
import 'darkmod_page.dart';
import 'color_lens_page.dart';
import 'package:about/about.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BuildContext _context = context;
    return Scaffold(
      appBar: AppBarEx(title: Text(Global.appName)),
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
              SizedBox(height: 4),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        '备份和缓存',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('备份'),
                      subtitle: Text('备份收藏夹、规则数据到本地存储'),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            backgroundColor: Theme.of(context).canvasColor,
                            title: Text("备份"),
                            content: Text("如果以前有过备份，此操作将会覆盖掉以前的备份数据，请确定是否继续！"),
                            actions: <Widget>[
                              FlatButton(
                                  child: Text('取消', style: TextStyle(color: Theme.of(context).hintColor)),
                                  onPressed: () => Navigator.pop(context)),
                              FlatButton(child: Text('开始备份'), onPressed: () async {
                                Navigator.pop(context);
                                final cache = CacheUtil(backup: true);
                                final _dir = await cache.cacheDir();
                                print(_dir);
                                try {
                                  final _favorite = await SearchItemManager
                                      .backupItems();
                                  cache.put('favorite.json', _favorite, false);
                                  print("备份收藏夹成功");
                                } catch (e) {
                                  print("备份收藏夹： $e");
                                }
                                try {
                                  final _rules = await EditSourceProvider.backupRules();
                                  cache.putData('rules.json', _rules, false);
                                  print("备份规则列表成功");
                                } catch (e) {
                                  print("备份规则列表： $e");
                                }
                                Utils.toast("备份成功($_dir)");
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                    ListTile(
                      title: Text('恢复'),
                      subtitle: Text('从备份数据中恢复收藏夹、规则列表'),
                      onTap: () async {
                        bool _clean = false;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            backgroundColor: Theme.of(context).canvasColor,
                            title: Text("恢复"),
                            content: Row(
                              children: [
                                Expanded(
                                  child: Text("恢复前清空当前数据"),
                                ),
                                StatefulBuilder(builder: (context, _state) {
                                  return Switch(value: _clean, onChanged: (v) {
                                    _clean = v;
                                    _state(() => null);
                                  });
                                })
                              ],
                            ),
                            actions: <Widget>[
                              FlatButton(
                                  child: Text('取消', style: TextStyle(color: Theme.of(context).hintColor)),
                                  onPressed: () => Navigator.pop(context)),
                              FlatButton(child: Text('恢复数据'), onPressed: () async {
                                Navigator.pop(context);
                                final cache = CacheUtil(backup: true);
                                await cache.requestPermission();
                                final _dir = await cache.cacheDir();
                                if (!CacheUtil.existPath(_dir)) {
                                  Utils.toast("恢复失败: 找不到备份数据。请将备份数据存放到（$_dir）中");
                                  return;
                                }
                                try {
                                  String _favorite = await cache.get(
                                      'favorite.json', null, false);
                                  if (!Utils.empty(_favorite)) {
                                    await SearchItemManager.restore(_favorite);
                                    print("恢复收藏夹成功");
                                  }
                                } catch (e) {}
                                try {
                                  final _rules = await cache.getData('rules.json', null, false);
                                  if (_rules != null && _rules is List) {
                                    await EditSourceProvider.restore(_rules, _clean);
                                  }
                                  print("恢复规则列表成功");
                                } catch (e) {}
                                // 发送一个通知
                                eventBus.fire(RestoreEvent());
                                Utils.toast("恢复成功");
                              }),
                            ],
                          ),
                        );
                      },
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
                                  child: Text('取消', style: TextStyle(color: Theme.of(context).hintColor)),
                                  onPressed: () => Navigator.pop(context)),
                              FlatButton(child: Text('立即清理'), onPressed: () async {
                                Navigator.pop(context);
                                await CacheUtil().clear(allCache: true);
                                Utils.toast("缓存清理成功");
                              }),
                            ],
                          ),
                        );
                      },
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
                      //Flutter 跳转(打开)QQ聊天对话和QQ群聊
                      //https://www.jianshu.com/p/8dc54ef6329c
                      onTap: () => launch(
                          'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=${1106156709}&card_type=group&source=qrcode'),
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
                      filename: 'lib/assets/md/README.md',
                      title: Text('使用指北'),
                      // icon: Icon(Icons.info_outline),
                    ),
                    MarkdownPageListTile(
                      filename: 'lib/assets/md/CHANGELOG.md',
                      title: Text('更新日志'),
                      // icon: Icon(FIcons.list),
                    ),
                    // MarkdownPageListTile(
                    //   filename: 'lib/assets/md/LICENSE.md',
                    //   title: Text('源代码许可'),
                    //   icon: Icon(Icons.description),
                    // ),
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
                  ],
                ),
              ),
              Card(
                child: Material(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                  child: InkWell(
                    onTap: () => showAboutDialog(
                        context: context,
                        applicationVersion: Global.appVersion,
                        children: <Widget>[
                          MarkdownPageListTile(
                            filename: 'lib/assets/md/README.md',
                            title: Text('使用指北'),
                            icon: Icon(Icons.info_outline),
                          ),
                          MarkdownPageListTile(
                            filename: 'lib/assets/md/CHANGELOG.md',
                            title: Text('更新日志'),
                            icon: Icon(Icons.history),
                          ),
                        ]),
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
}
