import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/profile.dart';
import '../../global.dart';

class DarkModpage extends StatelessWidget {
  const DarkModpage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darklist = ["开启", "关闭", "跟随系统"];
    return Scaffold(
      appBar: AppBar(
        title: Text('夜间模式'),
      ),
      body: Consumer<Profile>(
        builder: (BuildContext context, Profile profile, Widget widget) {
          return ListView.builder(
            itemCount: darklist.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildColorListTile(darklist[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildColorListTile(String darkMod) {
    return Consumer<Profile>(
      builder: (BuildContext context, Profile profile, Widget widget) {
        return ListTile(
            title: Text(darkMod),
            trailing: darkMod == profile.darkMode
                ? Icon(Icons.done,
                    size: 32,
                    color: Color(Global.colors[profile.colorName] ?? profile.customColor))
                : null,
            onTap: () => profile.darkMode = darkMod);
      },
    );
  }
}
