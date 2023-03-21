import 'dart:io';

import 'package:eso/main.dart';
import 'package:flutter/material.dart';
import 'about.dart';
import 'parser.dart';
import 'request.dart';


class RequestAndParserTestTool extends StatelessWidget {
  const RequestAndParserTestTool({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    const r = Request();
    const p = Parser();
    const a = About();
    return Container(
      decoration: globalDecoration,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("QING 请求测试与解析辅助工具"),
        ),
        body: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    child: r,
                    flex: 2,
                  ),
                  Expanded(
                    child: p,
                    flex: 2,
                  ),
                  Expanded(
                    child: a,
                    flex: 1,
                  ),
                ],
              )
            : DefaultTabController(
                length: 3,
                child: Column(
                  children: const <Widget>[
                    TabBar(
                      labelColor: Colors.pink,
                      unselectedLabelColor: Colors.cyan,
                      indicatorWeight: 1.0,
                      // labelPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      labelStyle: TextStyle(fontSize: 14),
                      tabs: <Widget>[
                        Tab(text: '请求'),
                        Tab(text: '解析'),
                        Tab(text: '频道'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          r,
                          p,
                          a,
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
