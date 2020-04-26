import 'dart:ui';
import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  final Color drawColor;

  const CurvePainter({
    this.drawColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();

    paint.color = drawColor;
    paint.style = PaintingStyle.stroke;
    paint.isAntiAlias = true;
    paint.strokeWidth = 3;

    var startPoint = Offset(0, 4 * (size.height / 5));
    var controlPoint1 =
        Offset(size.width / 4, size.height + (size.height / 5) / 3);
    var controlPoint2 =
        Offset(3 * size.width / 4, size.height + (size.height / 5) / 3);
    var endPoint = Offset(size.width, 4 * (size.height / 5));

    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(startPoint.dx, startPoint.dy);
    path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
        controlPoint2.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
