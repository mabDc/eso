import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../global.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "一个加载页而已",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20,),
          Image.asset(Global.waitingPath),
        ],
      )
    );
  }
}
