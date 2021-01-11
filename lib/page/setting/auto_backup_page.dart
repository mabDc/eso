import 'package:eso/profile.dart';
import 'package:flutter/material.dart';

class AutoBackupPage extends StatelessWidget {
  const AutoBackupPage({Key key}) : super(key: key);

  AlertDialog showTextDialog(BuildContext context, String title) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(6.0),
      content: TextField(),
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
            Navigator.of(context).pop();
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
            title: Text('自动备份频率'),
            subtitle: Text('最近 2021-01-11.zip'),
          ),
          Divider(),
          RadioListTile(
            title: Text('从不'),
            value: AutoBackup.day,
            groupValue: AutoBackup.none,
            onChanged: (vallue) {},
          ),
          RadioListTile(
            title: Text('每日'),
            value: AutoBackup.day,
            groupValue: AutoBackup.day,
            onChanged: (vallue) {},
          ),
          Divider(),
          SwitchListTile(
            title: Text('启用webdav自动同步'),
            onChanged: (value) {},
            value: true,
          ),
          Divider(),
          ListTile(
            title: Text('服务器地址'),
            subtitle: Text('输入您的服务器地址'),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(context, '服务器地址'),
            ),
          ),
          ListTile(
            title: Text('账号'),
            subtitle: Text('输入您的账号'),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(context, '账号'),
            ),
          ),
          ListTile(
            title: Text('密码'),
            subtitle: Text('输入您的授权密码'),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(context, '密码'),
            ),
          ),
          ListTile(
            title: Text('恢复'),
            subtitle: Text('从webdav恢复'),
          ),
          Divider(),
        ],
      ),
    );
  }
}

enum AutoBackup {
  none,
  day,
}
