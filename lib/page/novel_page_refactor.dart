import 'package:eso/database/history_item_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/database/search_item_manager.dart';
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
    return TextCompositionPage(
      controller: TextComposition(
        config: TextCompositionConfig.fromJSON(
            //Global.prefs.containsKey(TextConfigKey) ? jsonDecode(Global.prefs.get(TextConfigKey)) :
            {}),
        loadChapter: provider.loadChapter,
        chapters: searchItem.chapters.map((e) => e.name).toList(),
        percent: () {
          final p = searchItem.durContentIndex / NovelContentTotal;
          final ch = (p * searchItem.chapters.length).floor();
          if (ch == searchItem.durChapterIndex) return p;
          return searchItem.durChapterIndex / searchItem.chapters.length;
        }(),
        onSave: (TextCompositionConfig config, double percent) async {
          // Global.prefs.setString(TextConfigKey, jsonEncode(config.toJSON()));
          searchItem.durContentIndex = (percent * NovelContentTotal).floor();
          final index = (percent * searchItem.chapters.length).floor();
          HistoryItemManager.insertOrUpdateHistoryItem(searchItem);
          if (searchItem.durChapterIndex != index) {
            searchItem.durChapterIndex = index;
            searchItem.durChapter = searchItem.chapters[index].name;
            // searchItem.durContentIndex = 1;
            await SearchItemManager.saveSearchItem();
          }
        },
        name: bookName,
      ),
    );
  }
}

class NovelProvider with ChangeNotifier {}

const NovelContentTotal = 100000000; // 10000 * 10000 <==> 一万章节 * 一万页
const TextConfigKey = "TextCompositionConfig";
