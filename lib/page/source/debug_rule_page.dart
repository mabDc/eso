import 'package:eso/database/rule.dart';
import 'package:eso/model/debug_rule_bloc.dart';
import 'package:flutter/material.dart';

class DebugRulePage extends StatefulWidget {
  final Rule rule;
  DebugRulePage({this.rule, Key key}) : super(key: key);

  @override
  _DebugRulePageState createState() => _DebugRulePageState();
}

class _DebugRulePageState extends State<DebugRulePage> {
  DebugRuleBloc _bloc;
  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  void initState() {
    _bloc = DebugRuleBloc(widget.rule);
    super.initState();
  }

  Widget _buildTextField() {
    return TextField(
      onSubmitted: _bloc.search,
      cursorColor: Theme.of(context).primaryTextTheme.headline6.color,
      style: TextStyle(
        color: Theme.of(context).primaryTextTheme.headline6.color,
      ),
      autofocus: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryTextTheme.headline6.color,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryTextTheme.headline6.color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTextField(),
      ),
      body: StreamBuilder<TextSpan>(
        stream: _bloc.dataStream, //stream,
        // initialData: <TextSpan>[
        //   TextSpan(text: "请输入关键词开始搜索", style: TextStyle(fontSize: 20))
        // ],
        builder: (BuildContext context, AsyncSnapshot<TextSpan> snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: Text("请输入关键词开始搜索"),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText.rich(snapshot.data),
          );
        },
      ),
    );
  }
}
