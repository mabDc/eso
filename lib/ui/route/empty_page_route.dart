import 'package:flutter/material.dart';

/// 无动画效果
class EmptyPageRoute extends PageRouteBuilder {
  final WidgetBuilder builder;

  EmptyPageRoute({this.builder}): super(
    transitionDuration: const Duration(microseconds: 100),
    pageBuilder: (context, ani1, ani2) {
      return builder(context);
    },
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation1,
        Animation<double> animation2,
        Widget child)
    {
      return child;
    }
  );

}