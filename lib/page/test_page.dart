import 'package:eso/ui/widgets/app_bar_ex.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/flutter_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  static double value = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarEx(
        title: Text("功能测试"),
      ),
      body: Column(
        children: [
          SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black26,
            child: FlutterSlider(
              values: [value],
              min: 0,
              max: 0.0,
              handlerHeight: 12,
              handlerWidth: 12,
              handler: FlutterSliderHandler(
                child: Material(
                  elevation: 0,
                  color: Colors.transparent,
                  child: Container(
                    width: 12,
                    height: 12,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              touchSize: 30,
              disabled: false,
              onDragCompleted: (handlerIndex, lowerValue, upperValue) {
                setState(() {
                  value = lowerValue;
                });
              },
              trackBar: FlutterSliderTrackBar(
                inactiveTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white54,
                ),
                activeTrackBar: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white70,
                ),
              ),
              tooltip: FlutterSliderTooltip(
                disableAnimation: true,
                custom: (value) => Container(
                  color: Colors.black26,
                  padding: EdgeInsets.all(4),
                  child: Text(
                    Utils.formatDuration(Duration(milliseconds: (value as double).toInt())),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                positionOffset: FlutterSliderTooltipPositionOffset(left: 0, right: 0),
              ),
            ),
          )
        ],
      ),
    );
  }
}