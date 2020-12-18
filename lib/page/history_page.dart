import 'package:eso/api/api.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/ui/ui_text_field.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import 'chapter_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoryPageProvider>(
      create: (_) => HistoryPageProvider(),
      builder: (context, child) {
        final provider = Provider.of<HistoryPageProvider>(context, listen: false);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: SearchTextField(
              controller: provider.editingController,
              hintText: "搜索历史(共${provider.historyItem.length ?? 0}条)",
              onSubmitted: (value) => provider.getRuleListByName(value),
              onChanged: (value) => provider.getRuleListByNameDebounce(value),
            ),
          ),
          body: RefreshIndicator(
            onRefresh: provider.refresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Wrap(
                    spacing: 10,
                    children: [
                      for (final contentType in [
                        null,
                        API.NOVEL,
                        API.MANGA,
                        API.AUDIO,
                        API.VIDEO,
                      ])
                        buildButton(context, contentType)
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: buildItems(context),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> buildItems(BuildContext context) {
    final historyItem =
        context.select((HistoryPageProvider provider) => provider.historyItem);
    final list = <Widget>[];
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
        .add(Duration(days: 1));
    int days = -1;
    for (var item in historyItem) {
      final lastRead = DateTime.fromMicrosecondsSinceEpoch(item.lastReadTime);
      final _days = today.difference(lastRead).inDays;
      if (days != _days) {
        days = _days;
        list.add(ListTile(
          title: Text(
            days == 0
                ? '今天'
                : days == 1
                    ? '昨天'
                    : '$days天前',
          ),
        ));
      }
      list.add(buildItem(context, item, lastRead));
      list.add(Divider());
    }
    return list;
  }

  Widget buildItem(BuildContext context, SearchItem item, DateTime lastRead) {
    return InkWell(
      onTap: () {
        if (item.chapters.isEmpty) {
          item.chapters = null;
        }
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => ChapterPage(searchItem: item)))
            .whenComplete(
                () => Provider.of<HistoryPageProvider>(context, listen: false).refresh());
      },
      child: Container(
        height: 90,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 70,
              child: UIImageItem(
                cover: item.cover,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item.durChapter,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    lastRead.toString().substring(0, 19),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10),
                  ),
                  Text(
                    item.origin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, int contentType) {
    final curContentType =
        context.select((HistoryPageProvider provider) => provider.contentType);
    final selected = curContentType == contentType;
    return GestureDetector(
      onTap: () => Provider.of<HistoryPageProvider>(context, listen: false).contentType =
          contentType,
      child: Material(
        color: selected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            side: BorderSide(
                width: Global.borderSize,
                color: selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(8, 3, 8, 3),
          child: Text(
            contentType == null ? '全部' : API.getRuleContentTypeName(contentType),
            style: TextStyle(
              fontSize: 11,
              color: selected
                  ? Theme.of(context).cardColor
                  : Theme.of(context).textTheme.bodyText1.color,
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryPageProvider with ChangeNotifier {
  HistoryPageProvider() {
    _editingController = TextEditingController();
    _historyItem =
        HistoryItemManager.getHistoryItemByType(_editingController.text, _contentType);
  }

  Future<void> refresh() async {
    getRuleListByName(_editingController.text);
  }

  int _contentType;
  int get contentType => _contentType;
  set contentType(int value) {
    if (value != _contentType) {
      _contentType = value;
      getRuleListByName(_editingController.text);
    }
  }

  List<SearchItem> _historyItem;
  List<SearchItem> get historyItem => _historyItem;
  TextEditingController _editingController;
  TextEditingController get editingController => _editingController;
  DateTime _loadTime;
  void getRuleListByNameDebounce(String name) {
    _loadTime = DateTime.now();
    Future.delayed(const Duration(milliseconds: 301), () {
      if (DateTime.now().difference(_loadTime).inMilliseconds > 300) {
        getRuleListByName(name);
      }
    });
  }

  void getRuleListByName(String name) {
    _historyItem = HistoryItemManager.getHistoryItemByType(name, _contentType);
    notifyListeners();
  }
}
