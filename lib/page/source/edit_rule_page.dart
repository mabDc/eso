import 'package:flutter/material.dart';

class EditRulePage extends StatefulWidget {
  @override
  _EditRulePageState createState() => _EditRulePageState();
}

class _EditRulePageState extends State<EditRulePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新建规则'),
      ),
    );
  }
}
