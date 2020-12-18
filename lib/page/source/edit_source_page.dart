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
import 'package:eso/ui/search_edit.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
}

class _EditSourcePageState extends State<EditSourcePage> {
  final SlidableController slidableController = SlidableController();
  TextEditingController _searchEdit = TextEditingController();

  buildPopupMenuItem(int value, String text, IconData icon, [bool color]) {
    final primaryColor = Theme.of(context).primaryColor;
    return PopupMenuItem<int>(
      height: 35,
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: color == null
                ? null
                : color
                    ? primaryColor
                    : Colors.grey,
            size: 16,
          ),
          SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditSourceProvider>(
      create: (context) => EditSourceProvider(),
      builder: (context, child) {
        final provider = Provider.of<EditSourceProvider>(context, listen: true);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0.0,
            title: SearchEdit(
              controller: _searchEdit,
              hintText: "搜索名称和分组",
              onSubmitted: Provider.of<EditSourceProvider>(context, listen: false)
                  .getRuleListByName,
              onChanged: Provider.of<EditSourceProvider>(context, listen: false)
                  .getRuleListByNameDebounce,
            ),
            actions: [
              IconButton(
                icon: Icon(OMIcons.settingsEthernet),
                tooltip: '编辑空白规则',
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => EditRulePage()))
                    .whenComplete(() => refreshData(provider)),
              ),
              IconButton(
                icon: Icon(Icons.add),
                tooltip: '添加规则',
                onPressed: () => addRuleDialog(context, () => refreshData(provider)),
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
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (BuildContext context, int index) => Divider(),
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.rules.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return _buildItem(context, provider, provider.rules[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_box_outline_blank),
                        Text('全选(0/${provider.rules.length})'),
                        Spacer(),
                        OutlineButton(child: Text('反选'), onPressed: null),
                        SizedBox(width: 4),
                        OutlineButton(child: Text('删除'), onPressed: null),
                        PopupMenuButton<int>(
                          tooltip: "更多",
                          icon: Icon(OMIcons.moreVert),
                          offset: Offset(0, -260),
                          padding: EdgeInsets.only(),
                          onSelected: (value) {
                            switch (value) {
                              case ENABLE_SEARCH:
                                break;
                              default:
                            }
                          },
                          itemBuilder: (context) => [
                            buildPopupMenuItem(
                                ENABLE_SEARCH, '启用搜索', FIcons.check_square, true),
                            buildPopupMenuItem(
                                DISABLE_SEARCH, '禁用搜索', FIcons.square, false),
                            buildPopupMenuItem(
                                ENABLE_DISCOVER, '启用发现', FIcons.check_circle, true),
                            buildPopupMenuItem(
                                DISABLE_DISCOVER, '禁用发现', FIcons.circle, false),
                            buildPopupMenuItem(ADD_GROUP, '添加分组', OMIcons.addToPhotos),
                            buildPopupMenuItem(DELETE_GROUP, '移除分组', OMIcons.adjust),
                            buildPopupMenuItem(SET_TOP, '置顶所选', OMIcons.arrowUpward),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
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
    return InkWell(
      onTap: () => Utils.toast('点击选择未实现, 长按可以预览发现'),
      onLongPress: () => Navigator.of(context).push(
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
      ),
      child: Row(
        children: [
          Icon(OMIcons.checkBoxOutlineBlank, color: Colors.grey, size: 20),
          SizedBox(width: 4),
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
          SizedBox(width: 4),
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
          PopupMenuButton<int>(
            tooltip: "选项",
            icon: Icon(OMIcons.editAttributes),
            offset: Offset(0, 20),
            padding: EdgeInsets.only(),
            onSelected: (value) {
              switch (value) {
                case ENABLE_SEARCH:
                  provider.toggleEnableSearch(rule, ENABLE_SEARCH);
                  break;
                case DISABLE_SEARCH:
                  provider.toggleEnableSearch(rule, DISABLE_SEARCH);
                  break;
                case ENABLE_DISCOVER:
                  provider.toggleEnableSearch(rule, ENABLE_DISCOVER);
                  break;
                case DISABLE_DISCOVER:
                  provider.toggleEnableSearch(rule, DISABLE_DISCOVER);
                  break;
                case SET_TOP:
                  provider.setSortMax(rule);
                  break;
                case DELETE:
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("警告(不可恢复)"),
                          content: Text("删除 ${rule.name}"),
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
                  break;
                default:
              }
            },
            itemBuilder: (context) => [
              rule.enableSearch
                  ? buildPopupMenuItem(DISABLE_SEARCH, '禁用搜索', FIcons.square, false)
                  : buildPopupMenuItem(ENABLE_SEARCH, '启用搜索', FIcons.check_square, true),
              rule.enableDiscover
                  ? buildPopupMenuItem(DISABLE_DISCOVER, '禁用发现', FIcons.circle, false)
                  : buildPopupMenuItem(
                      ENABLE_DISCOVER, '启用发现', FIcons.check_circle, true),
              buildPopupMenuItem(SET_TOP, '置顶', OMIcons.arrowUpward),
              buildPopupMenuItem(DELETE, '删除', OMIcons.deleteSweep),
            ],
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
