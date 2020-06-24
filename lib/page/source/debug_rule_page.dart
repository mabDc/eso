import 'package:eso/database/rule.dart';
import 'package:eso/model/debug_rule_provider.dart';
import 'package:eso/ui/edit/edit_view.dart';
import 'package:eso/utils.dart';
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
        appBar: AppBarEx(
          title: _buildTextField(
            context,
            Provider.of<DebugRuleProvider>(context, listen: false).search,
          ),
        ),
        body: Consumer<DebugRuleProvider>(
          builder: (context, DebugRuleProvider provider, _) {
            if (provider.rows.isEmpty) {
              return Center(
                child: Icon(FIcons.cpu, size: 128, color: Theme.of(context).primaryColorDark.withOpacity(0.08)),
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
