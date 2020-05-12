import 'package:eso/database/rule.dart';
import 'package:eso/model/debug_rule_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DebugRulePage extends StatefulWidget {
  final Rule rule;
  DebugRulePage({this.rule, Key key}) : super(key: key);

  @override
  _DebugRulePageState createState() => _DebugRulePageState();
}

class _DebugRulePageState extends State<DebugRulePage> {
  DebugRuleProvider __provider;
  Widget _page;

  @override
  void dispose() {
    __provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_page == null) {
      _page = _buildPage(context);
    }
    return _page;
  }

  Widget _buildPage(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: DebugRuleProvider(
        widget.rule,
        Theme.of(context).textTheme.bodyText1.color,
      ),
      builder: (BuildContext context, _) {
        return Scaffold(
          appBar: AppBar(
            title: _buildTextField(context),
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
        );
      },
    );
  }

  Widget _buildTextField(BuildContext context) {
    final privider = Provider.of<DebugRuleProvider>(context);
    return TextField(
      onSubmitted: privider.search,
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
