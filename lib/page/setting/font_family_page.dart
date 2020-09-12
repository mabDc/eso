import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/profile.dart';
import '../../global.dart';

class FontFamilyPage extends StatelessWidget {
  const FontFamilyPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontList = <String, String>{
      "默认": null,
      "Roboto": "Roboto",
      "萝莉字体": "Lolita_V2",
      "文泉驿正黑": "文泉驿",
      "腾祥嘉丽圆体": "腾祥嘉丽",
    }.entries.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('字体选择'),
      ),
      body: Consumer<Profile>(
        builder: (BuildContext context, Profile profile, Widget widget) {
          return ListView.builder(
            itemCount: fontList.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildColorListTile(fontList[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildColorListTile(MapEntry<String, String> font) {
    return Consumer<Profile>(
      builder: (BuildContext context, Profile profile, Widget widget) {
        return ListTile(
          title: Text(
            font.key,
            style: TextStyle(fontFamily: font.value),
          ),
          trailing: font.value == profile.fontFamily
              ? Icon(Icons.done,
                  size: 32,
                  color: Color(Global.colors[profile.colorName] ?? profile.customColor))
              : null,
          onTap: () => profile.fontFamily = font.value,
        );
      },
    );
  }
}
