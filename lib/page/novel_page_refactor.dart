import 'dart:convert';

import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:eso/page/content_page_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:text_composition/text_composition.dart';

class NovelPage extends StatelessWidget {
  final SearchItem searchItem;
  const NovelPage({Key key, this.searchItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContentProvider>(context);
    final bookName = "${searchItem.name}(${searchItem.origin})";
    return TextComposition(
      controller: TextCompositionController(
        config: TextCompositionConfig.fromJSON(
            jsonDecode(Global.prefs.containsKey(TextConfigKey) ? Global.prefs.getString(TextConfigKey) : {})),
        loadChapter: provider.loadChapter,
        chapters: searchItem.chapters.map((e) => e.name).toList(),
        percent: searchItem.durContentIndex / NovelContentTotal,
        onsave: (TextCompositionConfig config, double percent) {
          Global.prefs.setString(TextConfigKey, config.toString());
          searchItem.durContentIndex = (percent * NovelContentTotal).floor();
        },
        name: bookName,
      ),
      lastPage: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.amber,
      ),
      // lastPage: Container(
      //   width: double.infinity,
      //   height: double.infinity,
      //   child: Column(
      //     mainAxisSize: MainAxisSize.min,
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Text(bookName),
      //       SizedBox(
      //         height: 10,
      //       ),
      //       Text("内容加载中或更多内容"),
      //     ],
      //   ),
      // ),
    );
  }
}

class NovelProvider with ChangeNotifier {}

const NovelContentTotal = 100000000; // 10000 * 10000 <==> 一万章节 * 一万页
const TextConfigKey = "TextCompositionConfig";
