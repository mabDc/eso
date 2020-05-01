import 'dart:convert';

import 'package:eso/database/rule.dart';
import 'package:eso/global.dart';
import 'package:eso/page/source/debug_rule_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class EditRulePage extends StatefulWidget {
  @override
  _EditRulePageState createState() => _EditRulePageState();
}

class _EditRulePageState extends State<EditRulePage> {
  var loadFlag = false;
  Rule rule;
  @override
  Widget build(BuildContext context) {
    if (null == rule) {
      rule = Rule.newRule();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('新建规则'),
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => DebugRulePage(rule: rule)));
            },
          ),
          _buildpopupMenu(context),
        ],
      ),
    );
  }

  Future<bool> _saveRule(BuildContext context) async {
    Toast.show("开始保存", context);
    final count = await Global.ruleDao.insertOrUpdateRule(Rule.newRule());
    if (count > 0) {
      Toast.show("保存成功", context);
      return true;
    } else {
      Toast.show("保存失败", context);
      return false;
    }
  }

  Future<bool> _fromClipBoard(BuildContext context) async {
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    rule = Rule.fromJson(jsonDecode(text.text));
    Toast.show("已从剪贴板导入", context);
    return true;
  }

  PopupMenuButton _buildpopupMenu(BuildContext context) {
    const SAVE = 0;
    const FROM_CLIPBOARD = 1;
    const TO_CLIPBOARD = 2;
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
            _fromClipBoard(context);
            break;
          case TO_CLIPBOARD:
            Clipboard.setData(ClipboardData(text: jsonEncode(rule.toJson())));
            Toast.show("已保存到剪贴板", context);
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
      ],
    );
  }
}