import 'package:eso/database/rule.dart';
import 'package:eso/model/debug_rule_provider.dart';
import 'package:eso/ui/ui_text_field.dart';
import 'package:eso/ui/widgets/draggable_scrollbar_sliver.dart';
import 'package:eso/ui/widgets/keyboard_dismiss_behavior_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../fonticons_icons.dart';

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
          title: SearchTextField(
            controller:
                Provider.of<DebugRuleProvider>(context, listen: false).searchController,
            hintText: '请输入关键词开始搜索',
            autofocus: true,
            onSubmitted: Provider.of<DebugRuleProvider>(context, listen: false).search,
          ),
          actions: [
            IconButton(
              icon: Icon(FIcons
                  .compass), // Text("发现测试",style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color)),
              tooltip: "发现测试",
              onPressed: Provider.of<DebugRuleProvider>(context, listen: false).discover,
            ),
          ],
        ),
        body: Consumer<DebugRuleProvider>(
          builder: (context, DebugRuleProvider provider, _) {
            if (provider.rows.isEmpty) {
              return Center(
                child: Icon(FIcons.cpu,
                    size: 128,
                    color: Theme.of(context).primaryColorDark.withOpacity(0.08)),
              );
            }
            return KeyboardDismissBehaviorView(
              child: DraggableScrollbar.semicircle(
                controller: provider.controller,
                child: ListView.builder(
                  controller: provider.controller,
                  padding: EdgeInsets.all(8),
                  itemCount: provider.rows.length,
                  itemBuilder: (BuildContext context, int index) {
                    return provider.rows[index];
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
