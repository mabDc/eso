import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaSetting extends StatefulWidget {
  BaSetting({Key key}) : super(key: key);

  @override
  State<BaSetting> createState() => _BaSettingState();
}

BoxDecoration aboutBoxDecoration = BoxDecoration(
  image: DecorationImage(
    fit: BoxFit.fitWidth,
    opacity: 0.8,
    image: AssetImage(
      "assets/ba/水12.jpg",
    ),
  ),
);

class _BaSettingState extends State<BaSetting> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: aboutBoxDecoration,
      margin: EdgeInsets.all(8),
      width: double.infinity,
      height: double.infinity,
      child: ListView(
        children: [
          CupertinoNavigationBar(
            backgroundColor: Colors.transparent,
            middle: Text('背景设置'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text("关于"),
              onPressed: () {},
            ),
            border: null,
          ),
          CupertinoListTile(
            title: Text("选择图片"),
          ),
          Wrap(
            spacing: 10,
            children: ["水1", "水2"].map((u) {
              return Image.asset(
                "assets/ba/$u.jpg",
                height: 200,
                fit: BoxFit.fitHeight,
              );
            }).toList(),
          ),
          CupertinoListTile(
            title: Text("透明度"),
            onTap: () {
              setState(
                () {
                  aboutBoxDecoration = BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      opacity: 0.9,
                      image: AssetImage(
                        "assets/ba/水12.jpg",
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
