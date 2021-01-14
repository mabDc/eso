import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/history_manager.dart';
import 'package:eso/profile.dart';
import 'package:eso/ui/ui_text_field.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webdav/webdav.dart';
import 'package:intl/intl.dart' as intl;
import 'package:path/path.dart';

import '../../global.dart';

class AutoBackupPage extends StatelessWidget {
  const AutoBackupPage({Key key}) : super(key: key);

  AlertDialog showTextDialog(
    BuildContext context,
    String title,
    String s,
    void Function(String s) press,
  ) {
    TextEditingController controller = TextEditingController(text: s);
    return AlertDialog(
      contentPadding: const EdgeInsets.all(6.0),
      content: FieldRightPopupMenu(
          controller: controller,
          child: TextField(
            controller: controller,
          )),
      title: Text(title),
      actions: [
        FlatButton(
          child: Text(
            "取消",
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text(
            "确定",
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            press(controller.text);
            Navigator.of(context).pop();
            Future.delayed(Duration(seconds: 1), () => controller.dispose());
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = Profile();
    return Scaffold(
      appBar: AppBar(
        title: Text('自动备份与webdav'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('自动备份'),
          ),
          Divider(),
          RadioListTile<int>(
            title: Text('从不'),
            value: Profile.autoBackupNone,
            groupValue: profile.autoBackRate,
            onChanged: (int value) => profile.autoBackRate = value,
          ),
          RadioListTile<int>(
            title: Text('每日'),
            value: Profile.autoBackupDay,
            groupValue: profile.autoBackRate,
            onChanged: (int value) => profile.autoBackRate = value,
          ),
          Divider(),
          ListTile(
            title: Text('备份'),
            subtitle: Text(profile.autoBackupLastDay.isEmpty
                ? "上次备份：从未备份"
                : '上次备份：${profile.autoBackupLastDay}.zip'),
            onTap: backup,
          ),
          ListTile(
            title: Text('分享'),
            subtitle: Text('发送最近备份文件至其他app'),
            onTap: share,
          ),
          GestureDetector(
            child: ListTile(
              title: Text('恢复'),
              subtitle: Text('选择文件恢复'),
            ),
            onTapUp: (TapUpDetails details) =>
                restoreLocal(context, details.globalPosition),
          ),
          Divider(),
          SwitchListTile(
            title: Text('启用webdav自动同步'),
            onChanged: (value) => profile.enableWebdav = value,
            value: profile.enableWebdav,
          ),
          ListTile(
            title: Text('坚果云webdav帮助'),
            subtitle: Text("https://help.jianguoyun.com/?p=2064"),
            onTap: () => launch('https://help.jianguoyun.com/?p=2064'),
          ),
          ListTile(
            title: Text('服务器地址'),
            subtitle:
                Text(profile.webdavServer.isEmpty ? '输入您的服务器地址' : profile.webdavServer),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '服务器地址',
                profile.webdavServer,
                (s) => profile.webdavServer =
                    s.isEmpty ? "https://dav.jianguoyun.com/dav/" : s,
              ),
            ),
          ),
          ListTile(
            title: Text('账号'),
            subtitle:
                Text(profile.webdavAccount.isEmpty ? '输入您的账号' : profile.webdavAccount),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '账号',
                profile.webdavAccount,
                (s) => profile.webdavAccount = s,
              ),
            ),
          ),
          ListTile(
            title: Text('密码'),
            subtitle: Text(profile.webdavPassword.isEmpty
                ? '输入您的授权密码'
                : '*' * profile.webdavPassword.length),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '密码',
                profile.webdavPassword,
                (s) => profile.webdavPassword = s,
              ),
            ),
          ),
          GestureDetector(
            child: ListTile(
              title: Text('恢复'),
              subtitle: Text('从webdav恢复'),
            ),
            onTapUp: (TapUpDetails details) =>
                restoreFromWebDav(context, details.globalPosition),
          ),
          Divider(),
        ],
      ),
    );
  }

  share() async {
    final profile = Profile();
    if (profile.autoBackupLastDay.isEmpty) {
      Utils.toast("从未备份");
      return;
    }
    final today = intl.DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dir = join(await CacheUtil(backup: true).cacheDir(), "$today.zip");
    FlutterShare.shareFile(title: "$today.zip", filePath: dir, text: "$today.zip");
  }

  /// type: 0->s, 1->getString, 2-> getStringList
  static getArchiveFile(String key, String s, int type) {
    List<int> bytes;
    if (type == 0) {
      bytes = utf8.encode(s);
    } else if (type == 1) {
      bytes = utf8.encode(Global.prefs.getString(key));
    } else if (type == 2) {
      bytes = utf8.encode(jsonEncode(Global.prefs.getStringList(key)));
    }
    return ArchiveFile("$key.json", bytes.length, bytes);
  }

  static backup([bool autoBackup = false]) async {
    final profile = Profile();
    final today = intl.DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dir = join(await CacheUtil(backup: true).cacheDir(), "$today.zip");
    if (autoBackup) {
      if (today == profile.autoBackupLastDay ||
          profile.autoBackRate != Profile.autoBackupDay) return;
      Utils.toast("1s后开始自动每日备份，路径$dir，可在设置中取消");
      await Future.delayed(Duration(seconds: 1));
    } else {}
    try {
      final rules = await Rule.backupRules();
      final favorite = SearchItemManager.backupItems();
      final archive = Archive();
      archive.addFile(getArchiveFile("rules", rules, 0));
      archive.addFile(getArchiveFile(Global.searchItemKey, favorite, 0));
      archive.addFile(getArchiveFile(Global.profileKey, "", 1));
      archive.addFile(getArchiveFile(Global.historyItemKey, "", 2));
      archive.addFile(getArchiveFile(Global.searchHistoryKey, "", 2));
      final bytes = ZipEncoder().encode(archive);
      File(dir)
        ..create(recursive: true)
        ..writeAsBytes(bytes);
      Utils.toast("$dir 文件写入成功");
      profile.autoBackupLastDay = today;
      if (profile.enableWebdav) {
        try {
          Client client = Client(
              profile.webdavServer, profile.webdavAccount, profile.webdavPassword, "");
          final ds = (await client.ls()).map((e) => e.name).toList();
          if (!ds.contains("ESO")) {
            await client.mkdir("ESO");
          }
          client.upload(bytes, "ESO/$today.zip");
          Utils.toast("备份至webdav成功");
        } catch (e, st) {
          print("备份至webdav错误 e:$e, st: $st");
          Utils.toast("备份至webdav错误 e:$e\n请检查账户密码或网络", duration: Duration(seconds: 3));
        }
      }
    } catch (e) {
      print("获取备份信息[收藏夹、规则、搜索关键词记录、个人配置]失败 $e");
    }
  }

  void restore(List<int> bytes) {
    ZipDecoder().decodeBytes(bytes).files.forEach((file) async {
      if (file.name == "rules.json") {
        final rules = jsonDecode(utf8.decode(file.content));
        if (rules is List) {
          Rule.restore(rules, false);
          Utils.toast("规则恢复${rules.length}条");
        }
      } else if (file.name == "${Global.searchItemKey}.json") {
        final favorite = utf8.decode(file.content);
        if (favorite != null && favorite is String) {
          SearchItemManager.restore(favorite);
        }
      } else if (file.name == "${Global.profileKey}.json") {
        final profile = utf8.decode(file.content);
        if (profile != null && profile is String && profile.isNotEmpty) {
          Profile().restore(profile);
        }
      } else if (file.name == "${Global.searchItemKey}.json") {
        final searchItem = utf8.decode(file.content);
        if (searchItem != null && searchItem is String && searchItem.isNotEmpty) {
          SearchItemManager.restore(searchItem);
        }
      } else if (file.name == "${Global.historyItemKey}.json") {
        final historyItem = utf8.decode(file.content);
        if (historyItem != null && historyItem is String && historyItem.isNotEmpty) {
          HistoryItemManager.restore(historyItem);
        }
      } else if (file.name == "${Global.searchHistoryKey}.json") {
        final history = utf8.decode(file.content);
        if (history != null && history is String && history.isNotEmpty) {
          HistoryManager.restore(history);
        }
      }
    });
  }

  void restoreLocal(BuildContext context, Offset pos, [String dir]) async {
    if (dir == null) {
      dir = await CacheUtil(backup: true).cacheDir();
    }
    final d = Directory(dir);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    final fs = <String>["选择文件夹 $dir"]..addAll(d.listSync().map((e) => basename(e.path)));
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 100, 0),
      items: fs
          .map((f) => PopupMenuItem<String>(
                value: f,
                child: Text(f),
              ))
          .toList(),
    ).then((value) async {
      if (value == null) return;
      if (value.startsWith("选择文件夹")) {
        String path;
        if (Global.isDesktop) {
          final r = await showOpenPanel(canSelectDirectories: true);
          if (!r.canceled) {
            path = r.paths.first;
          }
        } else {
          final r = await FilePicker.platform.getDirectoryPath();
          path = r;
        }
        if (path == null) {
          Utils.toast("未选择文件夹");
        } else {
          restoreLocal(context, pos, path);
        }
      } else {
        restore(File(join(dir, value)).readAsBytesSync());
      }
    });
  }

  void restoreFromWebDav(BuildContext context, Offset pos) async {
    final profile = Profile();
    try {
      Client client =
          Client(profile.webdavServer, profile.webdavAccount, profile.webdavPassword, "");
      final ds = (await client.ls()).map((e) => e.name).toList();
      if (!ds.contains("ESO")) {
        await client.mkdir("ESO");
      }
      final fs = (await client.ls(path: "ESO"))
          .map((e) => e.name)
          .where((n) => n != "ESO")
          .toList();
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 100, 0),
        items: fs
            .map((f) => PopupMenuItem<String>(
                  value: f,
                  child: Text(f),
                ))
            .toList(),
      ).then((value) async {
        if (value == null) return;
        final req =
            await client.httpClient.getUrl(Uri.parse(client.getUrl("ESO/$value")));
        final res = await req.close();
        final r = await res.toList();
        restore(r.reduce((value, element) => <int>[]..addAll(value)..addAll(element)));
      });
    } catch (e, st) {
      print("restoreFromWebDav 错误 e:$e, st: $st");
      Utils.toast("错误 e:$e\n请检查账户密码或网络", duration: Duration(seconds: 3));
    }
  }
}
