import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../hive/theme_box.dart';

class ColorPick extends StatefulWidget {
  final int color;
  final void Function(Color) onColorChanged;
  ColorPick({Key key, this.color, this.onColorChanged}) : super(key: key);

  @override
  State<ColorPick> createState() => _ColorPickState();
}

class _ColorPickState extends State<ColorPick> {
  Color pickerColor;
  @override
  void initState() {
    super.initState();
    pickerColor = Color(widget.color);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Builder(builder: (context) {
        return ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: (color) {
            setState(() {
              pickerColor = color;
            });
            widget.onColorChanged(color);
          },
          labelTypes: [],
          hexInputBar: true,
          portraitOnly: true,
        );
      }),
    );
  }
}

class ThemePage extends StatelessWidget {
  const ThemePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    pick(String title, String key, int dColor) => ListTile(
          title: Text(title),
          trailing: ValueListenableBuilder<Box>(
            valueListenable: themeBox.listenable(keys: <String>[key]),
            builder: (BuildContext context, Box _, Widget child) {
              return Container(
                color: Color(themeBox.get(key, defaultValue: dColor)),
                width: 20,
                height: 20,
              );
            },
          ),
          onTap: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: ColorPick(
                  color: themeBox.get(key, defaultValue: dColor),
                  onColorChanged: (val) => themeBox.put(key, val.value)),
            ),
          ),
        );

    return Container(
      // decoration: BoxDecoration(image: ),
      child: Scaffold(
          appBar: AppBar(title: Text('主题装扮')),
          body: ListView(
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(title: Text("主题 theme")),
                    Divider(),
                    pick('主题色 primaryColor', primaryColorKey, colors["冰青色"]),
                    pick('图标色 iconColor', iconColorKey, colors["鹿皮色"]),
                    pick('背景色 scaffoldBackgroundColor', scaffoldBackgroundColorColorKey,
                        colors["白杏色"]),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(title: Text("顶栏 app bar")),
                    Divider(),
                    pick('前景色 foregroundColor', appBarForegroundColorKey, colors["象牙色"]),
                    pick('背景色 backgroundColor', appBarBackgroundColorKey, colors["哔哩粉"]),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(title: Text("卡片 card")),
                    Divider(),
                    pick('背景色 background', cardBackgroundColorColorKey, colors["象牙色"]),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(title: Text("背景装饰 decoration")),
                    Divider(),
                    pick('背景色 background', decorationBackgroundColorKey, colors["象牙色"]),
                    
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
