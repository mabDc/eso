import 'package:eso/database/rule.dart';
import 'package:eso/main.dart';
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
    final focus = FocusNode();
    return ChangeNotifierProvider<DebugRuleProvider>(
      create: (_) => DebugRuleProvider(rule, textColor),
      builder: (context, child) => Container(
        decoration: globalDecoration,
        child: Scaffold(
          appBar: AppBar(
            title: SearchTextField(
              controller:
                  Provider.of<DebugRuleProvider>(context, listen: false).searchController,
              hintText: '请输入关键词开始测试',
              autofocus: true,
              focusNode: focus,
              onSubmitted: Provider.of<DebugRuleProvider>(context, listen: false).handle,
            ),
            actions: [
              IconButton(
                icon: Icon(FIcons.chevrons_right),
                tooltip: "开始或刷新",
                onPressed: Provider.of<DebugRuleProvider>(context, listen: false).handle,
              ),
              IconButton(
                icon: Icon(FIcons.compass),
                tooltip: "发现测试",
                onPressed:
                    Provider.of<DebugRuleProvider>(context, listen: false).discover,
              ),
            ],
          ),
          body: Consumer<DebugRuleProvider>(
            builder: (context, DebugRuleProvider provider, _) {
              Widget _buildKeyword(String title, List<String> keys) {
                return Container(
                  height: 35,
                  child: Row(
                    children: [
                      Text("[$title::]"),
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (final key in keys)
                              TextButton(
                                onPressed: () {
                                  provider.handle(title + "::" + key);
                                },
                                child: Text(key),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (provider.rows.isEmpty) {
                return Column(
                  children: [
                    _buildKeyword("发现", provider.discoverKeys),
                    _buildKeyword("搜索", provider.searchKeys),
                    Expanded(
                      child: Center(
                        child: Icon(FIcons.cpu,
                            size: 128,
                            color: Theme.of(context).primaryColorDark.withOpacity(0.08)),
                      ),
                    ),
                  ],
                );
              }
              return KeyboardDismissBehaviorView(
                child: DraggableScrollbar.semicircle(
                  controller: provider.controller,
                  child: ListView.builder(
                    controller: provider.controller,
                    padding: EdgeInsets.all(8),
                    itemCount: provider.rows.length + 2,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return _buildKeyword("发现", provider.discoverKeys);
                      }
                      if (index == 1) {
                        return _buildKeyword("搜索", provider.searchKeys);
                      }
                      return provider.rows[index - 2];
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
