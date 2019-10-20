import 'dart:math';

import 'package:eso/ui/ui_search_item.dart';
import 'package:eso/ui/ui_shelf_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liquidcore/liquidcore.dart';
import '../global.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key key}) : super(key: key);
  
  void test(BuildContext context) async {
    JSContext jsContext = JSContext();
    int start = DateTime.now().millisecondsSinceEpoch;
    String script =
    await DefaultAssetBundle.of(context).loadString(Global.cheerioFile);
    await jsContext.evaluateScript(script);
    final a = await jsContext.evaluateScript("var \$ = cheerio.load('<div><a>111</a></div>');\$('div').find('*').text()");
    print(a);
    int end = DateTime.now().millisecondsSinceEpoch;
    print(end-start);
  }
  
  @override
  Widget build(BuildContext context) {
    Random random = Random();
    return Scaffold(
      appBar: AppBar(
        title: Text(Global.appName),
      ),
      body: ListView.builder(
        itemBuilder: (context, index){
          final itemInfo = {};
          if(random.nextInt(10) > 5){
            return buildUiSearchItem(itemInfo);
          }
          return buildUiShelfItem(itemInfo);
        },
      ),
    );
  }
}
