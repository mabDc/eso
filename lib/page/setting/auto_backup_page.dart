import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/database/history_manager.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/main.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webdav/webdav.dart';
import 'package:intl/intl.dart' as intl;
import 'package:path/path.dart';

import '../../global.dart';

class AutoBackupPage extends StatelessWidget {
  const AutoBackupPage({Key key}) : super(key: key);

  AlertDialog showTextDialog(
      BuildContext context, String title, String s, void Function(String s) press,
      [bool isPassword = false]) {
    TextEditingController controller = TextEditingController(text: s);
    return AlertDialog(
      content: TextField(controller: controller),
      title: Text(title),
      actions: [
        TextButton(
          child: Text(
            "取消",
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(
            "确定",
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            if (isPassword && controller.text.length < 6) {
              Utils.toast("输入需大于六位");
              return;
            }
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
    final profile = ESOTheme();
    return Container(
      decoration: globalDecoration,
      child: Scaffold(
        appBar: AppBar(
          title: Text('备份恢复与webdav'),
        ),
        body: ListView(
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(title: Text('自动备份')),
                  Divider(),
                  StatefulBuilder(
                    builder: (context, setState) => Column(
                      children: [
                        RadioListTile<int>(
                          title: Text('从不'),
                          value: ESOTheme.autoBackupNone,
                          groupValue: profile.autoBackRate,
                          onChanged: (int value) =>
                              setState(() => profile.autoBackRate = value),
                        ),
                        RadioListTile<int>(
                          title: Text('每日'),
                          value: ESOTheme.autoBackupDay,
                          groupValue: profile.autoBackRate,
                          onChanged: (int value) =>
                              setState(() => profile.autoBackRate = value),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  ListTile(
                    title: Text('备份'),
                    subtitle: Text(profile.autoBackupLastDay.isEmpty
                        ? "上次备份：从未备份"
                        : '上次备份：${profile.autoBackupLastDay}.${Platform.operatingSystem}.zip'),
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
                        restoreLocal(context, false, '选择文件恢复'),
                  ),
                  GestureDetector(
                    child: ListTile(
                      title: Text('仅恢复规则'),
                      subtitle: Text('选择文件恢复'),
                    ),
                    onTapUp: (TapUpDetails details) =>
                        restoreLocal(context, true, '选择文件恢复规则'),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  StatefulBuilder(
                    builder: (context, setState) => SwitchListTile(
                      title: Text('启用规则分享'),
                      subtitle: Text('每日自动分享，不会自动覆盖删除，建议关闭'),
                      onChanged: (value) =>
                          setState(() => profile.enableWebdavRule = value),
                      value: profile.enableWebdavRule,
                    ),
                  ),
                  ListTile(
                    title: Text('分享的用户名称'),
                    subtitle: Text(profile.webdavRuleAccount.isEmpty
                        ? '输入用户名称'
                        : profile.webdavRuleAccount),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => showTextDialog(
                        context,
                        '账号',
                        profile.webdavRuleAccount,
                        (s) => profile.webdavRuleAccount = s,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('分享的用户校验码'),
                    subtitle: Text(profile.webdavRuleCheckcode.isEmpty
                        ? '防止覆盖同名用户, 至少六位'
                        : '*' * profile.webdavRuleCheckcode.length),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => showTextDialog(
                        context,
                        '密码',
                        profile.webdavRuleCheckcode,
                        (s) => profile.webdavRuleCheckcode = s,
                        true,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('分享至云上'),
                    subtitle: Text(profile.autoRuleUploadLastDay.isEmpty
                        ? "上次分享：从未分享"
                        : '上次分享：${profile.webdavRuleAccount}.${profile.autoRuleUploadLastDay}.zip'),
                    onTap: shareRule,
                  ),
                  GestureDetector(
                    child: ListTile(
                      title: Text('导入分享的规则'),
                    ),
                    onTapUp: (TapUpDetails details) =>
                        restoreShareRule(context, details.globalPosition, false),
                  ),
                  GestureDetector(
                    child: ListTile(
                      title: Text('下载分享的规则'),
                    ),
                    onTapUp: (TapUpDetails details) =>
                        restoreShareRule(context, details.globalPosition, true),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  StatefulBuilder(
                    builder: (context, setState) => SwitchListTile(
                      title: Text('启用webdav自动同步'),
                      subtitle: Text('备份或自动备份后自动上传至webdav'),
                      onChanged: (value) => setState(() => profile.enableWebdav = value),
                      value: profile.enableWebdav,
                    ),
                  ),
                  ListTile(
                    title: Text('坚果云webdav帮助'),
                    subtitle: Text("https://help.jianguoyun.com/?p=2064"),
                    onTap: () => launch('https://help.jianguoyun.com/?p=2064'),
                  ),
                  ListTile(
                    title: Text('服务器地址'),
                    subtitle: Text(profile.webdavServer.isEmpty
                        ? '输入您的服务器地址'
                        : profile.webdavServer),
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
                    subtitle: Text(
                        profile.webdavAccount.isEmpty ? '输入您的账号' : profile.webdavAccount),
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
                        restoreFromWebDav(context, details.globalPosition, false),
                  ),
                  GestureDetector(
                    child: ListTile(
                      title: Text('仅恢复规则'),
                      subtitle: Text('从webdav恢复'),
                    ),
                    onTapUp: (TapUpDetails details) =>
                        restoreFromWebDav(context, details.globalPosition, true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const myWebdavAccount = '747455334@qq.com';
  static const myWebdavPassword = 'ae2v6ggvbw6khcty';
  static const myWebdavServer = 'https://dav.jianguoyun.com/dav/';

  static shareRule([bool autoShare = false]) async {
    final profile = ESOTheme();
    final today = intl.DateFormat('yyyy-MM-dd').format(DateTime.now());
    final fileName = Uri.encodeComponent(
        'share.${profile.webdavRuleCheckcode}.rule.${profile.webdavRuleAccount}.$today.zip');
    if (autoShare) {
      if (today == profile.autoRuleUploadLastDay || !profile.enableWebdavRule) return;
      if (profile.webdavRuleAccount.trim().isEmpty ||
          profile.webdavRuleCheckcode.trim().isEmpty) {
        profile.autoRuleUploadLastDay = today;
        Utils.toast("分享的用户名称和校验码不可为空");
        return;
      }
      Utils.toast("1s后开始自动每日上传规则，可在设置中取消");
      await Future.delayed(Duration(seconds: 1));
    }
    try {
      final rules = await Rule.backupRules(await Global.ruleDao.findUploadRules());
      final archive = Archive();
      archive.addFile(getArchiveFile("rules", rules));
      final bytes = ZipEncoder().encode(archive);

      try {
        Client client =
            Client(myWebdavServer, myWebdavAccount, myWebdavPassword, path: "ESO");
        await client.upload(bytes, "$fileName");
        profile.autoRuleUploadLastDay = today;
        Utils.toast("上传分享规则（共${rules.length}条）至webdav成功");
      } catch (e, st) {
        print("上传分享规则至webdav错误 e:$e, st: $st");
        Utils.toast("上传分享规则至webdav错误 e:$e\n请检查账户密码或网络", duration: Duration(seconds: 3));
      }
    } catch (e) {
      print("上传规则失败 $e");
    }
  }

  share() async {
    final profile = ESOTheme();
    if (profile.autoBackupLastDay.isEmpty) {
      Utils.toast("从未备份");
      return;
    }
    final today = intl.DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dir = join(await CacheUtil(backup: true).cacheDir(),
        "$today.${Platform.operatingSystem}.zip");
    // FlutterShare.shareFile(title: "$today.zip", filePath: dir, text: "$today.zip");
    Share.shareFiles(<String>[dir], text: "$today.zip");
  }

  /// type: 0->s, 1->getString, 2-> getStringList
  static getArchiveFile(String key, String s) {
    // List<int> bytes;
    // if (type == 0) {
    //   bytes = utf8.encode(s);
    // } else if (type == 1) {
    //   // bytes = utf8.encode(Global.prefs.getString(key));
    // } else if (type == 2) {
    //   // bytes = utf8.encode(jsonEncode(Global.prefs.getStringList(key)));
    // }
    final bytes = utf8.encode(s);
    return ArchiveFile("$key.json", bytes.length, bytes);
  }

  static backup([bool autoBackup = false]) async {
    final profile = ESOTheme();
    final today = intl.DateFormat('yyyy-MM-dd').format(DateTime.now());
    // final fileName = '$today.${Platform.operatingSystem}.${Platform.operatingSystemVersion}.zip';
    final fileName = '$today.${Platform.operatingSystem}.zip';
    final dir = join(await CacheUtil(backup: true).cacheDir(), fileName);
    if (autoBackup) {
      if (today == profile.autoBackupLastDay ||
          profile.autoBackRate != ESOTheme.autoBackupDay) return;
      Utils.toast("1s后开始自动每日备份，路径$dir，可在设置中取消");
      await Future.delayed(Duration(seconds: 1));
    }
    try {
      final rules = await Rule.backupRules();
      final favorite = SearchItemManager.backupItems();
      final archive = Archive();
      archive.addFile(getArchiveFile("rules", rules));
      archive.addFile(getArchiveFile(Global.searchItemKey, favorite));
      archive.addFile(getArchiveFile(Global.profileKey, ESOTheme.backUpESOTheme()));
      archive.addFile(
          getArchiveFile(Global.historyItemKey, HistoryItemManager.backupItems()));
      archive.addFile(
          getArchiveFile(Global.searchHistoryKey, HistoryManager.backUpsearchHistory()));
      // archive.addFile(getArchiveFile(Global.profileKey, "", 1));
      // archive.addFile(getArchiveFile(Global.historyItemKey, "", 2));
      // archive.addFile(getArchiveFile(Global.searchHistoryKey, "", 2));
      final bytes = ZipEncoder().encode(archive);
      try {
        File(dir)
          ..create(recursive: true)
          ..writeAsBytes(bytes);
        Utils.toast("$dir 文件写入成功");
      } catch (e) {
        Utils.toast("文件写入失败 $e");
      }

      profile.autoBackupLastDay = today;
      if (profile.enableWebdav) {
        try {
          Client client = Client(
              profile.webdavServer, profile.webdavAccount, profile.webdavPassword,
              path: "ESO");
          await client.mkdir("");
          await client.upload(bytes, "$fileName");
          Utils.toast("备份至webdav成功");
        } catch (e, st) {
          print("备份至webdav错误 e:$e, st: $st");
          Utils.toast("备份至webdav错误 e:$e\n请检查账户密码或网络", duration: Duration(seconds: 3));
        }
      }
    } catch (e) {
      print("获取备份信息[收藏夹、规则、搜索关键词记录、个人配置]失败 $e");
      Utils.toast("获取备份信息[收藏夹、规则、搜索关键词记录、个人配置]失败 $e");
    }
  }

  void restore(List<int> bytes, bool isOnlyRule) {
    ZipDecoder().decodeBytes(bytes).files.forEach((file) async {
      if (file.name == "rules.json") {
        final rules = jsonDecode(utf8.decode(file.content, allowMalformed: true));
        if (rules is List) {
          Rule.restore(rules, false);
          Utils.toast("规则导入${rules.length}条");
        }
        return;
      }
      if (isOnlyRule) return;
      if (file.name == "${Global.searchItemKey}.json") {
        final favorite = utf8.decode(file.content, allowMalformed: true);
        if (favorite != null && favorite is String) {
          SearchItemManager.restore(favorite);
        }
      } else if (file.name == "${Global.profileKey}.json") {
        final profile = utf8.decode(file.content, allowMalformed: true);
        if (profile != null && profile is String && profile.isNotEmpty) {
          ESOTheme().restore(profile);
        }
      } else if (file.name == "${Global.searchItemKey}.json") {
        final searchItem = utf8.decode(file.content, allowMalformed: true);
        if (searchItem != null && searchItem is String && searchItem.isNotEmpty) {
          SearchItemManager.restore(searchItem);
        }
      } else if (file.name == "${Global.historyItemKey}.json") {
        final historyItem = utf8.decode(file.content, allowMalformed: true);
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

  void restoreLocal(BuildContext context, bool isOnlyRule, String title) async {
    final dir = await CacheUtil(backup: true).cacheDir();
    // String path = await FilesystemPicker.open(
    //   title: title,
    //   context: context,
    //   rootDirectory: Directory(dir),
    //   rootName: dir,
    //   fsType: FilesystemType.file,
    //   folderIconColor: Colors.teal,
    //   allowedExtensions: ['.zip', '.txt', '.json'],
    //   fileTileSelectMode: FileTileSelectMode.wholeTile,
    //   requestPermission: CacheUtil.requestPermission,
    // );
    final path = await Utils.pickFile(
        context, ['.zip', '.txt', '.json'], dir + "backup.zip",
        title: title);
    if (path == null) {
      Utils.toast("未选择文件");
    } else if (path.endsWith(".txt") || path.endsWith(".json")) {
      final rules = jsonDecode(File(path).readAsStringSync());
      final ruleList = rules is List ? rules : [rules];
      Rule.restore(ruleList, false);
      Utils.toast("规则导入${rules.length}条");
    } else {
      restore(File(path).readAsBytesSync(), false);
    }
  }

  String decodeShareRuleName(String name) {
    int lastPos = name.lastIndexOf(".rule.");
    return name.substring(lastPos + ".rule.".length);
  }

  void restoreShareRule(BuildContext context, Offset pos, bool download) async {
    try {
      var client = Client(myWebdavServer, myWebdavAccount, myWebdavPassword, path: "ESO");
      final files = await client.ls();
      final fs = <String>[];
      for (var file in files) {
        final name = Utils.getFileNameAndExt(file.path);
        if (name.startsWith("share.") && name.indexOf(".rule..") == -1) fs.add(name);
      }
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 100, 0),
        items: fs.map((f) {
          return PopupMenuItem<String>(
            value: f,
            child: Text(decodeShareRuleName(f)),
          );
        }).toList(),
      ).then((value) async {
        if (value == null) return;
        final req = await client.httpClient.getUrl(Uri.parse(client.getUrl("$value")));
        final res = await req.close();
        final r = await res.toList();
        final bytes = r.reduce((value, element) => <int>[]
          ..addAll(value)
          ..addAll(element));
        if (download) {
          final dir =
              join(await CacheUtil(backup: true).cacheDir(), decodeShareRuleName(value));
          File(dir)
            ..create(recursive: true)
            ..writeAsBytes(bytes);
          Utils.toast("写入至$dir");
        } else {
          restore(bytes, true);
        }
      });
    } catch (e, st) {
      print("restoreFromWebDav 错误 e:$e, st: $st");
      Utils.toast("错误 e:$e\n请检查账户密码或网络", duration: Duration(seconds: 3));
    }
  }

  void restoreFromWebDav(BuildContext context, Offset pos, bool isOnlyRule) async {
    final profile = ESOTheme();
    try {
      Client client = Client(
          profile.webdavServer, profile.webdavAccount, profile.webdavPassword,
          path: "ESO");

      final fs = (await client.ls()).map((e) => Utils.getFileNameAndExt(e.path)).toList();
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
        final req = await client.httpClient.getUrl(Uri.parse(client.getUrl("$value")));
        final res = await req.close();
        final r = await res.toList();
        restore(
            r.reduce((value, element) => <int>[]
              ..addAll(value)
              ..addAll(element)),
            isOnlyRule);
      });
    } catch (e, st) {
      print("restoreFromWebDav 错误 e:$e, st: $st");
      Utils.toast("错误 e:$e\n请检查账户密码或网络", duration: Duration(seconds: 3));
    }
  }
}
