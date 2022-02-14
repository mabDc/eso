import 'dart:convert';

import 'package:flutter/material.dart';
import 'const.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({Key key}) : super(key: key);

  Widget buildPindao(PinDao pinDao) {
    return InkWell(
      onTap: () => launch(pinDao.url),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Image.memory(
              base64Decode(pinDao.base64.split(',')[1]),
              fit: BoxFit.contain,
            ),
          ),
          Text(pinDao.name),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          children: [
            const ListTile(
              title: Text(joinPindao),
            ),
            buildPindao(yueduPindao),
            const SizedBox(height: 10),
            buildPindao(esoPindao),
            const SizedBox(height: 10),
            const ListTile(
              title: Text("更新日志"),
              subtitle: Text("""
v0.0.3 解析
v0.0.2 请求 生成阅读 生成亦搜
v0.0.1 搬运代码 没什么功能
"""),
            )
          ],
        ),
      ),
    );
  }
}
