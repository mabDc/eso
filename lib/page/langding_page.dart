import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../global.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(width: 200,child: LinearProgressIndicator(),),
      ),
    );
  }
}
