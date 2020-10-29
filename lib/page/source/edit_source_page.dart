import 'dart:convert';
import 'dart:ui';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_from_rule.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/rule_dao.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/model/profile.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/page/source/edit_rule_page.dart';
import 'package:eso/ui/edit/bottom_input_border.dart';
import 'package:eso/ui/edit/edit_view.dart';
import 'package:eso/ui/edit/search_edit.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/rule_comparess.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../fonticons_icons.dart';
import '../../global.dart';
import '../discover_search_page.dart';

const int ADD_RULE = 0;
const int ADD_FROM_CLIPBOARD = 1;
const int FROM_FILE = 2;
const int FROM_CLOUD = 3;
const int FROM_YICIYUAN = 4;
const int DELETE_ALL_RULES = 5;
const int FROM_CLIPBOARD = 6;
const int FROM_EDIT_SOURCE = 7;

/// 规则管理页
class EditSourcePage extends StatefulWidget {
  const EditSourcePage({Key key}) : super(key: key);

  @override
  _EditSourcePageState createState() => _EditSourcePageState();

  static void showURLDialog(
    BuildContext context,
    bool isLoadingUrl,
    EditSourceProvider provider,
    bool isYICIYUAN,
  ) async {
    var onSubmitted = (url) async {
      Utils.toast("开始导入$url", duration: Duration(seconds: 1));
      final count = await provider.addFromUrl(url.trim(), isYICIYUAN);
      Utils.toast("导入完成，一共$count条", duration: Duration(seconds: 1));
      Navigator.pop(context);
    };
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Theme.of(context).canvasColor,
        title: Text("网络导入"),
        content: EditView(
          autofocus: true,
          controller: _controller,
          hint: "输入源地址, 回车开始导入",
          border: BottomInputBorder(Theme.of(context).dividerColor),
          enabled: !isLoadingUrl,
          onSubmitted: (url) => onSubmitted(url),
        ),
        actions: <Widget>[
          FlatButton(
              child: Text('取消', style: TextStyle(color: Theme.of(context).hintColor)),
              onPressed: () => Navigator.pop(context)),
          FlatButton(child: Text('确定'), onPressed: () => onSubmitted(_controller.text)),
        ],
      ),
    );
  }

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
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          title: SearchEdit(
            controller: _searchEdit,
            hintText:
                "搜索名称和分组(共${context.select((EditSourceProvider provider) => provider.rules)?.length ?? 0}条)",
            onSubmitted:
                Provider.of<EditSourceProvider>(context, listen: false).getRuleListByName,
            onChanged: Provider.of<EditSourceProvider>(context, listen: false)
                .getRuleListByNameDebounce,
          ),
          actions: [
            IconButton(
              icon: Icon(
                FIcons.check_square,
                size: 20,
              ),
              tooltip: "启用搜索",
              constraints: BoxConstraints(maxWidth: 30),
              onPressed: Provider.of<EditSourceProvider>(context, listen: false)
                  .toggleCheckAllRule,
            ),
            IconButton(
              icon: Icon(
                FIcons.check_circle,
                size: 20,
              ),
              tooltip: "启用发现",
              constraints: BoxConstraints(maxWidth: 30),
              onPressed: Provider.of<EditSourceProvider>(context, listen: false)
                  .toggleCheckAllRuleDiscover,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 32),
              child: _buildpopupMenu(
                context,
                context.select((EditSourceProvider provider) => provider.isLoadingUrl),
                Provider.of<EditSourceProvider>(context, listen: false),
              ),
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
      ),
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
                decoration: TextDecoration.underline,
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

  Future<bool> _addFromClipBoard(
      BuildContext context, EditSourceProvider provider, bool showEditPage) async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain)).text.trim();
    try {
      if (text.startsWith('http')) {
        Utils.toast("开始导入$text", duration: Duration(seconds: 1));
        final count = await provider.addFromUrl(text.trim(), false);
        Utils.toast("导入完成，一共$count条", duration: Duration(seconds: 1));
        return true;
      }
      final rule = text.startsWith(RuleCompress.tag)
          ? RuleCompress.decompass(text)
          : Rule.fromJson(jsonDecode(text));
      if (provider.rules.any((r) => r.id == rule.id)) {
        await Global.ruleDao.insertOrUpdateRule(rule);
        provider.rules.removeWhere((r) => r.id == rule.id);
        provider.rules.add(rule);
        Utils.toast("更新成功");
      } else {
        provider.rules.add(rule);
        await Global.ruleDao.insertOrUpdateRule(rule);
        Utils.toast("添加成功");
      }
      if (showEditPage) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => EditRulePage(rule: rule)))
            .whenComplete(() => refreshData(provider));
      } else {
        provider.refreshData(false);
      }
      return true;
    } catch (e) {
      Utils.toast("失败！" + e.toString(), duration: Duration(seconds: 2));
      return false;
    }
  }

  Widget _buildpopupMenu(
      BuildContext context, bool isLoadingUrl, EditSourceProvider provider) {
    final primaryColor = Theme.of(context).primaryColor;
    const list = [
      {'title': '新建空白规则', 'icon': FIcons.code, 'type': ADD_RULE},
      {'title': '从剪贴板新建', 'icon': FIcons.clipboard, 'type': ADD_FROM_CLIPBOARD},
      {'title': '从剪贴板导入', 'icon': FIcons.file, 'type': FROM_CLIPBOARD},
      // {'title': '文件导入', 'icon': Icons.file_download, 'type': FROM_FILE},
      {'title': '网络导入', 'icon': FIcons.download_cloud, 'type': FROM_CLOUD},
      // {'title': '阅读或异次元', 'icon': Icons.cloud_queue, 'type': FROM_YICIYUAN},
      {'title': '清空源', 'icon': FIcons.x_circle, 'type': DELETE_ALL_RULES},
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
                .whenComplete(() => refreshData(provider));
            break;
          case ADD_FROM_CLIPBOARD:
            _addFromClipBoard(context, provider, true);
            break;
          case FROM_CLIPBOARD:
            _addFromClipBoard(context, provider, false);
            break;
          case FROM_FILE:
            Utils.toast("从本地文件导入");
            break;
          case FROM_CLOUD:
            EditSourcePage.showURLDialog(context, isLoadingUrl, provider, false);
            break;
          case FROM_YICIYUAN:
            EditSourcePage.showURLDialog(context, isLoadingUrl, provider, true);
            break;
          case DELETE_ALL_RULES:
            EditSourcePage.showDeleteAllDialog(context, provider);
            break;
          default:
        }
      },
      itemBuilder: (context) => list.map(
        (element) {
          return PopupMenuItem<int>(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(element['title']),
                Icon(element['icon'], color: primaryColor),
              ],
            ),
            value: element['type'],
          );
        },
      ).toList(),
    );
  }

  refreshData(EditSourceProvider provider) {
    if (Utils.empty(_searchEdit?.text))
      provider.refreshData();
    else
      provider.getRuleListByName(_searchEdit.text);
  }
}
