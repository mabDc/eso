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
  Rule rule;
  @override
  Widget build(BuildContext context) {
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

  Text _buildBigText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 20,
      ),
    );
  }

  Widget _buildDetailsText(String text) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: Container(
        height: 40,
        margin: EdgeInsets.only(bottom: 5, left: 12),
        //decoration: BoxDecoration(color: Colors.grey),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
    return FractionallySizedBox(
      widthFactor: 1,
      child: Container(
        height: 40,
        margin: EdgeInsets.only(bottom: 5, left: 12),
        // decoration: BoxDecoration(color: Colors.grey),
        child: TextField(
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          controller: TextEditingController(text: text),
          minLines: minLines,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: labelText,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return ExpansionTile(
      title: _buildBigText("规则信息"),
      tilePadding: EdgeInsets.symmetric(horizontal: 16),
      initiallyExpanded: true,
      children: [
        _buildDetailsText(
            '创建时间：${DateTime.fromMicrosecondsSinceEpoch(rule.createTime)}'),
        _buildDetailsText(
            '修改时间：${DateTime.fromMicrosecondsSinceEpoch(rule.modifiedTime)}'),
        _buildEditText(rule.author, '作者(author)', (text) => rule.author = text),
        _buildEditText(rule.name, '名称(name)', (text) => rule.name = text),
        _buildEditText(rule.host, '域名(host)', (text) => rule.host = text),
        _buildDetailsText('类型(contentType)：'),
        DropdownButton<int>(
          isDense: true,
          underline: Container(),
          value: rule.contentType,
          onChanged: (value) => rule.contentType = value,
          items: List.generate(
            5,
            (index) => DropdownMenuItem<int>(
              child: Text(API.getRuleContentTypeName(index)),
              value: index,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiscover(BuildContext context) {
    return ExpansionTile(
      title: _buildBigText("发现规则"),
      children: [],
    );
  }

  Widget _buildSearch(BuildContext context) {
    return ExpansionTile(
      title: _buildBigText("搜索规则"),
      children: [],
    );
  }

  Widget _buildChapter(BuildContext context) {
    return ExpansionTile(
      title: _buildBigText("章节规则"),
      children: [],
    );
  }

  Widget _buildContent(BuildContext context) {
    return ExpansionTile(
      title: _buildBigText("正文规则"),
      children: [],
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
