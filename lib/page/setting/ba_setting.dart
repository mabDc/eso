import 'package:flutter/material.dart';

class BaSetting extends StatefulWidget {
  BaSetting({Key key}) : super(key: key);

  @override
  State<BaSetting> createState() => _BaSettingState();
}

BoxDecoration aboutBoxDecoration = BoxDecoration(
  image: DecorationImage(
    fit: BoxFit.fitWidth,
    opacity: 0.6,
    image: AssetImage(
      "assets/ba/水12.jpg",
    ),
  ),
);

class _BaSettingState extends State<BaSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("背景设置"),
      ),
      body: ListView(
        children: [gen1("关于", aboutBoxDecoration)],
      ),
    );
  }

  gen1(String title, BoxDecoration decoration) {
    return Container(
      decoration: decoration,
      margin: EdgeInsets.all(8),
      width: double.infinity,
      height: 300,
      child: Column(children: [Text(title)]),
    );
  }
}
