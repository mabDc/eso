import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../../global.dart';
import '../../model/profile.dart';

class ColorLensPage extends StatelessWidget {
  static const primaryColor = 0;
  static const novelColor = 1;
  static const novelBackground = 2;
  final int option;
  final bool showAppbar;
  const ColorLensPage({
    Key key,
    this.option = primaryColor,
    this.showAppbar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keys = Global.colors.keys.toList();
    final colors = Global.colors;
    final profile = Provider.of<Profile>(context);
    return Scaffold(
      appBar: showAppbar
          ? AppBar(
              title: Text('调色板'),
              actions: [
                Tooltip(
                  message: '文字色和背景色是文字正文配置项\n请选配置项再设置颜色',
                  child: IconButton(
                    icon: Icon(Icons.help_outline),
                    onPressed: () => null,
                    tooltip: '文字色和背景色是文字正文配置项\n请选配置项再设置颜色',
                  ),
                ),
              ],
            )
          : null,
      body: ChangeNotifierProvider(
        create: (context) => _ColorLensProvider(option),
        builder: (context, child) {
          final provider = Provider.of<_ColorLensProvider>(context);
          int option = context.select((_ColorLensProvider provider) => provider.option);
          String colorName;
          void Function(String color) oncheck;
          switch (option) {
            case primaryColor:
              colorName = profile.colorName;
              oncheck = (colorName) => profile.colorName = colorName;
              break;
            case novelBackground:
              colorName = profile.novelBackground;
              oncheck = (colorName) => profile.novelBackground = colorName;
              break;
            default:
              colorName = profile.colorName;
              oncheck = (colorName) => profile.colorName = colorName;
              break;
          }
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: keys.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ColorPicker(
                      pickerColor: Color(profile.customColor),
                      onColorChanged: (Color color) {
                        if (option == primaryColor) {
                          profile.colorName = '自定义';
                          profile.customColor = color.value;
                          provider.fresh();
                        } else {
                          profile.novelBackground = '#' + color.value.toRadixString(16);
                          provider.fresh();
                        }
                      },
                      showLabel: true,
                      enableAlpha: false,
                      pickerAreaHeightPercent: 0.8,
                    ),
                    SlidePicker(
                      pickerColor: Color(profile.customColor),
                      onColorChanged: (Color color) {
                        if (option == primaryColor) {
                          profile.colorName = '自定义';
                          profile.customColor = color.value;
                          provider.fresh();
                        } else {
                          profile.novelBackground = '#' + color.value.toRadixString(16);
                          provider.fresh();
                        }
                      },
                      paletteType: PaletteType.rgb,
                      enableAlpha: false,
                      displayThumbColor: false,
                      showLabel: true,
                      showIndicator: false,
                      indicatorBorderRadius: const BorderRadius.vertical(
                        top: const Radius.circular(25.0),
                      ),
                    ),
                  ],
                );
              }
              String buildColor = keys[index - 1];
              int c = buildColor.startsWith('#')
                  ? int.parse(buildColor.substring(1), radix: 16)
                  : colors[buildColor];
              return _buildColorListTile(buildColor, c, colorName == buildColor, oncheck);
            },
          );
        },
      ),
    );
  }

  // 纯色
  Widget _buildColorListTile(
      String buildColor, int c, bool check, void Function(String color) oncheck) {
    final color = Color(c);
    return ListTile(
      leading: _buildColorContainer(color),
      trailing: check ? Icon(Icons.done, size: 32, color: color) : null,
      title: Text(buildColor),
      onTap: () => oncheck(buildColor),
    );
  }

  Container _buildColorContainer(Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      height: 32,
      width: 32,
    );
  }

  Widget _buildOption(_ColorLensProvider provider, int option) {
    return Row(
      children: [
        SizedBox(width: 16),
        Text('配置'),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 140,
                  child: RadioListTile(
                    value: primaryColor,
                    groupValue: option,
                    onChanged: (value) => provider.option = value,
                    title: Text(
                      '主题色',
                      style: TextStyle(fontSize: option == primaryColor ? 16 : 14),
                    ),
                  ),
                ),
                Container(
                  width: 140,
                  child: RadioListTile(
                    value: novelColor,
                    groupValue: option,
                    onChanged: (value) => provider.option = value,
                    title: Text(
                      '文字色',
                      style: TextStyle(fontSize: option == novelColor ? 16 : 14),
                    ),
                  ),
                ),
                Container(
                  width: 140,
                  child: RadioListTile(
                    value: novelBackground,
                    groupValue: option,
                    onChanged: (value) => provider.option = value,
                    title: Text(
                      '背景色',
                      style: TextStyle(fontSize: option == novelBackground ? 16 : 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  // Widget _buildCustomColor(Profile profile) {
  //   final color = Color(profile.customColor);
  //   return Column(
  //     children: <Widget>[
  //       _buildColorListTile(profile, '自定义', color),
  //       ListTile(
  //         leading: _buildColorContainer(Colors.red.withOpacity(color.red / 255)),
  //         title: _buildSeekBar(
  //           Colors.red,
  //           color.red,
  //           (value) => profile.customColorRed = value,
  //         ),
  //       ),
  //       ListTile(
  //         leading: _buildColorContainer(Colors.green.withOpacity(color.green / 255)),
  //         title: _buildSeekBar(
  //           Colors.green,
  //           color.green,
  //           (value) => profile.customColorGreen = value,
  //         ),
  //       ),
  //       ListTile(
  //         leading: _buildColorContainer(Colors.blue.withOpacity(color.blue / 255)),
  //         title: _buildSeekBar(
  //           Colors.blue,
  //           color.blue,
  //           (value) => profile.customColorBlue = value,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Container _buildSeekBar(Color color, int value, void Function(int) valueChanged) {
  //   return Container(
  //     height: 46,
  //     child: FlutterSlider(
  //       values: [value.toDouble()],
  //       max: 255,
  //       min: 0,
  //       onDragging: (handlerIndex, lowerValue, upperValue) =>
  //           valueChanged((lowerValue as double).toInt()),
  //       trackBar: FlutterSliderTrackBar(
  //         inactiveTrackBar: BoxDecoration(
  //           borderRadius: BorderRadius.circular(20),
  //           color: color.withOpacity(0.4),
  //         ),
  //         activeTrackBar: BoxDecoration(
  //           borderRadius: BorderRadius.circular(4),
  //           color: color,
  //         ),
  //       ),
  //       hatchMark: FlutterSliderHatchMark(
  //         labelsDistanceFromTrackBar: 24,
  //         linesDistanceFromTrackBar: -4,
  //         linesAlignment: FlutterSliderHatchMarkAlignment.left,
  //         displayLines: true,
  //         density: 0.16,
  //         smallLine: FlutterSliderSizedBox(
  //             height: 6, width: 1, decoration: BoxDecoration(color: color)),
  //         bigLine: FlutterSliderSizedBox(
  //             height: 8, width: 2, decoration: BoxDecoration(color: color)),
  //         labels: [
  //           FlutterSliderHatchMarkLabel(
  //             percent: 0,
  //             label: Text('0', style: TextStyle(fontSize: 12)),
  //           ),
  //           FlutterSliderHatchMarkLabel(
  //             percent: 5 / 16 * 100,
  //             label: Text('50', style: TextStyle(fontSize: 12)),
  //           ),
  //           FlutterSliderHatchMarkLabel(
  //             percent: 10 / 16 * 100,
  //             label: Text('A0', style: TextStyle(fontSize: 12)),
  //           ),
  //           FlutterSliderHatchMarkLabel(
  //             percent: 15 / 16 * 100,
  //             label: Text('F0', style: TextStyle(fontSize: 12)),
  //           ),
  //         ],
  //       ),
  //       handlerWidth: 6,
  //       handlerHeight: 14,
  //       handler: FlutterSliderHandler(
  //         decoration: BoxDecoration(),
  //         child: Container(
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(6),
  //             color: color,
  //             border: Border.all(color: color.withOpacity(0.65), width: 1),
  //           ),
  //         ),
  //       ),
  //       tooltip: FlutterSliderTooltip(
  //         disableAnimation: true,
  //         custom: (value) => Container(
  //           padding: EdgeInsets.all(8),
  //           color: color,
  //           child: Text("0x" +
  //               (value as double).toInt().toRadixString(16).toUpperCase() +
  //               " | " +
  //               (value as double).toStringAsFixed(0)),
  //         ),
  //         positionOffset: FlutterSliderTooltipPositionOffset(left: -20, right: -20),
  //       ),
  //     ),
  //   );
  // }

}

class _ColorLensProvider with ChangeNotifier {
  int _option;
  int get option => _option;
  set option(int value) {
    if (_option != value) {
      _option = value;
      notifyListeners();
    }
  }

  void fresh() => notifyListeners();

  _ColorLensProvider(int option) {
    _option = option;
  }
}
