import 'dart:convert';

import 'package:eso/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../global.dart';
import '../../hive/theme_box.dart';
import '../../hive/theme_mode_box.dart';
import '../../utils.dart';

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
                appBar: AppBar(
                  title: Text('主题装扮'),
                  actions: [
                    IconButton(
                        onPressed: () {
                          final controller = TextEditingController(
                            text: '''
// 亦搜主题
// app版本${Global.appVersion} 版号${Global.appBuildNumber}
// themeMode排序0为system,1为light,2为dark
{
  "themeMode": ${themeMode},
  "${decorationImageKey}":"${decorationImage.length > "assets/ba/".length ? decorationImage.substring("assets/ba/".length) : ''}",
  "${primaryColorKey}": "${primaryColor.toRadixString(16)}",
  "${iconColorKey}": "${iconColor.toRadixString(16)}",
  "${appBarForegroundColorKey}": "${appBarForegroundColor.toRadixString(16)}",
  "${appBarBackgroundColorKey}": "${appBarBackgroundColor.toRadixString(16)}",
  "${scaffoldBackgroundColorKey}": "${scaffoldBackgroundColor.toRadixString(16)}",
  "${cardBackgroundColorKey}": "${cardBackgroundColor.toRadixString(16)}",
  "${appBarForegroundDarkColorKey}": "${appBarForegroundDarkColor.toRadixString(16)}",
  "${appBarBackgroundDarkColorKey}": "${appBarBackgroundDarkColor.toRadixString(16)}",
  "${scaffoldBackgroundDarkColorKey}": "${scaffoldBackgroundDarkColor.toRadixString(16)}",
  "${cardBackgroundDarkColorKey}": "${cardBackgroundDarkColor.toRadixString(16)}"
}
''',
                          );

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("主题代码"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          controller.text = '''
// 亦搜主题(西红柿喵, 白天)
// app版本 1.23.03
// 频道用户懒儿提供灵感，调整得到
{
  "themeMode": ${(tomatoCat["themeMode"] as ThemeMode).index},
  "${decorationImageKey}":"${tomatoCat[decorationImageKey]}",
  "${primaryColorKey}": "${(tomatoCat[primaryColorKey] as int).toRadixString(16)}",
  "${iconColorKey}": "${(tomatoCat[iconColorKey] as int).toRadixString(16)}",
  "${appBarForegroundColorKey}": "${(tomatoCat[appBarForegroundColorKey] as int).toRadixString(16)}",
  "${appBarBackgroundColorKey}": "${(tomatoCat[appBarBackgroundColorKey] as int).toRadixString(16)}",
  "${scaffoldBackgroundColorKey}": "${(tomatoCat[scaffoldBackgroundColorKey] as int).toRadixString(16)}",
  "${cardBackgroundColorKey}": "${(tomatoCat[cardBackgroundColorKey] as int).toRadixString(16)}"
}
''';
                                        },
                                        child: Text("西红柿喵")),
                                    TextField(
                                      controller: controller,
                                      maxLines: 8,
                                      decoration: InputDecoration(
                                        labelText: "不了解请勿手动编辑", 
                                        // helperText: "",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () async {
                                        final text = (await Clipboard.getData(
                                                Clipboard.kTextPlain))
                                            .text;
                                        controller.text = text;
                                        Utils.toast("已从剪贴板更新");
                                      },
                                      child: Text("粘贴")),
                                  TextButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: controller.text));
                                        Utils.toast("已保存到剪贴板");
                                      },
                                      child: Text("复制")),
                                  TextButton(
                                      onPressed: () {
                                        Share.share(controller.text);
                                      },
                                      child: Text("分享")),
                                  TextButton(
                                      onPressed: () {
                                        try {
                                          final json = controller.text
                                              .replaceAll(RegExp("\\s*//.*"), "")
                                              .trim();
                                          final obj = jsonDecode(json);
                                          if (obj is Map) {
                                            for (var entry in obj.entries)
                                              if (entry.key == "themeMode") {
                                                final mode = entry.value;
                                                if (mode != null &&
                                                    mode is int &&
                                                    mode > -1 &&
                                                    mode < 3) {
                                                  themeMode = mode;
                                                }
                                              } else if (entry.key ==
                                                  decorationImageKey) {
                                                themeBox.put(decorationImageKey,
                                                    "assets/ba/${entry.value}");
                                              } else {
                                                final value =
                                                    int.tryParse(entry.value, radix: 16);
                                                if (value != null &&
                                                    value > 0 &&
                                                    value <= 0xFFFFFFFF) {
                                                  themeBox.put(entry.key, value);
                                                } else {
                                                  Utils.toast("错误, ${entry.key}数值不对");
                                                }
                                              }
                                            Utils.toast("应用成功");
                                            Navigator.of(context).pop();
                                            Future.delayed(Duration(seconds: 1), () {
                                              controller.dispose();
                                            });
                                          } else {
                                            Utils.toast("错误, 不是json");
                                          }
                                        } catch (e) {
                                          Utils.toast("出错, 请检查json格式, $e");
                                        }
                                      },
                                      child: Text("应用")),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.code)),
                  ],
                ),
                body: ListView(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.color_lens),
                            title: const Text("调色板"),
                          ),
                          pick('主题色', primaryColorKey, tomatoCat[primaryColorKey]),
                          pick('图标色', iconColorKey, tomatoCat[iconColorKey]),
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
                              pick('顶栏前景色', appBarForegroundColorKey,
                                  tomatoCat[appBarForegroundColorKey]),
                              pick('顶栏背景色', appBarBackgroundColorKey,
                                  tomatoCat[appBarBackgroundColorKey]),
                              pick('页面背景色', scaffoldBackgroundColorKey,
                                  tomatoCat[scaffoldBackgroundColorKey]),
                              pick('卡片背景色', cardBackgroundColorKey,
                                  tomatoCat[cardBackgroundColorKey]),
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
                    // Card(
                    //   child: Wrap(
                    //     spacing: 4,
                    //     runSpacing: 4,
                    //     alignment: WrapAlignment.center,
                    //     children: [
                    //       for (final color in colors.entries)
                    //         Chip(
                    //           backgroundColor: Color(color.value),
                    //           labelStyle: TextStyle(color: Colors.black),
                    //           label:
                    //               Text(color.key + " #${color.value.toRadixString(16)}"),
                    //           onDeleted: () {
                    //             Clipboard.setData(ClipboardData(
                    //                 text:
                    //                     "#${color.value.toRadixString(16).substring(2)}"));
                    //           },
                    //           deleteButtonTooltipMessage: "复制",
                    //           deleteIcon: Icon(
                    //             Icons.copy,
                    //             size: 16,
                    //           ),
                    //         )
                    //     ],
                    //   ),
                    // ),
                  ],
                )),
          );
        });
  }
}
