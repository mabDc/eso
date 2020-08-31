import 'package:flutter/material.dart';

/// 淡入淡出效果
class FadePageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;
  final int milliseconds;
  final bool isNext;

  FadePageRoute({this.builder, this.milliseconds = 500, this.isNext}): super(
    transitionDuration: Duration(milliseconds: milliseconds),
    pageBuilder: (context, ani1, ani2) {
      return builder(context);
    },
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation1,
        Animation<double> animation2,
        Widget child)
    {
      return FadeTransition(opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: animation1,
          curve: Curves.easeInOut
      )), child: child);
    }
  );

}