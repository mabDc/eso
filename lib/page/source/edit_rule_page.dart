import 'dart:convert';

import 'package:eso/database/rule.dart';
import 'package:eso/global.dart';
import 'package:eso/page/source/debug_rule_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import '../../api/api.dart';

class EditRulePage extends StatefulWidget {
  final Rule rule;
  const EditRulePage({
    this.rule,
    Key key,
  }) : super(key: key);
  @override
  _EditRulePageState createState() => _EditRulePageState();
}

class _EditRulePageState extends State<EditRulePage> {
  var isLoading = false;
  Color primaryColor;
  Rule rule;
  bool _infoExpanded = true;
  bool _discoverExpanded = true;
  bool _searchExpanded = true;
  bool _chapterExpanded = true;
  bool _contentExpanded = true;
  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;
    if (null == rule) {
      rule = widget.rule ?? Rule.newRule();
      _discoverExpanded = rule.enableDiscover;
      _searchExpanded = rule.enableSearch;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rule == null ? '新建规则' : '编辑规则'),
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () async {
              if (isLoading) return;
              isLoading = true;
              rule.modifiedTime = DateTime.now().microsecondsSinceEpoch;
              await Global.ruleDao.insertOrUpdateRule(rule);
              isLoading = false;
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DebugRulePage(rule: rule)));
            },
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _saveRule(context),
          ),
          _buildpopupMenu(context),
        ],
      ),
      body: ListView(
        children: [
          _buildInfo(context),
          _buildDiscover(context),
          _buildSearch(context),
          _buildChapter(context),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildDetailsText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEditText(
    String text,
    String labelText,
    void Function(String text) onChanged, {
    int minLines = 1,
    int maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        minLines: minLines,
        maxLines: maxLines,
        controller: TextEditingController(text: text),
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTitle(String text) {
    return Text(
      text,
      style: TextStyle(color: primaryColor),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("基本规则"),
      initiallyExpanded: _infoExpanded,
      onExpansionChanged: (value) => _infoExpanded = value,
      children: [
        _buildDetailsText('创建时间：${DateTime.fromMicrosecondsSinceEpoch(rule.createTime)}'),
        _buildDetailsText(
            '修改时间：${DateTime.fromMicrosecondsSinceEpoch(rule.modifiedTime)}'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              _buildDetailsText('类型(contentType)：'),
              DropdownButton<int>(
                isDense: true,
                value: rule.contentType,
                onChanged: (value) {
                  setState(() {
                    rule.contentType = value;
                  });
                },
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem<int>(
                    child: Text(API.getRuleContentTypeName(index)),
                    value: index,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildEditText(
          rule.name,
          '名称(name)',
          (text) => rule.name = text,
          maxLines: 1,
        ),
        _buildEditText(
          rule.host,
          '域名(host)',
          (text) => rule.host = text,
          maxLines: 1,
        ),
        _buildEditText(
          rule.group,
          '分组(group)',
          (text) => rule.group = text,
          maxLines: 1,
        ),
        _buildEditText(
          rule.author,
          '作者(author)',
          (text) => rule.author = text,
          maxLines: 1,
        ),
        _buildEditText(
          rule.postScript,
          '签名档(post script, p.s.)',
          (text) => rule.postScript = text,
        ),
        _buildEditText(
          rule.userAgent,
          '用户代理字符串(userAgent)',
          (text) => rule.userAgent = text,
        ),
        _buildEditText(
          rule.loadJs,
          '加载js内容(loadJs)',
          (text) => rule.loadJs = text,
        ),
      ],
    );
  }

  Widget _buildDiscover(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("发现规则"),
      initiallyExpanded: _discoverExpanded,
      onExpansionChanged: (value) => _discoverExpanded = value,
      children: [
        SwitchListTile(
          title: Text('启用'),
          value: rule.enableDiscover,
          onChanged: (value) {
            setState(() {
              rule.enableDiscover = value;
            });
          },
        ),
        _buildEditText(
          rule.discoverUrl,
          '地址(discoverUrl)',
          (text) => rule.discoverUrl = text,
        ),
        _buildEditText(
          rule.discoverList,
          '列表(discoverList)',
          (text) => rule.discoverList = text,
        ),
        _buildEditText(
          rule.discoverName,
          '名称(discoverName)',
          (text) => rule.discoverName = text,
        ),
        _buildEditText(
          rule.discoverAuthor,
          '作者(discoverAuthor)',
          (text) => rule.discoverAuthor = text,
        ),
        _buildEditText(
          rule.discoverCover,
          '封面(discoverCover)',
          (text) => rule.discoverCover = text,
        ),
        _buildEditText(
          rule.discoverChapter,
          '最新章节(discoverChapter)',
          (text) => rule.discoverChapter = text,
        ),
        _buildEditText(
          rule.discoverDescription,
          '简介(discoverDescription)',
          (text) => rule.discoverDescription = text,
        ),
        _buildEditText(
          rule.discoverTags,
          '标签(discoverTags)',
          (text) => rule.discoverTags = text,
        ),
        _buildEditText(
          rule.discoverResult,
          '结果(discoverResult)',
          (text) => rule.discoverResult = text,
        ),
      ],
    );
  }

  Widget _buildSearch(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("搜索规则"),
      initiallyExpanded: _searchExpanded,
      onExpansionChanged: (value) => _searchExpanded = value,
      children: [
        SwitchListTile(
          title: Text('启用'),
          value: rule.enableSearch,
          onChanged: (value) {
            setState(() {
              rule.enableSearch = value;
            });
          },
        ),
        _buildEditText(
          rule.searchUrl,
          '地址(searchUrl)',
          (text) => rule.searchUrl = text,
        ),
        _buildEditText(
          rule.searchList,
          '列表(searchList)',
          (text) => rule.searchList = text,
        ),
        _buildEditText(
          rule.searchName,
          '名称(searchName)',
          (text) => rule.searchName = text,
        ),
        _buildEditText(
          rule.searchAuthor,
          '作者(searchAuthor)',
          (text) => rule.searchAuthor = text,
        ),
        _buildEditText(
          rule.searchCover,
          '封面(searchCover)',
          (text) => rule.searchCover = text,
        ),
        _buildEditText(
          rule.searchChapter,
          '最新章节(searchChapter)',
          (text) => rule.searchChapter = text,
        ),
        _buildEditText(
          rule.searchDescription,
          '简介(searchDescription)',
          (text) => rule.searchDescription = text,
        ),
        _buildEditText(
          rule.searchTags,
          '标签(searchTags)',
          (text) => rule.searchTags = text,
        ),
        _buildEditText(
          rule.searchResult,
          '结果(searchResult)',
          (text) => rule.searchResult = text,
        ),
      ],
    );
  }

  Widget _buildChapter(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("章节规则"),
      initiallyExpanded: _chapterExpanded,
      onExpansionChanged: (value) => _chapterExpanded = value,
      children: [
        SwitchListTile(
          title: Text('启用多线路'),
          value: rule.enableMultiRoads,
          onChanged: (value) {
            setState(() {
              rule.enableSearch = value;
            });
          },
        ),
        _buildEditText(
          rule.chapterUrl,
          '地址(chapterUrl)',
          (text) => rule.chapterUrl = text,
        ),
        _buildEditText(
          rule.chapterRoads,
          '线路(chapterRoads)',
          (text) => rule.chapterRoads = text,
        ),
        _buildEditText(
          rule.chapterRoadName,
          '线路名称(chapterRoadName)',
          (text) => rule.chapterRoadName = text,
        ),
        _buildEditText(
          rule.chapterList,
          '章节列表(chapterList)',
          (text) => rule.chapterList = text,
        ),
        _buildEditText(
          rule.chapterName,
          '章节名称(chapterName)',
          (text) => rule.chapterName = text,
        ),
        _buildEditText(
          rule.chapterTime,
          '更新时间(chapterTime)',
          (text) => rule.chapterTime = text,
        ),
        _buildEditText(
          rule.chapterCover,
          '章节封面(chapterCover)',
          (text) => rule.chapterCover = text,
        ),
        _buildEditText(
          rule.chapterLock,
          '章节状态(chapterLock)',
          (text) => rule.chapterLock = text,
        ),
        _buildEditText(
          rule.chapterResult,
          '结果(chapterResult)',
          (text) => rule.chapterResult = text,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("正文规则"),
      initiallyExpanded: _contentExpanded,
      onExpansionChanged: (value) => _contentExpanded = value,
      children: [
        SwitchListTile(
          title: Text('启用CryptoJS'),
          value: rule.useCryptoJS,
          onChanged: (value) {
            setState(() {
              rule.enableSearch = value;
            });
          },
        ),
        _buildEditText(
          rule.contentUrl,
          '地址(contentUrl)',
          (text) => rule.contentUrl = text,
        ),
        _buildEditText(
          rule.contentItems,
          '内容(contentItems)',
          (text) => rule.contentItems = text,
        ),
      ],
    );
  }

  Future<bool> _saveRule(BuildContext context) async {
    Toast.show("开始保存", context);
    if (isLoading) return false;
    isLoading = true;
    final count = await Global.ruleDao.insertOrUpdateRule(rule);
    isLoading = false;
    if (count > 0) {
      Toast.show("保存成功", context);
      return true;
    } else {
      Toast.show("保存失败", context);
      return false;
    }
  }

  Future<bool> _loadFromClipBoard(BuildContext context) async {
    if (isLoading) return false;
    isLoading = true;
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    isLoading = false;
    try {
      setState(() {
        rule = Rule.fromJson(jsonDecode(text.text), rule);
      });
      Toast.show("已从剪贴板导入", context);
      return true;
    } catch (e) {
      Toast.show("导入失败：" + e.toString(), context, duration: 2);
      return false;
    }
  }

  Future<bool> _loadFromYICIYUAN(BuildContext context) async {
    if (isLoading) return false;
    isLoading = true;
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    isLoading = false;
    try {
      final json = jsonDecode(text.text);
      if (json is Map) {
        setState(() {
          rule = Rule.fromYiCiYuan(json, rule);
        });
        Toast.show("已从剪贴板导入", context);
        return true;
      } else if (json is List) {
        Toast.show("当前界面只支持单个源导入", context);
      }
    } catch (e) {
      Toast.show("导入失败：" + e.toString(), context, duration: 2);
    }
    return false;
  }

  PopupMenuButton _buildpopupMenu(BuildContext context) {
    const SAVE = 0;
    const FROM_CLIPBOARD = 1;
    const TO_CLIPBOARD = 2;
    const DEBUG_WITHOUT_SAVE = 3;
    const FROM_YICIYUAN = 4;
    final primaryColor = Theme.of(context).primaryColor;
    return PopupMenuButton<int>(
      elevation: 20,
      icon: Icon(Icons.more_vert),
      offset: Offset(0, 40),
      onSelected: (int value) {
        switch (value) {
          case SAVE:
            _saveRule(context);
            break;
          case FROM_CLIPBOARD:
            _loadFromClipBoard(context);
            break;
          case FROM_YICIYUAN:
            _loadFromYICIYUAN(context);
            break;
          case TO_CLIPBOARD:
            Clipboard.setData(ClipboardData(text: jsonEncode(rule.toJson())));
            Toast.show("已保存到剪贴板", context);
            break;
          case DEBUG_WITHOUT_SAVE:
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => DebugRulePage(rule: rule)));
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        // PopupMenuItem(
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: <Widget>[
        //       Text('保存规则'),
        //       Icon(
        //         Icons.save,
        //         color: primaryColor,
        //       ),
        //     ],
        //   ),
        //   value: SAVE,
        // ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('从剪贴板导入'),
              Icon(
                Icons.content_paste,
                color: primaryColor,
              ),
            ],
          ),
          value: FROM_CLIPBOARD,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('从异次元导入'),
              Icon(
                Icons.ac_unit,
                color: primaryColor,
              ),
            ],
          ),
          value: FROM_YICIYUAN,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('导出到剪贴板'),
              Icon(
                Icons.content_copy,
                color: primaryColor,
              ),
            ],
          ),
          value: TO_CLIPBOARD,
        ),
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('调试但不保存'),
              Icon(
                Icons.bug_report,
                color: primaryColor,
              ),
            ],
          ),
          value: DEBUG_WITHOUT_SAVE,
        ),
      ],
    );
  }
}
