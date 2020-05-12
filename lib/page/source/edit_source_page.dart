import 'dart:convert';
import 'dart:ui';

import 'package:eso/api/api_form_rule.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/global.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/page/source/edit_rule_page.dart';
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
            hintText: "搜索名称和分组",
            hintStyle: TextStyle(
              color: Colors.white70,
            ),
            isDense: true,
            contentPadding: EdgeInsets.only(bottom: 4),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Icon(
                Icons.search,
                color: Colors.white70,
              ),
            ),
            prefixIconConstraints: BoxConstraints(),
          ),
          maxLines: 1,
          style: TextStyle(color: Colors.white, height: 1.25),
          textAlignVertical: TextAlignVertical.bottom,
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
      body: ChangeNotifierProvider.value(
        value: EditSourceProvider(),
        child: Consumer<EditSourceProvider>(
          builder: (context, EditSourceProvider provider, _) {
            if (__provider == null) {
              __provider = provider;
            }
            if (provider.isLoading) {
              return LandingPage();
            }
            return ListView.separated(
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemCount: provider.rules.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return _buildItem(provider, index);
              },
            );
          },
        ),
      ),
    );
  }

  bool _isloadFromYiciYuan = false;

  Future<void> fromYiciYuan(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "输入源地址, 回车开始导入",
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          enabled: !_isloadFromYiciYuan,
          onSubmitted: (url) async {
            setState(() {
              _isloadFromYiciYuan = true;
            });
            url = url.trim();
            Toast.show("输入的地址为$url", context);
            try {
              final res = await http.get("$url");
              final json = jsonDecode(utf8.decode(res.bodyBytes));
              if (json is Map) {
                await Global.ruleDao
                    .insertOrUpdateRule(Rule.fromYiCiYuan(json));
              } else if (json is List) {
                await Global.ruleDao.insertOrUpdateRules(
                    json.map((rule) => Rule.fromYiCiYuan(rule)).toList());
              }
            } catch (e) {
              Toast.show("$e", context);
            }
            _isloadFromYiciYuan = false;
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
            Toast.show("从网络导入", context);
            break;
          case EditSourceProvider.FROM_YICIYUAN:
            fromYiciYuan(context);
            break;
          case EditSourceProvider.DELETE_ALL_RULES:
            showDialog<Null>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("警告"),
                    content: Text("是否删除所有站点？"),
                    actions: [
                      FlatButton(
                        child: Text(
                          "确定",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () => __provider.deleteAllRules(),
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
                Icon(
                  element['icon'],
                  color: primaryColor,
                ),
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
          subtitle: Text('${rule.host}'),
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
              .push(MaterialPageRoute(
                  builder: (context) => EditRulePage(rule: rule)))
              .then((value) => provider.refreshData()),
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
