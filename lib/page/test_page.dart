import 'package:eso/ui/widgets/app_bar_ex.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarEx(
        title: Text("功能测试"),
      ),
    );
  }
}