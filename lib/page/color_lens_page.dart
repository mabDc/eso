import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../global.dart';
import '../model/profile.dart';

class ColorLensPage extends StatelessWidget {
  const ColorLensPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keys = Global.colors.keys.toList();
    Profile profile = Provider.of<Profile>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('调色板'),
      ),
      body: ListView.builder(
        itemCount: keys.length * 2,
        itemBuilder: (BuildContext context, int index) {
          if (index % 2 == 1) {
            return Divider();
          }
          String colorName = keys[index ~/ 2];
          if ((keys.length - 1) * 2 == index) {
            Color color = Color(Global.colors[colorName]);
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                    height: 32,
                    width: 32,
                  ),
                  title: Text(colorName),
                  onTap: () => profile.colorName = colorName,
                ),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    height: 32,
                    width: 32,
                  ),
                  title: Column(
                    children: <Widget>[
                      Text(''),
                      LinearProgressIndicator(value: color.red / 255),
                      Text('${color.red} / 255'),
                    ],
                  ),
                ),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    height: 32,
                    width: 32,
                  ),
                  title: Column(
                    children: <Widget>[
                      Text(''),
                      LinearProgressIndicator(value: color.green / 255),
                      Text('${color.green} / 255'),
                    ],
                  ),
                ),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    height: 32,
                    width: 32,
                  ),
                  title: Column(
                    children: <Widget>[
                      Text(''),
                      LinearProgressIndicator(value: color.blue / 255),
                      Text('${color.blue} / 255'),
                    ],
                  ),
                ),
              ],
            );
          }
          return ListTile(
            leading: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(Global.colors[colorName]),
              ),
              height: 32,
              width: 32,
            ),
            title: Text(colorName),
            onTap: () => profile.colorName = colorName,
          );
        },
      ),
    );
  }
}
