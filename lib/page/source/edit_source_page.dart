import 'dart:ui';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_from_rule.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/rule_dao.dart';
import 'package:eso/menu/menu.dart';
import 'package:eso/menu/menu_edit_source.dart';
import 'package:eso/menu/menu_item.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/profile.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/ui/ui_add_rule_dialog.dart';
import 'package:eso/page/source/edit_rule_page.dart';
import 'package:eso/ui/ui_text_field.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

import '../../fonticons_icons.dart';
import '../../global.dart';
import '../discover_search_page.dart';

class EditSourcePage extends StatefulWidget {
  const EditSourcePage({Key key}) : super(key: key);

  @override
  _EditSourcePageState createState() => _EditSourcePageState();
}

class _EditSourcePageState extends State<EditSourcePage> {
  TextEditingController _searchEdit = TextEditingController();
  String group;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditSourceProvider>(
      create: (context) => EditSourceProvider(),
      builder: (context, child) {
        final provider = Provider.of<EditSourceProvider>(context, listen: true);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0.0,
            title: SearchTextField(
              controller: _searchEdit,
              hintText:
                  "搜索名称和分组(共${Provider.of<EditSourceProvider>(context, listen: false)?.rules?.length ?? 0}条)",
              onSubmitted: Provider.of<EditSourceProvider>(context, listen: false)
                  .getRuleListByName,
              onChanged: Provider.of<EditSourceProvider>(context, listen: false)
                  .getRuleListByNameDebounce,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                tooltip: '添加规则',
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) =>
                      UIAddRuleDialog(refresh: () => refreshData(provider)),
                ),
              ),
              IconButton(
                icon: Icon(OMIcons.settingsEthernet),
                tooltip: '新建空白规则',
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => EditRulePage()))
                    .whenComplete(() => refreshData(provider)),
              ),
              Menu<MenuEditSource>(
                tooltip: "编辑选中规则",
                items: editSourceMenus,
                onSelect: (value) {
                  if (value == null) return;
                  final rules = provider.rules
                      .where((element) => provider.checkSelectMap[element.id] == true)
                      .toList();
                  if (value != MenuEditSource.all &&
                      value != MenuEditSource.revert &&
                      rules.isEmpty) {
                    Utils.toast("请先选择规则");
                    return;
                  }
                  if (value == MenuEditSource.delete) {
                    alert(
                      Text("警告(不可恢复)"),
                      Text("删除选中${rules.length}条规则"),
                      () => provider.handleSelect(rules, value),
                    );
                  } else if (value == MenuEditSource.add_group ||
                      value == MenuEditSource.delete_group) {
                    group = "";
                    alert(
                      value == MenuEditSource.add_group ? Text('添加分组') : Text('移除分组'),
                      TextField(onChanged: (value) => group = value),
                      () => provider.handleSelect(rules, value, group),
                    );
                  } else {
                    provider.handleSelect(rules, value);
                  }
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var sort in RuleDao.sortMap.entries)
                    if (sort.value == RuleDao.sortName)
                      InkWell(
                        child: Text(
                          " ${sort.key}${(RuleDao.sortOrder == RuleDao.desc ? "⇓" : "⇑")}",
                          style: TextStyle(
                              fontSize: 14, color: Theme.of(context).primaryColor),
                        ),
                        onTap: () {
                          if (RuleDao.sortOrder == RuleDao.desc) {
                            RuleDao.sortOrder = RuleDao.asc;
                          } else {
                            RuleDao.sortOrder = RuleDao.desc;
                          }
                          Provider.of<EditSourceProvider>(context, listen: false)
                              .refreshData();
                        },
                      )
                    else
                      InkWell(
                        child: Text(
                          " ${sort.key} ",
                          style: TextStyle(fontSize: 14),
                        ),
                        onTap: () {
                          RuleDao.sortName = sort.value;
                          Provider.of<EditSourceProvider>(context, listen: false)
                              .refreshData();
                        },
                      )
                ],
              ),
            ),
          ),
          body: Consumer<EditSourceProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return LandingPage();
              }
              return ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Divider(),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
                itemCount: provider.rules.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return _buildItem(context, provider, provider.rules[index]);
                },
              );
            },
          ),
        );
      },
    );
  }

  final cleanHost = RegExp(r"(?:\s*https?://(?:www.|m.)?)([^/:]*)");

  void alert(Widget title, Widget content, VoidCallback handle) => showDialog(
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

  void preview(Rule rule) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FutureBuilder<List<DiscoverMap>>(
            future: APIFromRUle(rule).discoverMap(),
            initialData: null,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Scaffold(
                  body: Text("error: ${snapshot.error}"),
                );
              }
              if (!snapshot.hasData) {
                return LandingPage();
              }
              return DiscoverSearchPage(
                rule: rule,
                originTag: rule.id,
                origin: rule.name,
                discoverMap: snapshot.data,
              );
            },
          ),
        ),
      );

  Widget _buildItem(BuildContext context, EditSourceProvider provider, Rule rule) {
    final _theme = Theme.of(context);
    final _leadColor = () {
      switch (rule.contentType) {
        case API.MANGA:
          return _theme.primaryColorLight;
        case API.VIDEO:
          return _theme.primaryColor;
        case API.AUDIO:
          return _theme.primaryColorDark;
        default:
          return Colors.white;
      }
    }();
    final _leadBorder = rule.contentType == API.NOVEL
        ? Border.all(color: _theme.primaryColor, width: 1.0)
        : null;
    return InkWell(
      onTap: () => provider.toggleSelect(rule.id),
      onLongPress: () => preview(rule),
      child: Row(
        children: [
          Checkbox(
            value: provider.checkSelectMap[rule.id] ?? false,
            onChanged: (value) => provider.toggleSelect(rule.id, value),
          ),
          SizedBox(width: 8),
          Container(
            height: 28,
            width: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _leadColor,
              shape: BoxShape.circle,
              border: _leadBorder,
            ),
            child: Text(
              rule.ruleTypeName,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: Profile.staticFontFamily,
                  color: Global.lightness(_leadColor) > 180
                      ? _theme.primaryColorDark
                      : Colors.white),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${rule.name}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                  maxLines: 1,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      rule.enableSearch ? FIcons.check_square : FIcons.square,
                      size: 10,
                      color: rule.enableSearch ? _theme.primaryColor : Colors.grey,
                    ),
                    Text(
                      "搜索",
                      style: TextStyle(
                        fontSize: 12,
                        color: rule.enableSearch ? _theme.primaryColor : Colors.grey,
                        // decoration: TextDecoration.underline,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      rule.enableDiscover ? FIcons.check_circle : FIcons.circle,
                      size: 10,
                      color: rule.enableDiscover ? _theme.primaryColor : Colors.grey,
                    ),
                    Text(
                      "发现",
                      style: TextStyle(
                        fontSize: 12,
                        color: rule.enableDiscover ? _theme.primaryColor : Colors.grey,
                        // decoration: TextDecoration.underline,
                      ),
                    ),
                    if (rule.author != null && rule.author.isNotEmpty)
                      Text(
                        ' @${rule.author}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                    if (rule.host != null && rule.host.isNotEmpty) SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${cleanHost.firstMatch(rule.host)?.group(1) ?? ""}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
              tooltip: "编辑",
              icon: Icon(OMIcons.settingsEthernet),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => EditRulePage(rule: rule)))
                  .whenComplete(() => refreshData(provider))),
          Menu<MenuEditSource>(
            tooltip: "选项",
            items: [
              rule.enableSearch
                  ? MenuItem(
                      text: '搜索',
                      icon: OMIcons.toggleOn,
                      color: Global.primaryColor,
                      value: MenuEditSource.disable_search,
                    )
                  : MenuItem(
                      text: '搜索',
                      icon: OMIcons.toggleOff,
                      color: Colors.grey,
                      value: MenuEditSource.enable_search,
                    ),
              rule.enableDiscover
                  ? MenuItem(
                      text: '发现',
                      icon: OMIcons.toggleOn,
                      color: Global.primaryColor,
                      value: MenuEditSource.disable_discover,
                    )
                  : MenuItem(
                      text: '发现',
                      icon: OMIcons.toggleOff,
                      color: Colors.grey,
                      value: MenuEditSource.enable_discover,
                    ),
              MenuItem(
                text: '置顶',
                icon: OMIcons.arrowUpward,
                value: MenuEditSource.top,
                color: Global.primaryColor,
              ),
              MenuItem(
                text: '预览',
                icon: OMIcons.category,
                value: MenuEditSource.preview,
                color: Global.primaryColor,
              ),
              MenuItem(
                text: '删除',
                icon: OMIcons.deleteSweep,
                value: MenuEditSource.delete_this,
                color: Global.primaryColor,
              ),
            ],
            onSelect: (value) {
              if (value == MenuEditSource.delete_this) {
                alert(
                  Text("警告(不可恢复)"),
                  Text("删除选中${rule.name}条规则"),
                  () => provider.handleSelect([rule], value),
                );
              } else if (value == MenuEditSource.preview) {
                preview(rule);
              } else {
                provider.handleSelect([rule], value);
              }
            },
          ),
        ],
      ),
    );
  }

  refreshData(EditSourceProvider provider) {
    if (Utils.empty(_searchEdit?.text))
      provider.refreshData();
    else
      provider.getRuleListByName(_searchEdit.text);
  }
}
