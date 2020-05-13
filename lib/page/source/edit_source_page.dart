import 'dart:convert';
import 'dart:ui';

import 'package:eso/api/api_form_rule.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/global.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/page/source/edit_rule_page.dart';
import 'package:eso/ui/ui_dash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;

import '../discover_search_page.dart';

//图源编辑
class EditSourcePage extends StatefulWidget {
  @override
  _EditSourcePageState createState() => _EditSourcePageState();
}

class _EditSourcePageState extends State<EditSourcePage> {
  Widget _page;
  EditSourceProvider __provider;

  @override
  void dispose() {
    __provider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_page == null) {
      _page = _buildPage();
    }
    return _page;
  }

  Widget _buildPage() {
    return ChangeNotifierProvider.value(
      value: EditSourceProvider(),
      builder: (BuildContext context, _) {
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              cursorColor: Theme.of(context).primaryColor,
              cursorRadius: Radius.circular(2),
              selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
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
                    "搜索名称和分组(共${Provider.of<EditSourceProvider>(context).rules?.length ?? 0}条)",
                hintStyle: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 4),
                prefixIcon: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),
                ),
                prefixIconConstraints: BoxConstraints(),
              ),
              maxLines: 1,
              style: TextStyle(color: Colors.white, height: 1.25),
              onSubmitted: (content) {
                __provider.getRuleListByName(content);
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.check_circle),
                onPressed: () {
                  __provider.toggleCheckAllRule();
                },
              ),
              _buildpopupMenu(context),
            ],
          ),
          body: Consumer<EditSourceProvider>(
            builder: (context, EditSourceProvider provider, _) {
              if (__provider == null) {
                __provider = provider;
              }
              if (provider.isLoading) {
                return LandingPage();
              }
              return ListView.separated(
                separatorBuilder: (BuildContext context, int index) => UIDash(
                  color: Colors.black54,
                  height: 0.5,
                  dashWidth: 5,
                ),
                itemCount: provider.rules.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return _buildItem(provider, index);
                },
              );
            },
          ),
        );
      },
    );
  }

  bool _isload = false;
  Future<void> fromURL(BuildContext context, {type = 'json'}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "输入源地址, 回车开始导入",
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          enabled: !_isload,
          onSubmitted: (url) async {
            setState(() {
              _isload = true;
            });
            url = url.trim();
            Toast.show("输入的地址为$url", context);
            try {
              final res = await http.get("$url");
              final json = jsonDecode(utf8.decode(res.bodyBytes));
              if (json is Map) {
                await Global.ruleDao.insertOrUpdateRule(type.contains('json')
                    ? Rule.fromJson(json)
                    : Rule.fromYiCiYuan(json));
              } else if (json is List) {
                await Global.ruleDao.insertOrUpdateRules(json
                    .map((rule) => type.contains('json')
                        ? Rule.fromJson(rule)
                        : Rule.fromYiCiYuan(rule))
                    .toList());
              }
            } catch (e) {
              Toast.show("$e", context);
            }
            _isload = false;
            Navigator.pop(context);
            __provider.refreshData();
          },
        ),
      ),
    );
  }

  PopupMenuButton _buildpopupMenu(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return PopupMenuButton<int>(
      elevation: 20,
      icon: Icon(Icons.add),
      offset: Offset(0, 40),
      onSelected: (int value) {
        switch (value) {
          case EditSourceProvider.ADD_RULE:
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => EditRulePage()))
                .then((value) => __provider.refreshData());
            break;
          case EditSourceProvider.FROM_FILE:
            Toast.show("从本地文件导入", context);
            break;
          case EditSourceProvider.FROM_CLOUD:
            fromURL(context);
            break;
          case EditSourceProvider.FROM_YICIYUAN:
            fromURL(context, type: 'YiCiYuan');
            break;
          case EditSourceProvider.DELETE_ALL_RULES:
            showDialog<Null>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.black),
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
                          __provider.deleteAllRules();
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
                });
            break;
          default:
        }
      },
      itemBuilder: (context) {
        List<PopupMenuEntry<int>> menuList = [];
        __provider.getMenuList().forEach((element) {
          menuList.add(PopupMenuItem(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(element['title']),
                Icon(element['icon'], color: primaryColor),
              ],
            ),
            value: element['type'],
          ));
        });
        return menuList;
      },
    );
  }

  Widget _buildItem(EditSourceProvider provider, int index) {
    final rule = provider.rules[index];
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
        IconSlideAction(
          caption: '进入',
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
              .push(MaterialPageRoute(
                  builder: (context) => EditRulePage(rule: rule)))
              .then((value) => provider.refreshView()),
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
}
