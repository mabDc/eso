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
  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;
    if (null == rule) {
      rule = widget.rule ?? Rule.newRule();
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
              await Global.ruleDao.insertOrUpdateRule(rule);
              isLoading = false;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DebugRulePage(rule: rule)));
            },
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
    int maxLines = 1,
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
      initiallyExpanded: true,
      children: [
        _buildDetailsText(
            '创建时间：${DateTime.fromMicrosecondsSinceEpoch(rule.createTime)}'),
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
        _buildEditText(rule.author, '作者(author)', (text) => rule.author = text),
        _buildEditText(rule.name, '名称(name)', (text) => rule.name = text),
        _buildEditText(
          rule.postScript,
          '签名档(post script, p.s.)',
          (text) => rule.postScript = text,
          maxLines: null,
        ),
        _buildEditText(rule.host, '域名(host)', (text) => rule.host = text),
      ],
    );
  }

  Widget _buildDiscover(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("发现规则"),
      initiallyExpanded: rule.enableDiscover,
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
          maxLines: null,
        ),
        _buildEditText(
          rule.discoverList,
          '列表(discoverList)',
          (text) => rule.discoverList = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.discoverName,
          '名称(discoverName)',
          (text) => rule.discoverName = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.discoverAuthor,
          '作者(discoverAuthor)',
          (text) => rule.discoverAuthor = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.discoverCover,
          '封面(discoverCover)',
          (text) => rule.discoverCover = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.discoverChapter,
          '最新章节(discoverChapter)',
          (text) => rule.discoverChapter = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.discoverDescription,
          '简介(discoverDescription)',
          (text) => rule.discoverDescription = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.discoverTags,
          '标签(discoverTags)',
          (text) => rule.discoverTags = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.discoverResult,
          '结果(discoverResult)',
          (text) => rule.discoverResult = text,
          maxLines: null,
        ),
      ],
    );
  }

  Widget _buildSearch(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("搜索规则"),
      initiallyExpanded: rule.enableSearch,
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
          maxLines: null,
        ),
        _buildEditText(
          rule.searchList,
          '列表(searchList)',
          (text) => rule.searchList = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.searchName,
          '名称(searchName)',
          (text) => rule.searchName = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.searchAuthor,
          '作者(searchAuthor)',
          (text) => rule.searchAuthor = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.searchCover,
          '封面(searchCover)',
          (text) => rule.searchCover = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.searchChapter,
          '最新章节(searchChapter)',
          (text) => rule.searchChapter = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.searchDescription,
          '简介(searchDescription)',
          (text) => rule.searchDescription = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.searchTags,
          '标签(searchTags)',
          (text) => rule.searchTags = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.searchResult,
          '结果(searchResult)',
          (text) => rule.searchResult = text,
          maxLines: null,
        ),
      ],
    );
  }

  Widget _buildChapter(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("章节规则"),
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
          maxLines: null,
        ),
        _buildEditText(
          rule.chapterRoads,
          '线路(chapterRoads)',
          (text) => rule.chapterRoads = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.chapterList,
          '章节列表(chapterList)',
          (text) => rule.chapterList = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.chapterName,
          '章节名称(chapterName)',
          (text) => rule.chapterName = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.chapterTime,
          '更新时间(chapterTime)',
          (text) => rule.chapterTime = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.chapterCover,
          '章节封面(chapterCover)',
          (text) => rule.chapterCover = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.chapterLock,
          '章节状态(chapterLock)',
          (text) => rule.chapterLock = text,
          maxLines: null,
        ),
        _buildEditText(
          rule.chapterResult,
          '结果(chapterResult)',
          (text) => rule.chapterResult = text,
          maxLines: null,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return ExpansionTile(
      title: _buildTitle("正文规则"),
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
          maxLines: null,
        ),
        _buildEditText(
          rule.contentItems,
          '内容(contentItems)',
          (text) => rule.contentItems = text,
          maxLines: null,
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

  Future<bool> _loadfromClipBoard(BuildContext context) async {
    if (isLoading) return false;
    isLoading = true;
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    isLoading = false;
    try {
      rule = Rule.fromJson(jsonDecode(text.text));
      Toast.show("已从剪贴板导入", context);
      return true;
    } catch (e) {
      Toast.show("导入失败：" + e.toString(), context, duration: 2);
      return false;
    }
  }

  PopupMenuButton _buildpopupMenu(BuildContext context) {
    const SAVE = 0;
    const FROM_CLIPBOARD = 1;
    const TO_CLIPBOARD = 2;
    const DEBUG_WITHOUT_SAVE = 3;
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
            _loadfromClipBoard(context);
            break;
          case TO_CLIPBOARD:
            Clipboard.setData(ClipboardData(text: jsonEncode(rule.toJson())));
            Toast.show("已保存到剪贴板", context);
            break;
          case DEBUG_WITHOUT_SAVE:
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => DebugRulePage(rule: rule)));
            break;
          default:
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('保存规则'),
              Icon(
                Icons.save,
                color: primaryColor,
              ),
            ],
          ),
          value: SAVE,
        ),
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
              Text('调试且不保存'),
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
