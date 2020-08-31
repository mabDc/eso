/*
 * @Author: your name
 * @Date: 2020-07-08 21:57:29
 * @LastEditTime: 2020-07-26 21:20:36
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: \eso\lib\page\source\debug_rule_page.dart
 */
import 'package:eso/database/rule.dart';
import 'package:eso/ui/edit/edit_view.dart';
import 'package:flutter/material.dart';

import '../../fonticons_icons.dart';

class DebugRulePage extends StatelessWidget {
  final Rule rule;
  const DebugRulePage({this.rule, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyText1.color;
    return Scaffold(
      appBar: AppBar(
        title: _buildTextField(
          context,
          (_) {},
        ),
        actions: [
          IconButton(
            icon: Icon(FIcons
                .compass), // Text("发现测试",style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color)),
            tooltip: "发现测试",
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Icon(FIcons.cpu,
            size: 128, color: Theme.of(context).primaryColorDark.withOpacity(0.08)),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, void Function(String) onSubmitted) {
    return EditView(
      onSubmitted: onSubmitted,
      cursorColor: Theme.of(context).primaryTextTheme.headline6.color,
      style: TextStyle(
        color: Theme.of(context).primaryTextTheme.headline6.color,
      ),
      autofocus: true,
      hint: "请输入关键词开始搜索",
      maxLines: 1,
      textInputAction: TextInputAction.search,
    );
  }
}
