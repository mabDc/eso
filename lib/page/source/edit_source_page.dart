import 'dart:ui';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_from_rule.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/rule_dao.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/page/source/add_rule_dialog.dart';
import 'package:eso/page/source/edit_rule_page.dart';
import 'package:eso/ui/edit/search_edit.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../fonticons_icons.dart';
import '../../global.dart';
import '../discover_search_page.dart';

class EditSourcePage extends StatefulWidget {
  const EditSourcePage({Key key}) : super(key: key);

  @override
  _EditSourcePageState createState() => _EditSourcePageState();

  static void showDeleteAllDialog(BuildContext context, EditSourceProvider provider) {
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
                "取消",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
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
          ],
        );
      },
    );
  }
}

class _EditSourcePageState extends State<EditSourcePage> {
  final SlidableController slidableController = SlidableController();
  TextEditingController _searchEdit = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditSourceProvider>(
      create: (context) => EditSourceProvider(),
      builder: (context, child) {
        final provider = Provider.of<EditSourceProvider>(context, listen: false);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0.0,
            title: SearchEdit(
              controller: _searchEdit,
              hintText:
                  "搜索名称和分组(共${context.select((EditSourceProvider provider) => provider.rules)?.length ?? 0}条)",
              onSubmitted: Provider.of<EditSourceProvider>(context, listen: false)
                  .getRuleListByName,
              onChanged: Provider.of<EditSourceProvider>(context, listen: false)
                  .getRuleListByNameDebounce,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                tooltip: '新增规则',
                onPressed: () => addRuleDialog(context, () => refreshData(provider)),
              ),
              IconButton(
                icon: Icon(FIcons.x_circle),
                tooltip: '清空规则',
                onPressed: () => EditSourcePage.showDeleteAllDialog(context, provider),
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
                              fontSize: 12, color: Theme.of(context).primaryColor),
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
                          style: TextStyle(fontSize: 12),
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
                separatorBuilder: (BuildContext context, int index) => Container(),
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
    return ListTile(
      onTap: () => provider.toggleEnableSearch(rule),
      contentPadding: EdgeInsets.symmetric(horizontal: 12),
      leading: Container(
        height: 36,
        width: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _leadColor,
          shape: BoxShape.circle,
          border: _leadBorder,
        ),
        child: Text(
          rule.ruleTypeName,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: Profile.staticFontFamily,
              color: Global.lightness(_leadColor) > 180
                  ? _theme.primaryColorDark
                  : Colors.white),
        ),
      ),
      dense: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
              child: Text('${rule.name}', style: TextStyle(fontWeight: FontWeight.bold))),
          IconButton(
              tooltip: "编辑",
              icon: Icon(FIcons.edit_3, size: 20),
              constraints: const BoxConstraints(maxWidth: 26, maxHeight: 26),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => EditRulePage(rule: rule)))
                  .whenComplete(() => refreshData(provider))),
          IconButton(
            tooltip: "置顶",
            icon: Icon(OMIcons.arrowUpward, size: 20),
            constraints: const BoxConstraints(maxWidth: 26, maxHeight: 26),
            onPressed: () => provider.setSortMax(rule),
          ),
          IconButton(
              tooltip: "删除",
              icon: Icon(OMIcons.deleteSweep, size: 20),
              constraints: const BoxConstraints(maxWidth: 26, maxHeight: 26),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("警告"),
                        content: Text("确认删除 ${rule.name}"),
                        actions: [
                          FlatButton(
                            child: Text(
                              "取消",
                              style: TextStyle(color: Theme.of(context).hintColor),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          FlatButton(
                            child: Text(
                              "确定",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              provider.deleteRule(rule);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              }),
        ],
      ),
      subtitle: Wrap(
        spacing: 6,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                rule.enableSearch ? FIcons.check_square : FIcons.square,
                size: 10,
                color: rule.enableSearch ? _theme.primaryColor : Colors.grey,
              ),
              Text(
                "搜索",
                style: TextStyle(
                  fontSize: 10,
                  height: 1.2,
                  color: rule.enableSearch ? _theme.primaryColor : Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                rule.enableDiscover ? FIcons.check_circle : FIcons.circle,
                size: 10,
                color: rule.enableDiscover ? _theme.primaryColor : Colors.grey,
              ),
              Text(
                "发现",
                style: TextStyle(
                  fontSize: 10,
                  height: 1.2,
                  color: rule.enableDiscover ? _theme.primaryColor : Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          if (rule.author != null && rule.author.isNotEmpty)
            Text(
              '@${rule.author}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                height: 1.2,
              ),
            ),
          if (rule.host != null && rule.host.isNotEmpty)
            Text(
              '${cleanHost.firstMatch(rule.host)?.group(1) ?? ""}',
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 10,
                height: 1.2,
                color: Colors.blueAccent,
                decoration: TextDecoration.underline,
              ),
            ),
        ],
      ),
      onLongPress: () => Navigator.of(context).push(MaterialPageRoute(
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
      )),
    );
  }

  refreshData(EditSourceProvider provider) {
    if (Utils.empty(_searchEdit?.text))
      provider.refreshData();
    else
      provider.getRuleListByName(_searchEdit.text);
  }
}
