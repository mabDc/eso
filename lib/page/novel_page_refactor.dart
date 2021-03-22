import 'package:eso/database/search_item.dart';
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
    return TextComposition(
      controller: TextCompositionController(
        TextCompositionConfig(),
        provider.loadChapter,
        searchItem.chapters.map((e) => e.name).toList(),
        searchItem.durChapterIndex / searchItem.chapters.length,
      ),
      lastPage: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(child: Text("${searchItem.name}\n 这是最后一页")),
      ),
    );
  }
}

class NovelProvider with ChangeNotifier {}

const NovelContentTotal = 10000000; // 10000 * 1000 <==> 一万章节 * 一千页
