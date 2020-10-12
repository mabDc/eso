import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:eso/database/rule.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/evnts/restore_event.dart';
import 'package:eso/model/history_manager.dart';
import 'package:eso/page/setting/font_family_page.dart';
import 'package:eso/page/source/edit_source_page.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_chooser/file_chooser.dart';
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
                      title: Text('夜间模式'),
                      subtitle: Text('切换夜间模式'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => DarkModpage())),
                    ),
                    ListTile(
                      title: Text('字体管理'),
                      subtitle: Text('全局界面、正文字体设置'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) => FontFamilyPage())),
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
                                  child: Text('取消',
                                      style:
                                          TextStyle(color: Theme.of(context).hintColor)),
                                  onPressed: () => Navigator.pop(context)),
                              FlatButton(
                                  child: Text('开始备份'),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    final cache = CacheUtil(backup: true);
                                    final _dir = await cache.cacheDir();
                                    print(_dir);
                                    try {
                                      final _favorite =
                                          await SearchItemManager.backupItems();
                                      cache.put('favorite.json', _favorite, false);
                                      print("备份收藏夹成功");
                                    } catch (e) {
                                      print("备份收藏夹： $e");
                                    }
                                    try {
                                      final _rules = await Rule.backupRules();
                                      cache.putData('rules.json', _rules,
                                          hashCodeKey: false);
                                      print("备份规则列表成功");
                                    } catch (e) {
                                      print("备份规则列表： $e");
                                    }
                                    try {
                                      final searchHistory =
                                          HistoryManager().searchHistory;
                                      cache.putData('searchHistory.json', searchHistory,
                                          hashCodeKey: false);
                                      print("备份搜索记录成功");
                                    } catch (e) {
                                      print("备份搜索记录： $e");
                                    }
                                    try {
                                      final profile = Profile().toJson();
                                      cache.putData('profile.json', profile,
                                          hashCodeKey: false);
                                      print("备份配置成功");
                                    } catch (e) {
                                      print("备份配置： $e");
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
                        String _ruleFile;
                        Uint8List _ruleBytes;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            backgroundColor: Theme.of(context).canvasColor,
                            title: Text("恢复"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text("恢复前清空当前数据"),
                                    ),
                                    StatefulBuilder(builder: (context, _state) {
                                      return Switch(
                                          value: _clean,
                                          onChanged: (v) {
                                            _clean = v;
                                            _state(() => null);
                                          });
                                    })
                                  ],
                                ),
                                StatefulBuilder(builder: (context, _state) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text('点击选择规则文件'),
                                    subtitle: Text(_ruleFile ?? '使用默认文件'),
                                    onTap: () async {
                                      if (Global.isDesktop) {
                                        final f = await showOpenPanel(
                                          confirmButtonText: '选择规则',
                                          allowedFileTypes: <FileTypeFilterGroup>[
                                            FileTypeFilterGroup(
                                              label: '规则文件',
                                              fileExtensions: <String>['json', 'txt'],
                                            ),
                                            FileTypeFilterGroup(
                                              label: '其他',
                                              fileExtensions: <String>[],
                                            ),
                                          ],
                                        );
                                        if (f.canceled) {
                                          Utils.toast('未选取规则文件');
                                          return;
                                        }
                                        _ruleFile = f.paths.first;
                                        _ruleBytes = File(_ruleFile).readAsBytesSync();
                                        _state(() => null);
                                      } else {
                                        FilePickerResult jsonPick =
                                            await FilePicker.platform.pickFiles(
                                                type: FileType.custom, withData: true);
                                        if (jsonPick == null) {
                                          Utils.toast('未选取规则文件');
                                          return;
                                        }
                                        final json = jsonPick.files.single;
                                        if (json.extension != 'json' &&
                                            json.extension != 'txt' &&
                                            json.extension != 'bin' &&
                                            json.extension != 'mainfest') {
                                          Utils.toast('只支持扩展名为json或txt或mainfest的规则文件');
                                          return;
                                        }
                                        _ruleFile = json.path;
                                        _ruleBytes = json.bytes;
                                        _state(() => null);
                                      }
                                    },
                                  );
                                }),
                              ],
                            ),
                            actions: <Widget>[
                              FlatButton(
                                  child: Text('取消',
                                      style:
                                          TextStyle(color: Theme.of(context).hintColor)),
                                  onPressed: () => Navigator.pop(context)),
                              FlatButton(
                                child: Text('恢复数据'),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final cache = CacheUtil(backup: true);
                                  await cache.requestPermission();
                                  final _dir = await cache.cacheDir();
                                  if (_ruleFile == null && !CacheUtil.existPath(_dir)) {
                                    Utils.toast("恢复失败: 找不到备份数据。请将备份数据存放到（$_dir）中");
                                    return;
                                  }
                                  try {
                                    String _favorite =
                                        await cache.get('favorite.json', null, false);
                                    if (!Utils.empty(_favorite)) {
                                      await SearchItemManager.restore(_favorite);
                                      print("恢复收藏夹成功");
                                    }
                                  } catch (e) {
                                    print("恢复收藏夹 $e");
                                  }
                                  try {
                                    if (_ruleBytes == null || _ruleBytes.isEmpty) {
                                      final _rules = await cache.getData('rules.json',
                                          defaultValue: null, hashCodeKey: false);
                                      if (_rules != null && _rules is List) {
                                        await Rule.restore(_rules, _clean);
                                      }
                                      print("恢复规则列表成功");
                                    } else {
                                      final _rules = jsonDecode(utf8.decode(_ruleBytes));
                                      if (_rules != null && _rules is List) {
                                        await Rule.restore(_rules, _clean);
                                      }
                                    }
                                  } catch (e) {}
                                  try {
                                    final profile = await cache.getData('profile.json',
                                        defaultValue: null, hashCodeKey: false);
                                    if (profile != null && profile is Map) {
                                      Profile.restore(profile);
                                    }
                                    print("恢复配置成功");
                                  } catch (e) {
                                    print("恢复配置 $e");
                                  }
                                  try {
                                    final searchHistory = await cache.getData(
                                        'searchHistory.json',
                                        defaultValue: null,
                                        hashCodeKey: false);
                                    if (searchHistory != null && searchHistory is List) {
                                      await HistoryManager()
                                          .restore(searchHistory, _clean);
                                    }
                                    print("恢复搜索记录列表成功");
                                  } catch (e) {
                                    print("恢复搜索记录列表 $e");
                                  }
                                  // 发送一个通知
                                  eventBus.fire(RestoreEvent());
                                  Utils.toast("恢复成功");
                                },
                              ),
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
