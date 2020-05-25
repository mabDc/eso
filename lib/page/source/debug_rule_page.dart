import 'package:eso/database/rule.dart';
import 'package:eso/model/debug_rule_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebugRulePage extends StatelessWidget {
  final Rule rule;
  const DebugRulePage({this.rule, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyText1.color;
    return ChangeNotifierProvider<DebugRuleProvider>(
      create: (_) => DebugRuleProvider(rule, textColor),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: _buildTextField(
            context,
            Provider.of<DebugRuleProvider>(context, listen: false).search,
          ),
        ),
        body: Consumer<DebugRuleProvider>(
          builder: (context, DebugRuleProvider provider, _) {
            if (provider.rows.isEmpty) {
              return Center(
                child: Text("请输入关键词开始搜索"),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: provider.rows.length,
              itemBuilder: (BuildContext context, int index) {
                return provider.rows[index];
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, void Function(String) onSubmitted) {
    return TextField(
      onSubmitted: onSubmitted,
      cursorColor: Theme.of(context).primaryTextTheme.headline6.color,
      style: TextStyle(
        color: Theme.of(context).primaryTextTheme.headline6.color,
      ),
      autofocus: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryTextTheme.headline6.color,
          ),
        ),
        isDense: true,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryTextTheme.headline6.color,
          ),
        ),
      ),
    );
  }
}
