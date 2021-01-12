import 'dart:convert';

import 'package:eso/profile.dart';
import 'package:eso/ui/ui_text_field.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webdav/webdav.dart';

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
            subtitle: Text(profile.autoBackupLastDay.isEmpty
                ? "上次备份：从未备份"
                : '上次备份：${profile.autoBackupLastDay}.zip'),
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
          SwitchListTile(
            title: Text('启用webdav自动同步'),
            onChanged: (value) => profile.enableWebdav = value,
            value: profile.enableWebdav,
          ),
          Divider(),
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
      );
    } catch (e, st) {
      print("restoreFromWebDav 错误 e:$e, st: $st");
      Utils.toast("错误 e:$e\n请检查账户密码或网络", duration: Duration(seconds: 3));
    }
  }
}
