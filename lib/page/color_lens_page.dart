import 'package:flutter/material.dart';
import 'package:flutter_seekbar/flutter_seekbar.dart';
import 'package:provider/provider.dart';

import '../global.dart';
import '../model/profile.dart';

class ColorLensPage extends StatelessWidget {
  const ColorLensPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keys = Global.colors.keys.toList();
    final colors = Global.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text('调色板'),
      ),
      body: Consumer<Profile>(
        builder: (BuildContext context, Profile profile, Widget widget) {
          return ListView.builder(
            itemCount: keys.length * 2 + 2,
            itemBuilder: (BuildContext context, int index) {
              if (index % 2 == 1) {
                return Divider();
              }
              if (index == 0) {
                return _buildCustomColor();
              }
              String colorName = keys[index ~/ 2 - 1];
              return _buildColorListTile(colorName, Color(colors[colorName]));
            },
          );
        },
      ),
    );
  }

  Widget _buildCustomColor() {
    return Consumer<Profile>(
      builder: (BuildContext context, Profile profile, Widget widget) {
        final color = Color(profile.customColor);
        return Column(
          children: <Widget>[
            _buildColorListTile('自定义', color),
            ListTile(
              leading:
                  _buildColorContainer(Colors.red.withOpacity(color.red / 255)),
              title: _buildSeekBar(
                Colors.red,
                color.red,
                (value) => profile.customColorRed = value,
              ),
            ),
            ListTile(
              leading: _buildColorContainer(
                  Colors.green.withOpacity(color.green / 255)),
              title: _buildSeekBar(
                Colors.green,
                color.green,
                (value) => profile.customColorGreen = value,
              ),
            ),
            ListTile(
              leading: _buildColorContainer(
                  Colors.blue.withOpacity(color.blue / 255)),
              title: _buildSeekBar(
                Colors.blue,
                color.blue,
                (value) => profile.customColorBlue = value,
              ),
            ),
          ],
        );
      },
    );
  }

  SeekBar _buildSeekBar(
      Color color, int value, void Function(int) valueChanged) {
    return SeekBar(
      min: 0.0,
      max: 255.0,
      value: value.toDouble(),
      progresseight: 6,
      showSectionText: true,
      progressColor: color,
      backgroundColor: color.withOpacity(0.5),
      onValueChanged: (ProgressValue progressValue) {
        valueChanged(progressValue.value.toInt());
      },
      afterDragShowSectionText: true,
    );
  }

  Widget _buildColorListTile(String colorName, Color color) {
    return Consumer<Profile>(
      builder: (BuildContext context, Profile profile, Widget widget) {
        return ListTile(
          leading: _buildColorContainer(color),
          trailing: colorName == profile.colorName
              ? Icon(Icons.done, size: 32, color: color)
              : null,
          title: Text(colorName),
          onTap: () => profile.colorName = colorName,
        );
      },
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
}
