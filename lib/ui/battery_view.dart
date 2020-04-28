import 'package:flutter/material.dart';

class BatteryView extends StatefulWidget {
  final double electricQuantity;
  final double width;
  final double height;

  BatteryView(
      {Key key, this.electricQuantity, this.width = 18, this.height = 8})
      : super(key: key);

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
      child: CustomPaint(
          size: Size(widget.width, widget.height),
          painter: BatteryViewPainter(widget.electricQuantity)),
    );
  }
}

class BatteryViewPainter extends CustomPainter {
  double electricQuantity;
  Paint mPaint;
  double mStrokeWidth = 0.0;
  double mPaintStrokeWidth = 1.5;

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

    double electricQuantityLeft = 0;
    double electricQuantityTop = 0;
    double electricQuantityRight = size.width * electricQuantity;
    double electricQuantityBottom = size.height - mStrokeWidth;

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
    if(electricQuantity<0.2){
      mPaint.color = Colors.red;
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
