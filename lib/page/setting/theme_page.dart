import 'package:eso/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../hive/theme_box.dart';
import '../../hive/theme_mode_box.dart';

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

    return ValueListenableBuilder<Box>(
        valueListenable: themeBox.listenable(keys: <String>[decorationImageKey]),
        builder: (BuildContext context, Box _, Widget child) {
          return Container(
            decoration: globalDecoration,
            child: Scaffold(
                appBar: AppBar(title: Text('主题装扮')),
                body: ListView(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.color_lens),
                            title: const Text("调色板"),
                          ),
                          pick('主题色', primaryColorKey, colors["哔哩粉"]),
                          pick('图标色', iconColorKey, colors["西红柿色"]),
                        ],
                      ),
                    ),
                    Card(
                      child: ValueListenableBuilder<Box<int>>(
                        valueListenable: themeModeBox.listenable(),
                        builder: (BuildContext context, Box<int> box, Widget child) {
                          const done = const Icon(Icons.done, size: 32);
                          return Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.auto_mode_outlined),
                                title: Text("跟随系统"),
                                onTap: () => themeMode = ThemeMode.system.index,
                                trailing:
                                    ThemeMode.system.index == themeMode ? done : null,
                              ),
                              ListTile(
                                leading: const Icon(Icons.light_mode_outlined),
                                title: Text("白天模式"),
                                onTap: () => themeMode = ThemeMode.light.index,
                                trailing:
                                    ThemeMode.light.index == themeMode ? done : null,
                              ),
                              pick('顶栏前景色', appBarForegroundColorKey, colors["星空灰"]),
                              pick('顶栏背景色', appBarBackgroundColorKey, colors["象牙色"]),
                              pick('页面背景色', scaffoldBackgroundColorKey, colors["象牙色"]),
                              pick('卡片背景色', cardBackgroundColorKey, colors["象牙色"]),
                              ListTile(
                                leading: const Icon(Icons.dark_mode_outlined),
                                title: Text("黑夜模式"),
                                onTap: () => themeMode = ThemeMode.dark.index,
                                trailing: ThemeMode.dark.index == themeMode ? done : null,
                              ),
                              pick('顶栏前景色', appBarForegroundDarkColorKey, colors["象牙色"]),
                              pick('顶栏背景色', appBarBackgroundDarkColorKey, colors["星空灰"]),
                              pick(
                                  '页面背景色', scaffoldBackgroundDarkColorKey, colors["星空灰"]),
                              pick('卡片背景色', cardBackgroundDarkColorKey, colors["星空灰"]),
                            ],
                          );
                        },
                      ),
                    ),
                    Card(
                      child: Material(
                        color: Colors.transparent,
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            "懒儿1",
                            "懒儿2",
                            "懒儿3",
                            "懒儿4",
                            "响海1",
                            "响海2",
                            ...List.generate(13, (index) => "水${index + 1}"),
                          ].map((u) {
                            return InkWell(
                              onTap: () {
                                themeBox.put(decorationImageKey, "assets/ba/$u.jpg");
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.asset(
                                  "assets/ba/$u.jpg",
                                  height: 200,
                                  width: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Card(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        alignment: WrapAlignment.center,
                        children: [
                          for (final color in colors.entries)
                            Chip(
                              backgroundColor: Color(color.value),
                              labelStyle: TextStyle(color: Colors.black),
                              label:
                                  Text(color.key + " #${color.value.toRadixString(16)}"),
                              onDeleted: () {
                                Clipboard.setData(ClipboardData(
                                    text:
                                        "#${color.value.toRadixString(16).substring(2)}"));
                              },
                              deleteButtonTooltipMessage: "复制",
                              deleteIcon: Icon(
                                Icons.copy,
                                size: 16,
                              ),
                            )
                        ],
                      ),
                    ),
                  ],
                )),
          );
        });
  }
}
