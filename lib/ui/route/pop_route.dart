import 'package:flutter/material.dart';

class PopRoute extends PageRouteBuilder {
  final WidgetBuilder builder;
  final int milliseconds;
  bool isNext;
  bool isPop;

  PopRoute({this.builder, this.milliseconds = 500, this.isNext, this.isPop}): super(
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
        return SlideTransition(position: animation1.drive(
            Tween(end: Offset(-1.0, 0.0), begin: Offset.zero)
                .chain(CurveTween(curve: Curves.ease))), child: child);
      }
  );

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) => false;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> previousRoute) => true;

}
