import 'dart:io';

import 'package:flutter/material.dart';

/// 电池小部件
class BatteryView extends StatefulWidget {
  final int electricQuantity;
  final double width;
  final double height;

  BatteryView({
    Key key,
    this.electricQuantity,
    this.width = 18,
    this.height = 10,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BatteryViewState();
  }
}

class BatteryViewState extends State<BatteryView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: [
          CustomPaint(
              size: Size(widget.width, widget.height),
              painter: BatteryViewPainter(widget.electricQuantity / 100)),
          Center(
            child: Text('${widget.electricQuantity}', style: TextStyle(
              fontSize: 10,
              height: 1.0,
              color: Colors.white,
              fontFamily: Platform.isIOS ? ".SF UI Display" : "Roboto",
              shadows: [Shadow(blurRadius: 1.5, offset: Offset(0.5, 0.5))],
            ), textAlign: TextAlign.center, maxLines: 1, textScaleFactor: 1.0),
          )
        ],
      ),
    );
  }
}

class BatteryViewPainter extends CustomPainter {
  double electricQuantity;
  Paint mPaint;
  double mStrokeWidth = 0.0;
  double mPaintStrokeWidth = 1.0;

  BatteryViewPainter(electricQuantity) {
    this.electricQuantity = electricQuantity;
    mPaint = Paint()..strokeWidth = mPaintStrokeWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //电池框位置
    double batteryLeft = mStrokeWidth;
    double batteryTop = 0;
    double batteryRight = size.width;
    double batteryBottom = size.height;

    //电量位置
    double electricQuantityLeft = mPaintStrokeWidth;
    double electricQuantityTop = mPaintStrokeWidth ;
    double electricQuantityRight = mPaintStrokeWidth +
        (size.width - mPaintStrokeWidth * 2) * electricQuantity;
    double electricQuantityBottom = size.height - mPaintStrokeWidth;

    //电池头部位置
    double batteryHeadLeft = batteryRight + mStrokeWidth * 4;
    double batteryHeadTop = size.height / 4;
    double batteryHeadRight = batteryHeadLeft + size.width / 12;
    double batteryHeadBottom = batteryHeadTop + (size.height / 2);

    mPaint.style = PaintingStyle.fill;
    mPaint.color = Colors.white;
    //画电池头部
    canvas.drawRRect(
        RRect.fromLTRBR(batteryHeadLeft, batteryHeadTop, batteryHeadRight,
            batteryHeadBottom, Radius.circular(mStrokeWidth)),
        mPaint);
    mPaint.style = PaintingStyle.stroke;
    //画电池框
    canvas.drawRRect(
        RRect.fromLTRBR(batteryLeft, batteryTop, batteryRight, batteryBottom,
            Radius.circular(mStrokeWidth)),
        mPaint);
    mPaint.style = PaintingStyle.fill;

    //判断电池电量颜色
    if (electricQuantity < 0.2) {
      mPaint.color = Colors.red;
    } else {
      mPaint.color = Colors.white60;
    }

    //画电池电量
    canvas.drawRRect(
        RRect.fromLTRBR(
            electricQuantityLeft,
            electricQuantityTop,
            electricQuantityRight,
            electricQuantityBottom,
            Radius.circular(mStrokeWidth)),
        mPaint);
  }

  @override
  bool shouldRepaint(BatteryViewPainter other) {
    return true;
  }
}
