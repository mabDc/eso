import 'package:flutter/material.dart';

/// 文本框底部边线
class BottomInputBorder extends InputBorder {
  final Color color;
  final double width;

  BottomInputBorder(this.color, {this.width = 1.0})
      : super(borderSide: BorderSide(color: color, width: width));

  @override
  BottomInputBorder copyWith(
      {BorderSide borderSide, BorderRadius borderRadius}) {
    return BottomInputBorder(this.color, width: this.width);
  }

  @override
  bool get isOutline => false;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  BottomInputBorder scale(double t) =>
      BottomInputBorder(this.color, width: this.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(
      Canvas canvas,
      Rect rect, {
        double gapStart,
        double gapExtent: 0.0,
        double gapPercentage: 0.0,
        TextDirection textDirection,
      }) {
    canvas.drawLine(rect.bottomLeft, rect.bottomRight, borderSide.toPaint());
  }
}
