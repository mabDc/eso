import 'package:eso/database/search_item.dart';
import 'package:eso/page/content_page_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NovelPage extends StatelessWidget {
  final SearchItem searchItem;
  const NovelPage({Key key, this.searchItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContentProvider>(context);
    return FutureBuilder(
      future: provider.loadChapter(0),
      initialData: "获取章节",
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Material(
          child: Center(
            child: Text("${snapshot.data}"),
          ),
        );
      },
    );
  }
}

class NovelProvider with ChangeNotifier {}

const NovelContentTotal = 10000000; // 10000 * 1000 <==> 一万章节 * 一千页
