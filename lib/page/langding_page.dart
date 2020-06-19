import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  final Color color;
  const LandingPage({Key key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      body: Center(
        child: SizedBox(width: 200, child: CupertinoActivityIndicator()),
      ),
    );
  }
}
