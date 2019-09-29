import 'package:flutter/material.dart';
import '../global.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(Global.waitingPath),
      ),
    );
  }
}
