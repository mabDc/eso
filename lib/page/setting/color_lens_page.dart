// import 'package:cupertino_lists/cupertino_lists.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../profile.dart';

class EditColorPage extends StatefulWidget {
  final Color pickerColor;
  final void Function(Color) onChangeColor;

  const EditColorPage(
      {@required this.pickerColor, @required this.onChangeColor, Key key})
      : super(key: key);

  @override
  State<EditColorPage> createState() => _EditColorPageState();
}

class _EditColorPageState extends State<EditColorPage> {
  Widget buildColorItem(
      {@required BuildContext context,
      @required Color pickerColor,
      @required ValueChanged<Color> onColorChanged,
      bool enableAlpha = true}) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // ListTile(
          //     title: Text(title,
          //         style: TextStyle(color: Theme.of(context).primaryColor))),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: BlockPicker(
              pickerColor: pickerColor,
              onColorChanged: onColorChanged,
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
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: SlidePicker(
              pickerColor: pickerColor,
              onColorChanged: onColorChanged,
              // paletteType: PaletteType.rgb,
              // showLabel: false,
              labelTypes: const [],
              showIndicator: false,
              enableAlpha: enableAlpha,
              indicatorBorderRadius: const BorderRadius.vertical(
                top: Radius.circular(10.0),
              ),
            ),
          ),
        ]);
  }

  Color pickerColor;

  @override
  void initState() {
    super.initState();
    pickerColor = widget.pickerColor;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            // automaticallyImplyLeading: false,
            middle: Text("主色"),
            border: null,
          ),
          child: SafeArea(
            // bottom: false,
            child: CustomScrollView(slivers: [
              SliverList(
                  delegate: SliverChildListDelegate([
                const SizedBox(height: 4),
                buildColorItem(
                    context: context,
                    pickerColor: pickerColor,
                    onColorChanged: ((value) {
                      setState(() {
                        pickerColor = value;
                        widget.onChangeColor(value);
                      });
                    })),
              ]))
            ]),
          )),
    );
  }
}

class ColorLensPage extends StatelessWidget {
  const ColorLensPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext rootcontext) {
    final profile = Provider.of<Profile>(rootcontext, listen: false);
    Color currentColor =
        Color(profile.primaryColor ?? CupertinoColors.systemBlue.value);
    void Function(Color color) changeColor =
        (Color color) => profile.primaryColor = color.value;

    Color backgroundColor = Color(profile.scaffoldBackgroundColor ??
        CupertinoColors.systemGroupedBackground.value);
    void Function(Color color) changeBackgroundColor =
        (Color color) => profile.scaffoldBackgroundColor = color.value;

    Color barBackgroundColor = Color(profile.barBackgroundColor ??
        CupertinoDynamicColor.withBrightness(
          color: Color(0xF0F9F9F9),
          darkColor: Color(0xF01D1D1D),
        ).value);
    void Function(Color color) changebarBackgroundColor =
        (Color color) => profile.barBackgroundColor = color.value;

    Color primaryTextColor =
        Color(profile.primaryTextColor ?? CupertinoColors.black.value);
    void Function(Color color) changeprimaryTextColor =
        (Color color) => profile.primaryTextColor = color.value;

    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          // transitionBetweenRoutes: false,
          border: null,
          trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                profile.primaryColor = CupertinoColors.systemBlue.value;
                profile.scaffoldBackgroundColor =
                    CupertinoColors.systemGroupedBackground.value;
                profile.primaryTextColor = CupertinoColors.black.value;
                profile.barBackgroundColor =
                    CupertinoDynamicColor.withBrightness(
                  // color: Colors.white,
                  color: Color(0xF0F9F9F9),
                  darkColor: Color(0xF01D1D1D),
                ).value;
              },
              child: Text("重置")),
          middle: Text(
            "修改主题色",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 21),
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  CupertinoListSection.insetGrouped(
                    // decoration: null,
                    backgroundColor: backgroundColor.withOpacity(0.1),
                    header: Text(
                      "主题颜色,暂时只对白天模式有效",
                      style: CupertinoTheme.of(rootcontext)
                          .textTheme
                          .textStyle
                          .copyWith(
                              fontSize: 13,
                              color: CupertinoDynamicColor.resolve(
                                  Profile().kHeaderFooterColor, rootcontext)),
                    ),
                    children: [
                      CupertinoListTile(
                        backgroundColor: backgroundColor.withOpacity(0.2),
                        title: Text("主色"),
                        additionalInfo: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                                color: Color(profile.primaryColor),
                                borderRadius: BorderRadius.circular(10))),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () {
                          showCupertinoModalBottomSheet(
                            expand: true,
                            context: rootcontext,
                            backgroundColor: Colors.transparent,
                            builder: (context) => EditColorPage(
                              pickerColor: currentColor,
                              onChangeColor: changeColor,
                            ),
                          );
                        },
                      ),
                      CupertinoListTile(
                        title: Text("背景色"),
                        backgroundColor: backgroundColor.withOpacity(0.2),
                        additionalInfo: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(10))),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () {
                          showCupertinoModalBottomSheet(
                            expand: true,
                            context: rootcontext,
                            backgroundColor: Colors.transparent,
                            builder: (context) => EditColorPage(
                              pickerColor: backgroundColor,
                              onChangeColor: changeBackgroundColor,
                            ),
                          );
                        },
                      ),
                      CupertinoListTile(
                        title: Text("导航栏颜色"),
                        backgroundColor: backgroundColor.withOpacity(0.2),
                        additionalInfo: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                                color: barBackgroundColor,
                                borderRadius: BorderRadius.circular(10))),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () {
                          showCupertinoModalBottomSheet(
                            expand: true,
                            context: rootcontext,
                            backgroundColor: Colors.transparent,
                            builder: (context) => EditColorPage(
                              pickerColor: barBackgroundColor,
                              onChangeColor: changebarBackgroundColor,
                            ),
                          );
                        },
                      ),
                      CupertinoListTile(
                        title: Text("文字颜色"),
                        backgroundColor: backgroundColor.withOpacity(0.2),
                        additionalInfo: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                                color: primaryTextColor,
                                borderRadius: BorderRadius.circular(10))),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () {
                          showCupertinoModalBottomSheet(
                            expand: true,
                            context: rootcontext,
                            backgroundColor: Colors.transparent,
                            builder: (context) => EditColorPage(
                              pickerColor: primaryTextColor,
                              onChangeColor: changeprimaryTextColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]
              // child: Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: [
              //     Card(
              //         child: buildColorItem(
              //       context: context,
              //       title: "主题色",
              //       pickerColor: currentColor,
              //       onColorChanged: changeColor,
              //       enableAlpha: false,
              //     )),
              //     const SizedBox(height: 4),
              //     Container(
              //       padding: EdgeInsets.symmetric(horizontal: 10),
              //       constraints: BoxConstraints(maxWidth: 320),
              //       child: ColorPicker(
              //         pickerColor: currentColor,
              //         onColorChanged: changeColor,
              //         pickerAreaHeightPercent: 0.6,
              //         enableAlpha: false,
              //       ),
              //     ),
              //     Divider(),
              //     Wrap(
              //       children: [
              //         SlidePicker(
              //           pickerColor: currentColor,
              //           onColorChanged: changeColor,
              //           colorModel: ColorModel.rgb,
              //           showIndicator: false,
              //           enableAlpha: false,
              //           indicatorBorderRadius: const BorderRadius.vertical(
              //             top: const Radius.circular(10.0),
              //           ),
              //         ),
              //         SlidePicker(
              //           pickerColor: currentColor,
              //           onColorChanged: changeColor,
              //           colorModel: ColorModel.hsl,
              //           showIndicator: false,
              //           enableAlpha: false,
              //           indicatorBorderRadius: const BorderRadius.vertical(
              //             top: const Radius.circular(10.0),
              //           ),
              //         ),
              //         SlidePicker(
              //           pickerColor: currentColor,
              //           onColorChanged: changeColor,
              //           colorModel: ColorModel.hsv,
              //           showIndicator: false,
              //           enableAlpha: false,
              //           indicatorBorderRadius: const BorderRadius.vertical(
              //             top: const Radius.circular(10.0),
              //           ),
              //         ),
              //       ],
              //     ),
              //     Divider(),
              //     BlockPicker(
              //       pickerColor: currentColor,
              //       onColorChanged: changeColor,
              //     ),
              //     Divider(),
              //     MaterialPicker(
              //       pickerColor: currentColor,
              //       onColorChanged: changeColor,
              //       enableLabel: true,
              //     ),
              //     Divider(),
              //   ],
              // ),
              ),
        ),
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
