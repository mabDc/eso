import 'dart:ui';

import 'package:eso/api/api_from_rule.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/page/source/edit_rule_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../discover_search_page.dart';

//图源编辑
class EditSourcePage extends StatelessWidget {
  const EditSourcePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditSourceProvider>(
      create: (context) => EditSourceProvider(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          title: TextField(
            cursorColor: Theme.of(context).primaryColor,
            cursorRadius: Radius.circular(2),
            selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              hintText:
                  "搜索名称和分组(共${context.select((EditSourceProvider provider) => provider.rules)?.length ?? 0}条)",
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
                fontSize: 12,
              ),
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 4),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.7),
                ),
              ),
              prefixIconConstraints: BoxConstraints(),
            ),
            maxLines: 1,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              height: 1.25,
            ),
            onSubmitted:
                Provider.of<EditSourceProvider>(context, listen: false).getRuleListByName,
            onChanged: Provider.of<EditSourceProvider>(context, listen: false)
                .getRuleListByNameDebounce,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.check_circle_outline),
              onPressed: Provider.of<EditSourceProvider>(context, listen: false)
                  .toggleCheckAllRule,
            ),
            _buildpopupMenu(
              context,
              context.select((EditSourceProvider provider) => provider.isLoadingUrl),
              Provider.of<EditSourceProvider>(context, listen: false),
            ),
          ],
        ),
        body: Consumer<EditSourceProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return LandingPage();
            }
            return ListView.separated(
              separatorBuilder: (BuildContext context, int index) => Container(),
              // UIDash(
              //   color: Colors.black54,
              //   height: 0.5,
              //   dashWidth: 5,
              // ),
              itemCount: provider.rules.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return _buildItem(context, provider, provider.rules[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, EditSourceProvider provider, Rule rule) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: InkWell(
        onTap: () {
          Toast.show(rule.name, context);
        },
        child: CheckboxListTile(
          value: rule.enableSearch,
          activeColor: Theme.of(context).primaryColor,
          title: Text('${rule.name}'),
          subtitle: Text(
            '${rule.host}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onChanged: (value) => provider.toggleEnableSearch(rule),
        ),
        onLongPress: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DiscoverSearchPage(
                  originTag: rule.id,
                  origin: rule.name,
                  discoverMap: APIFromRUle(rule).discoverMap(),
                ))),
      ),
      actions: [
        IconSlideAction(
          caption: '置顶',
          color: Colors.blueGrey,
          icon: Icons.vertical_align_top,
          onTap: () => provider.setSortMax(rule),
        ),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: '编辑',
          color: Colors.black45,
          icon: Icons.create,
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => EditRulePage(rule: rule)))
              .whenComplete(() => provider.refreshData()),
        ),
        IconSlideAction(
          caption: '删除',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => provider.deleteRule(rule),
        ),
      ],
    );
  }

  void showURLDialog(
    BuildContext context,
    bool isLoadingUrl,
    EditSourceProvider provider,
    bool isYICIYUAN,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "输入源地址, 回车开始导入",
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          enabled: !isLoadingUrl,
          onSubmitted: (url) async {
            Toast.show("开始导入$url", context, duration: 1);
            final count = await provider.addFromUrl(url.trim(), isYICIYUAN);
            Toast.show("导入完成，一共$count条", context, duration: 1);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void showDeleteAllDialog(BuildContext context, EditSourceProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Text("警告"),
            ],
          ),
          content: Text("是否删除所有站点？"),
          actions: [
            FlatButton(
              child: Text(
                "确定",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                provider.deleteAllRules();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                "取消",
                style: Theme.of(context).textTheme.subtitle2,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildpopupMenu(
      BuildContext context, bool isLoadingUrl, EditSourceProvider provider) {
    final primaryColor = Theme.of(context).primaryColor;
    const int ADD_RULE = 0;
    const int FROM_FILE = 2;
    const int FROM_CLOUD = 3;
    const int FROM_YICIYUAN = 4;
    const int DELETE_ALL_RULES = 5;
    return PopupMenuButton<int>(
      elevation: 20,
      icon: Icon(Icons.add),
      offset: Offset(0, 40),
      onSelected: (int value) {
        switch (value) {
          case ADD_RULE:
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => EditRulePage()));
            break;
          case FROM_FILE:
            Toast.show("从本地文件导入", context);
            break;
          case FROM_CLOUD:
            showURLDialog(context, isLoadingUrl, provider, false);
            break;
          case FROM_YICIYUAN:
            showURLDialog(context, isLoadingUrl, provider, true);
            break;
          case DELETE_ALL_RULES:
            showDeleteAllDialog(context, provider);
            break;
          default:
        }
      },
      itemBuilder: (context) => [
        {'title': '新建规则', 'icon': Icons.code, 'type': ADD_RULE},
        {'title': '阅读或异次元', 'icon': Icons.cloud_download, 'type': FROM_YICIYUAN},
        // {'title': '文件导入', 'icon': Icons.file_download, 'type': FROM_FILE},
        {'title': '网络导入', 'icon': Icons.cloud_download, 'type': FROM_CLOUD},
        {'title': '清空源', 'icon': Icons.delete_forever, 'type': DELETE_ALL_RULES},
      ]
          .map(
            (element) => PopupMenuItem<int>(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(element['title']),
                  Icon(element['icon'], color: primaryColor),
                ],
              ),
              value: element['type'],
            ),
          )
          .toList(),
    );
    // return Consumer<EditSourceProvider>(
    //   builder: (context, provider, child) => PopupMenuButton<int>(
    //     elevation: 20,
    //     icon: Icon(Icons.add),
    //     offset: Offset(0, 40),
    //     onSelected: (int value) {
    //       switch (value) {
    //         case ADD_RULE:
    //           Navigator.of(context)
    //               .push(MaterialPageRoute(builder: (context) => EditRulePage()));
    //           break;
    //         case FROM_FILE:
    //           Toast.show("从本地文件导入", context);
    //           break;
    //         case FROM_CLOUD:
    //           showURLDialog(context, provider, false);
    //           break;
    //         case FROM_YICIYUAN:
    //           showURLDialog(context, provider, true);
    //           break;
    //         case DELETE_ALL_RULES:
    //           showDeleteAllDialog(context, provider);
    //           break;
    //         default:
    //       }
    //     },
    //     itemBuilder: (context) => [
    //       {'title': '新建规则', 'icon': Icons.code, 'type': ADD_RULE},
    //       {'title': '阅读或异次元', 'icon': Icons.cloud_download, 'type': FROM_YICIYUAN},
    //       // {'title': '文件导入', 'icon': Icons.file_download, 'type': FROM_FILE},
    //       {'title': '网络导入', 'icon': Icons.cloud_download, 'type': FROM_CLOUD},
    //       {'title': '清空源', 'icon': Icons.delete_forever, 'type': DELETE_ALL_RULES},
    //     ]
    //         .map(
    //           (element) => PopupMenuItem<int>(
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: [
    //                 Text(element['title']),
    //                 Icon(element['icon'], color: primaryColor),
    //               ],
    //             ),
    //             value: element['type'],
    //           ),
    //         )
    //         .toList(),
    //   ),
    // );
  }
}
