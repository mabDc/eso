import 'dart:convert';
import 'dart:ui';

import 'package:eso/api/api_from_rule.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/page/discover_search_page.dart';
import 'package:eso/page/source/edit_source_page.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/ui/edit/search_edit.dart';
import 'package:eso/ui/widgets/keyboard_dismiss_behavior_view.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../global.dart';
import 'source/edit_rule_page.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
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
      value: EditSourceProvider(type: 2),
      builder: (BuildContext context, _) {
        return Scaffold(
          appBar: AppBarEx(
            centerTitle: false,
            title: SearchEdit(
              hintText:
                  "搜索发现站点(共${Provider.of<EditSourceProvider>(context).rules?.length ?? 0}条)",
              onSubmitted: (value) => __provider.getRuleListByName(value),
              onChanged: (value) => __provider.getRuleListByNameDebounce(value),
            ),
            actions: [
              _buildpopupMenu(
                context,
                Provider.of<EditSourceProvider>(context, listen: false),
              ),
              // IconButton(
              //   icon: Icon(Icons.edit),
              //   onPressed: () => Navigator.of(context)
              //       .push(MaterialPageRoute(
              //           builder: (BuildContext context) => EditSourcePage()))
              //       .whenComplete(() => __provider.refreshData()),
              // )
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
              return KeyboardDismissBehaviorView(
                child: ListView.builder(
                  itemCount: provider.rules.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return _buildItem(provider, index);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<bool> _addFromClipBoard(
      BuildContext context, EditSourceProvider provider, bool showEditPage) async {
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    try {
      final rule = Rule.fromJson(jsonDecode(text.text));
      if (provider.rules.any((r) => r.id == rule.id)) {
        await Global.ruleDao.insertOrUpdateRule(rule);
        provider.rules.removeWhere((r) => r.id == rule.id);
        provider.rules.add(rule);
        Toast.show("更新成功", context);
      } else {
        provider.rules.add(rule);
        await Global.ruleDao.insertOrUpdateRule(rule);
        Toast.show("添加成功", context);
      }
      if (showEditPage) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => EditRulePage(rule: rule)))
            .whenComplete(() => provider.refreshData());
      } else {
        provider.refreshData(false);
      }
      return true;
    } catch (e) {
      Toast.show("失败！" + e.toString(), context, duration: 2);
      return false;
    }
  }

  Widget _buildpopupMenu(BuildContext context, EditSourceProvider provider) {
    final popupIconColor = Theme.of(context).primaryColor;
    const list = [
      {'title': '新建空白规则', 'icon': FIcons.code, 'type': ADD_RULE},
      {'title': '从剪贴板新建', 'icon': FIcons.clipboard, 'type': ADD_FROM_CLIPBOARD},
      {'title': '粘贴单条规则', 'icon': FIcons.file, 'type': FROM_CLIPBOARD},
      {'title': '网络导入', 'icon': FIcons.download_cloud, 'type': FROM_CLOUD},
    ];
    return PopupMenuButton<int>(
      elevation: 20,
      icon: Icon(FIcons.plus),
      offset: Offset(0, 40),
      onSelected: (int value) {
        switch (value) {
          case ADD_RULE:
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => EditRulePage()))
                .whenComplete(() => provider.refreshData());
            break;
          case ADD_FROM_CLIPBOARD:
            _addFromClipBoard(context, provider, true);
            break;
          case FROM_CLIPBOARD:
            _addFromClipBoard(context, provider, false);
            break;
          case FROM_CLOUD:
            EditSourcePage.showURLDialog(context, provider.isLoadingUrl, provider, false);
            break;
          default:
        }
      },
      itemBuilder: (context) => list
          .map(
            (element) => PopupMenuItem<int>(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(element['title']),
                  Icon(element['icon'], color: popupIconColor),
                ],
              ),
              value: element['type'],
            ),
          )
          .toList(),
    );
  }

  Widget _buildItem(EditSourceProvider provider, int index) {
    final rule = provider.rules[index];
    Widget _child = ListTile(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DiscoverSearchPage(
            originTag: rule.id,
            origin: rule.name,
            discoverMap: APIFromRUle(rule).discoverMap(),
          ))),
      onLongPress: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => EditRulePage(rule: rule)))
          .whenComplete(() => provider.refreshData()),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Flexible(
            child: Text(
              "${rule.name}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                textBaseline: TextBaseline.alphabetic,
                fontSize: 14,
                height: 1,
              ),
            ),
          ),
          SizedBox(width: 5),
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 0),
            alignment: Alignment.centerLeft,
            child: Text(
              '${rule.ruleTypeName}',
              style: TextStyle(
                fontSize: 10,
                height: 1.4,
                color: Colors.white,
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        '${rule.host}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    if (index < provider.rules.length - 1)
      return _child;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _child,
        SizedBox(height: 30)
      ],
    );
  }
}
