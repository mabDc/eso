import 'package:eso/api/api.dart';
import 'package:eso/database/history_item_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/ui/ui_text_field.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../fonticons_icons.dart';
import '../global.dart';
import 'chapter_page.dart';


class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  var isLargeScreen = false;
  Widget detailPage;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        isLargeScreen = true;
      } else {
        isLargeScreen = false;
      }

      return Row(children: <Widget>[
        Expanded(
          child: HistoryPage2(invokeTap: (Widget detailPage) {
            if (isLargeScreen) {
              this.detailPage = detailPage;
              setState(() {});
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => detailPage,
                  ));
            }
          }),
        ),
        SizedBox(
          height: double.infinity,
          width:2,
          child: Material(
            color: Colors.grey.withAlpha(123),
          ),
        ),
        isLargeScreen ? Expanded(child: detailPage ?? Scaffold()) : Container(),
      ]);
    });
  }
}

class HistoryPage2 extends StatelessWidget {
  final void Function(Widget) invokeTap;
  const HistoryPage2({Key key,this.invokeTap}) : super(key: key);
  void alert(BuildContext context, Widget title, Widget content, VoidCallback handle) =>
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: title,
          content: content,
          actions: [
            TextButton(
              child: Text(
                "取消",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                "确定",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                handle();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HistoryPageProvider>(
      create: (_) => HistoryPageProvider(),
      builder: (context, child) {
        final provider = Provider.of<HistoryPageProvider>(context, listen: false);
        return Scaffold(
          appBar: AppBar(
            title: SearchTextField(
              controller: provider.editingController,
              hintText: "搜索历史(共${provider.historyItem.length ?? 0}条)",
              onSubmitted: (value) => provider.getRuleListByName(value),
              onChanged: (value) => provider.getRuleListByNameDebounce(value),
            ),
            actions: [
              IconButton(
                  icon: Icon(FIcons.check_square), onPressed: provider.toggleCheck),
              IconButton(
                icon: Icon(Icons.delete_sweep),
                onPressed: () {
                  final checkCount = provider.checkCount;
                  if (checkCount == 0) {
                    Utils.toast("请先选择");
                    return;
                  }
                  alert(
                    context,
                    Text("警告(不可恢复)"),
                    Text("删除选中$checkCount条记录"),
                    () => provider.delete(),
                  );
                },
              ),
            ],
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
    final provider = Provider.of<HistoryPageProvider>(context, listen: true);
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
      list.add(buildItem(provider, context, item, lastRead));
      list.add(Divider());
    }
    return list;
  }

  Widget buildItem(HistoryPageProvider provider, BuildContext context, SearchItem item,
      DateTime lastRead) {
    return InkWell(
      onTap: () {
        if (item.chapters != null && item.chapters.isEmpty) {
          item.chapters = null;
        }
        if (provider.checkkMode) {
          provider.checkOne(item.id);
          return;
        }
       invokeTap(ChapterPage(searchItem: item, key: Key(item.id.toString())));
      },
      child: Container(
        height: 90,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            if (provider.checkkMode)
              Container(
                padding: EdgeInsets.all(8),
                child: Icon(provider.isCheck(item.id)
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank),
              ),
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
  bool _checkMode;
  bool get checkkMode => _checkMode == true;

  toggleCheck() {
    _checkMode = !checkkMode;
    if (!_checkMode) _idSet.clear();
    notifyListeners();
  }

  final _idSet = Set<int>();

  delete() async {
    await HistoryItemManager.removeSearchItem(_idSet);
    _historyItem =
        HistoryItemManager.getHistoryItemByType(_editingController.text, _contentType);
    notifyListeners();
  }

  bool isCheck(int id) => _idSet.contains(id);
  int get checkCount => _idSet.length;
  checkOne(int id) {
    if (isCheck(id)) {
      _idSet.remove(id);
    } else {
      _idSet.add(id);
    }
    notifyListeners();
  }

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
  bool _lockDataBase = false;
  void getRuleListByNameDebounce(String name) {
    if (_lockDataBase) return;
    _loadTime = DateTime.now();
    Future.delayed(const Duration(milliseconds: 301), () {
      if (DateTime.now().difference(_loadTime).inMilliseconds > 300) {
        getRuleListByName(name);
      }
    });
  }

  void getRuleListByName(String name) {
    if (_lockDataBase) return;
    _lockDataBase = true;
    _historyItem = HistoryItemManager.getHistoryItemByType(name, _contentType);
    notifyListeners();
    _lockDataBase = false;
  }
}
