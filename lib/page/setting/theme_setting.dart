import 'package:eso/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../utils.dart';

class themeSetting extends StatelessWidget {
  const themeSetting({Key key}) : super(key: key);

  Widget colorPick(BuildContext context, String title, Color color,
      void Function(Color) onChangeColor) {
    return CupertinoListTile(
      title: Text(title),
      additionalInfo: Container(
          height: 20,
          width: 20,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))),
      trailing: Icon(
        CupertinoIcons.right_chevron,
        size: CupertinoTheme.of(context).textTheme.textStyle.fontSize,
        color: getThemeColor("iconColor"),
      ),
      onTap: () {
        showCupertinoModalBottomSheet(
          expand: false,
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => EditColorPage(
            title: title,
            pickerColor: color,
            onChangeColor: onChangeColor,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = getThemeColor("backgroundColor");
    return Container(
      decoration: globalDecoration,
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: Colors.transparent,
          middle: Text('主题装扮'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: Text("应用"),
            onPressed: () {},
          ),
          border: null,
        ),
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              decoration: BoxDecoration(color: backgroundColor.withOpacity(0.2)),
              backgroundColor: backgroundColor.withOpacity(0.2),
              header: Text("配色"),
              children: [
                colorPick(context, "主色调", getThemeColor("primaryColor"),
                    (color) => setThemeColor("primaryColor", color.value)),
                colorPick(context, "背景色", getThemeColor("backgroundColor"),
                    (color) => setThemeColor("backgroundColor", color.value)),
                colorPick(context, "导航栏", getThemeColor("barBackgroundColor"),
                    (color) => setThemeColor("barBackgroundColor", color.value)),
                colorPick(context, "文字", getThemeColor("primaryTextColor"),
                    (color) => setThemeColor("primaryTextColor", color.value)),
                colorPick(context, "图标", getThemeColor("iconColor"),
                    (color) => setThemeColor("iconColor", color.value)),
                colorPick(context, "背景图蒙版(关联背景图透明度)", getThemeColor("decorationColor"),
                    (color) => setThemeColor("decorationColor", color.value)),
              ],
            ),
            CupertinoListSection.insetGrouped(
              decoration: BoxDecoration(color: backgroundColor.withOpacity(0.2)),
              backgroundColor: backgroundColor.withOpacity(0.2),
              header: Text("背景图"),
              children: [
                CupertinoListTile(
                  title: Text("透明度"),
                  trailing: Material(
                      color: Colors.transparent,
                      child: DropdownButton<double>(
                          iconEnabledColor: getThemeColor("iconColor"),
                          value: globalDecoration.image.opacity,
                          items: List.generate(
                              11,
                              (index) => DropdownMenuItem(
                                    child: Text((index / 10).toString()),
                                    value: index / 10,
                                  )),
                          onChanged: (value) {
                            Hive.box(themeSettingBoxName).put("opacity", value);
                            updateDecoration();
                          })),
                  onTap: () {},
                ),
                CupertinoListTile(
                  title: Text("大小填充方式"),
                  subtitle: Row(
                      children: BoxFit.values.map((e) => Text(e.name + "  ")).toList()),
                  onTap: () {
                    Utils.toast(" 还没做呢 ");
                  },
                ),
                CupertinoListTile(title: Text("选择图片")),
                Material(
                  color: Colors.transparent,
                  child: Wrap(
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
                          Hive.box(themeSettingBoxName).put("bapath", "assets/ba/$u.jpg");
                          updateDecoration();
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration globalDecoration;
String themeSettingBoxName = "themeSetting";
void updateDecoration() {
  Box themeSetting = Hive.box(themeSettingBoxName);
  int color = themeSetting.get("decorationColor") ??
      CupertinoColors.systemGroupedBackground.value;
  int boxFit = themeSetting.get("boxFit") ?? BoxFit.fitWidth.index;
  double opacity = themeSetting.get("opacity") ?? 0.8;
  String bapath = themeSetting.get("bapath") ?? "assets/ba/水12.jpg";
  globalDecoration = null;
  globalDecoration = BoxDecoration(
    color: Color(color),
    image: DecorationImage(
      fit: BoxFit.values[boxFit],
      opacity: opacity,
      image: AssetImage(bapath),
    ),
  );
  Profile().refreshAllApp();
}

Color getThemeColor(String name) {
  final box = Hive.box("themeSetting");
  switch (name) {
    case "backgroundColor":
      return Color(
          box.get("backgroundColor") ?? CupertinoColors.systemGroupedBackground.value);
    case "decorationColor":
      return Color(
          box.get("decorationColor") ?? CupertinoColors.systemGroupedBackground.value);
    case "barBackgroundColor":
      return Color(box.get("barBackgroundColor") ??
          CupertinoDynamicColor.withBrightness(
            color: Color(0xF0F9F9F9),
            darkColor: Color(0xF01D1D1D),
          ).value);
    case "primaryTextColor":
      return Color(box.get("primaryTextColor") ?? CupertinoColors.black.value);
    case "primaryColor":
      return Color(box.get("primaryColor") ?? CupertinoColors.systemBlue.value);
    case "iconColor":
      return Color(box.get("iconColor") ?? CupertinoColors.systemBlue.value);
    default:
      return Colors.grey;
  }
}

void setThemeColor(String name, int color) {
  Hive.box("themeSetting").put(name, color);
  if (name == "decorationColor") updateDecoration();
  Profile().refreshAllApp();
}

class EditColorPage extends StatefulWidget {
  final Color pickerColor;
  final void Function(Color) onChangeColor;
  final String title;

  const EditColorPage({
    @required this.title,
    @required this.pickerColor,
    @required this.onChangeColor,
    Key key,
  }) : super(key: key);

  @override
  State<EditColorPage> createState() => _EditColorPageState();
}

class _EditColorPageState extends State<EditColorPage> {
  Color pickerColor;

  @override
  void initState() {
    super.initState();
    pickerColor = widget.pickerColor;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: globalDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CupertinoNavigationBar(
            backgroundColor: Colors.transparent,
            middle: Text(widget.title),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text("重置"),
              onPressed: () {
                pickerColor = widget.pickerColor;
                widget.onChangeColor(pickerColor);
              },
            ),
            border: null,
          ),
          BlockPicker(
            pickerColor: pickerColor,
            onColorChanged: ((value) {
              setState(() {
                pickerColor = value;
                widget.onChangeColor(value);
              });
            }),
            availableColors: _defaultColors,
            layoutBuilder: (context, colors, child) {
              return Wrap(
                runAlignment: WrapAlignment.center,
                children: colors
                    .map((Color color) => SizedBox(
                          width: 38,
                          height: 38,
                          child: child(color),
                        ))
                    .toList(),
              );
            },
          ),
          SlidePicker(
            pickerColor: pickerColor,
            onColorChanged: ((value) {
              setState(() {
                pickerColor = value;
                widget.onChangeColor(value);
              });
            }),
            // paletteType: PaletteType.rgb,
            // showLabel: false,
            labelTypes: const [],
            showIndicator: false,
            enableAlpha: false,
            indicatorBorderRadius: const BorderRadius.vertical(
              top: Radius.circular(10.0),
            ),
          ),
        ],
      ),
    );
  }
}

const List<Color> _defaultColors = [
  Colors.transparent,
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.yellow,
  Colors.amber,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Color(0xfff2f3f4),
  Color(0xffe1e2e3),
  Color(0xffd1d0d0),
  Color(0xffb0b1b2),
  Colors.grey,
  Colors.blueGrey,
  Color(0xff3c3f41),
  Color(0xff313335),
  Color(0xff2b2b2b),
  Color(0xff252626),
  Color(0xff202020),
  Color(0xff101010),
  Colors.black,
];
