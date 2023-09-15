import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'text_composition.dart';

const indentation = "　";

T cast<T>(x, T defaultValue) => x is T ? x : defaultValue; // 安全转换

void paintText(
    ui.Canvas canvas, ui.Size size, TextPage page, TextCompositionConfig config) {
  print("paintText ${page.chIndex} ${page.number} / ${page.total}");
  final lineCount = page.lines.length;
  final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
  final titleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: config.fontSize + 2,
    fontFamily: config.fontFamily,
    color: config.fontColor,
    height: config.fontHeight,
  );
  final style = TextStyle(
    fontSize: config.fontSize,
    fontFamily: config.fontFamily,
    color: config.fontColor,
    height: config.fontHeight,
  );
  final _lineHeight = config.fontSize * config.fontHeight;
  for (var i = 0; i < lineCount; i++) {
    final line = page.lines[i];
    if (line.letterSpacing != null &&
        (line.letterSpacing! < -0.1 || line.letterSpacing! > 0.1)) {
      tp.text = TextSpan(
        text: line.text,
        style: line.isTitle
            ? TextStyle(
                letterSpacing: line.letterSpacing,
                fontWeight: FontWeight.bold,
                fontSize: config.fontSize + 2,
                fontFamily: config.fontFamily,
                color: config.fontColor,
                height: config.fontHeight,
              )
            : TextStyle(
                letterSpacing: line.letterSpacing,
                fontSize: config.fontSize,
                fontFamily: config.fontFamily,
                color: config.fontColor,
                height: config.fontHeight,
              ),
      );
    } else {
      tp.text = TextSpan(text: line.text, style: line.isTitle ? titleStyle : style);
    }
    final offset = Offset(line.dx, line.dy);
    tp.layout();
    tp.paint(canvas, offset);
    if (config.underLine) {
      canvas.drawLine(
          Offset(line.dx, line.dy + _lineHeight),
          Offset(line.dx + page.column, line.dy + _lineHeight),
          Paint()..color = Colors.grey);
    }
  }
  if (config.showInfo) {
    final styleInfo = TextStyle(
      fontSize: 12,
      fontFamily: config.fontFamily,
      color: config.fontColor,
    );
    tp.text = TextSpan(text: page.info, style: styleInfo);
    tp.layout(maxWidth: size.width - config.leftPadding - config.rightPadding - 60);
    tp.paint(canvas, Offset(config.leftPadding, size.height - 20));

    tp.text = TextSpan(
      text: '${page.number}/${page.total} ${(100 * page.percent).toStringAsFixed(2)}%',
      style: styleInfo,
    );
    tp.layout();
    tp.paint(
        canvas, Offset(size.width - config.rightPadding - tp.width, size.height - 20));
  }
  if (page.columns == 2) {
    drawMiddleShadow(canvas, size);
  }
}

Decoration getDecoration(String background, Color backgroundColor) {
  DecorationImage? image;
  if (background.isEmpty || background == 'null') {
    // backgroundColor = Color(int.parse(background.substring(1), radix: 16));
  } else if (background.startsWith("assets")) {
    try {
      image = DecorationImage(
        image: AssetImage(background),
        fit: BoxFit.fill,
        onError: (_, __) {
          print(_);
          print(__);
          image = null;
        },
      );
    } catch (e) {}
  } else if (!background.startsWith("#")) {
    final file = File(background);
    if (file.existsSync()) {
      try {
        image = DecorationImage(
          image: FileImage(file),
          fit: BoxFit.fill,
          onError: (_, __) => image = null,
        );
      } catch (e) {}
    }
  }
  return BoxDecoration(
    color: backgroundColor,
    image: image,
  );
}

class _StyleItem {
  final Color bg;
  final Color text;
  final String img;
  const _StyleItem(this.bg, this.text, this.img);
}

Widget configSettingBuilder(
  BuildContext context,
  TextCompositionConfig config,
  void Function(Color color, void Function(Color color) onChange) onColor,
  void Function(String background, void Function(String background) onChange)
      onBackground,
  void Function(String fontFamily, void Function(String fontFamily) onChange)
      onFontFamily,
) {
  final style = TextStyle(color: Theme.of(context).primaryColor);

  AlertDialog showTextDialog(
    BuildContext context,
    String title,
    String s,
    void Function(String s) onPress, [
    bool isInt = false,
  ]) {
    TextEditingController controller = TextEditingController(text: s);
    return AlertDialog(
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
      ),
      title: Text(title),
      actions: [
        TextButton(
          child: Text(
            "取消",
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(
            "确定",
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            final s = (isInt ? RegExp("^\\d+\$") : RegExp("^\\d+(\\.\\d+)?\$"))
                .stringMatch(controller.text);
            if (s == null || s.isEmpty) {
              controller.text += isInt ? "只能输入整数" : "必须输入一个数";
              controller.selection =
                  TextSelection(baseOffset: 0, extentOffset: controller.text.length);
              return;
            }
            onPress(controller.text);
            Navigator.of(context).pop();
            Future.delayed(Duration(milliseconds: 200), () => controller.dispose());
          },
        ),
      ],
    );
  }

  final colors = [
    const _StyleItem(Color(0xFFFFFFCC), Color(0xFF303133), ''), //page_turn
    const _StyleItem(Color(0xfff1f1f1), Color(0xff373534), ''), //白底
    const _StyleItem(Color(0xfff5ede2), Color(0xff373328), ''), //浅黄
    const _StyleItem(Color(0xFFF5DEB3), Color(0xff373328), ''), //黄
    const _StyleItem(Color(0xffe3f8e1), Color(0xff485249), ''), //绿
    const _StyleItem(Color(0xff999c99), Color(0xff353535), ''), //浅灰
    const _StyleItem(Color(0xff33383d), Color(0xffc5c4c9), ''), //黑
    const _StyleItem(Color(0xff010203), Color(0xFfffffff), ''), //纯黑
    ///
    const _StyleItem(Color(0xFF303133), Color(0xFFFFFFCC), ''), //page_turn
    const _StyleItem(Color(0xff373534), Color(0xfff1f1f1), ''), //白底
    const _StyleItem(Color(0xff373328), Color(0xfff5ede2), ''), //浅黄
    const _StyleItem(Color(0xff373328), Color(0xFFF5DEB3), ''), //黄
    const _StyleItem(Color(0xff485249), Color(0xffe3f8e1), ''), //绿
    const _StyleItem(Color(0xff353535), Color(0xff999c99), ''), //浅灰
    const _StyleItem(Color(0xffc5c4c9), Color(0xff33383d), ''), //黑
    const _StyleItem(Color(0xFfffffff), Color(0xff010203), ''), //纯黑
    ///
    const _StyleItem(Color(0xffffffff), Color(0xff101010), "assets/bg/001.jpg"),
    const _StyleItem(Color(0xffffffff), Color(0xff101010), "assets/bg/002.jpg"),
    const _StyleItem(Color(0xffffffff), Color(0xff000000), "assets/bg/003.png"),
    const _StyleItem(Color(0xffffffff), Color(0xff102030), "assets/bg/004.jpg"),
    const _StyleItem(Color(0xff101010), Color(0xffc5c4c9), "assets/bg/005.jpg"),
    const _StyleItem(Color(0xfffefefe), Color(0xff353535), "assets/bg/006.jpg"),
    const _StyleItem(Color(0xff101010), Color(0xffc5c4c9), "assets/bg/007.jpg"),
    const _StyleItem(Color(0xfffefefe), Color(0xff010203), "assets/bg/008.png"),
  ];
  return StatefulBuilder(
    builder: (context, setState) {
      return ListView(
        children: [
          ListTile(title: Text("（注意：部分效果需要重进正文页或者下一章才生效或者过几页才生效")),
          Divider(),
          ListTile(title: Text("开关与选择", style: style)),
          Divider(),
          SwitchListTile(
            value: config.showStatus,
            onChanged: (value) {
              if (value) {
                SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
              } else {
                SystemChrome.setEnabledSystemUIOverlays([]);
              }
              setState(() => config.showStatus = value);
            },
            title: Text("显示状态栏"),
          ),
          SwitchListTile(
            value: config.showInfo,
            onChanged: (value) => setState(() => config.showInfo = value),
            title: Text("显示底部"),
            subtitle: Text("章节名（书名） 页数/总页数 百分比进度"),
          ),
          SwitchListTile(
            value: config.justifyHeight,
            onChanged: (value) => setState(() => config.justifyHeight = value),
            title: Text("高度调整"),
            subtitle: Text("底部对齐 最底行对齐到相同位置"),
          ),
          SwitchListTile(
            value: config.oneHand,
            onChanged: (value) => setState(() => config.oneHand = value),
            title: Text("单手模式"),
            subtitle: Text("点击左侧也是向下翻页"),
          ),
          SwitchListTile(
            value: config.underLine,
            onChanged: (value) => setState(() => config.underLine = value),
            title: Text("文字底部横线"),
            subtitle: Text("增加书籍仿真沉浸感"),
          ),
          SwitchListTile(
            value: config.animationStatus,
            onChanged: (value) => setState(() => config.animationStatus = value),
            title: Text("状态栏动画"),
            subtitle: Text("翻页动画可以越过状态栏"),
          ),
          SwitchListTile(
            value: config.animationHighImage,
            onChanged: (value) => setState(() => config.animationHighImage = value),
            title: Text("[仿真苹果] 高清模式"),
            subtitle: Text("打开后截图质量更高 关闭会更流畅"),
          ),
          SwitchListTile(
            value: config.animationWithImage,
            onChanged: (value) => setState(() => config.animationWithImage = value),
            title: Text("背景图跟随"),
            subtitle: Text("开启随翻页动画移动，关闭则固定"),
          ),
          ListTile(
            subtitle: Text('翻页动画选择，宽屏试试双栏加翻转（-是横向 | 是纵向 +是自动）'),
            title: Wrap(
              children: [
                for (var pair in <String, AnimationType>{
                  "仿真-": AnimationType.curl,
                  "覆盖+": AnimationType.cover,
                  // "水平覆盖": AnimationType.coverHorizontal,
                  // "垂直覆盖": AnimationType.coverVertical,
                  "翻转-": AnimationType.flip,
                  "卷轴-": AnimationType.simulation,
                  // "卷轴半左": AnimationType.simulation2L,
                  // "卷轴半右": AnimationType.simulation2R,
                  "滚动 |": AnimationType.scroll,
                  "滑动+": AnimationType.slide,
                  // "滑动水平": AnimationType.slideHorizontal,
                  // "滑动垂直": AnimationType.slideVertical,
                }.entries)
                  Container(
                    width: 80,
                    height: 30,
                    child: InkWell(
                      onTap: () => setState(() => config.animation = pair.value),
                      child: Center(
                        child: Text(pair.key,
                            style: config.animation == pair.value ? style : null),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            title: Text("动画时间（毫秒数）"),
            subtitle: Text(config.animationDuration.toString() + "(ms)"),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '动画时间（毫秒数）',
                config.animationDuration.toString(),
                (s) => setState(() => config.animationDuration = int.parse(s)),
                true,
              ),
            ),
          ),
          Divider(),
          ListTile(title: Text("文字与排版", style: style)),
          Container(
            decoration: BoxDecoration(border: Border.all()),
            margin: EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              decoration: getDecoration(config.background, config.backgroundColor),
              padding: EdgeInsets.fromLTRB(config.leftPadding, config.topPadding,
                  config.rightPadding, config.bottomPadding),
              child: Text(
                "${indentation * config.indentation}这是一段示例文字。This is an example sentence. This is another example sentence. 这是另一段示例文字。",
                maxLines: null,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: config.fontSize,
                  height: config.fontHeight,
                  color: config.fontColor,
                  fontFamily: config.fontFamily,
                ),
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              for (var c in colors)
                InkWell(
                  onTap: () => setState(() {
                    config.backgroundColor = c.bg;
                    config.background = c.img;
                    config.fontColor = c.text;
                  }),
                  child: Container(
                    decoration: getDecoration(c.img, c.bg),
                    padding: EdgeInsets.all(4),
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Text("文字", style: TextStyle(color: c.text)),
                  ),
                ),
            ],
          ),
          Divider(),
          ListTile(
            title: Text("分栏数"),
            subtitle: Text("${config.columns}（0为自动 宽度超过580时两栏）"),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '分栏数',
                config.columns.toString(),
                (s) => setState(() => config.columns = int.parse(s)),
                true,
              ),
            ),
          ),
          ListTile(
            title: Text("段落缩进"),
            subtitle: Text(config.indentation.toString()),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '段落缩进',
                config.indentation.toString(),
                (s) => setState(() => config.indentation = int.parse(s)),
                true,
              ),
            ),
          ),
          ListTile(
            title: Text("字色"),
            subtitle: Text(config.fontColor.value.toRadixString(16).toUpperCase()),
            onTap: () => onColor(
                config.fontColor, (color) => setState(() => config.fontColor = color)),
          ),
          ListTile(
            title: Text("字号"),
            subtitle: Text(config.fontSize.toStringAsFixed(1)),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '字号',
                config.fontSize.toStringAsFixed(1),
                (s) => setState(() => config.fontSize = double.parse(s)),
              ),
            ),
          ),
          ListTile(
            title: Text("行高"),
            subtitle: Text(config.fontHeight.toStringAsFixed(1)),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '行高',
                config.fontHeight.toStringAsFixed(1),
                (s) => setState(() => config.fontHeight = double.parse(s)),
              ),
            ),
          ),
          ListTile(
            title: Text("字体"),
            subtitle: Text(config.fontFamily.isEmpty ? "无" : config.fontFamily),
            onTap: () => onFontFamily(
                config.fontFamily, (font) => setState(() => config.fontFamily = font)),
          ),
          ListTile(
            title: Text("背景 纯色"),
            subtitle: Text(config.backgroundColor.value.toRadixString(16).toUpperCase()),
            onTap: () => onColor(
                config.backgroundColor,
                (color) => setState(() {
                      config.backgroundColor = color;
                      config.background = '';
                    })),
          ),
          ListTile(
            title: Text("背景 图片"),
            subtitle: Text(config.background),
            onTap: () => onBackground(config.background,
                (background) => setState(() => config.background = background)),
          ),
          Divider(),
          ListTile(title: Text("边距", style: style)),
          Divider(),
          ListTile(
            title: Text("上边距"),
            subtitle: Text(config.topPadding.toStringAsFixed(1)),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '上边距',
                config.topPadding.toStringAsFixed(1),
                (s) => setState(() => config.topPadding = double.parse(s)),
              ),
            ),
          ),
          ListTile(
            title: Text("左边距"),
            subtitle: Text(config.leftPadding.toStringAsFixed(1)),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '左边距',
                config.leftPadding.toStringAsFixed(1),
                (s) => setState(() => config.leftPadding = double.parse(s)),
              ),
            ),
          ),
          ListTile(
            title: Text("下边距"),
            subtitle: Text(config.bottomPadding.toStringAsFixed(1)),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '下边距',
                config.bottomPadding.toStringAsFixed(1),
                (s) => setState(() => config.bottomPadding = double.parse(s)),
              ),
            ),
          ),
          ListTile(
            title: Text("右边距"),
            subtitle: Text(config.rightPadding.toStringAsFixed(1)),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '右边距',
                config.rightPadding.toStringAsFixed(1),
                (s) => setState(() => config.rightPadding = double.parse(s)),
              ),
            ),
          ),
          ListTile(
            title: Text("标题与正文间距"),
            subtitle: Text(config.titlePadding.toStringAsFixed(1)),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '标题与正文间距',
                config.titlePadding.toStringAsFixed(1),
                (s) => setState(() => config.titlePadding = double.parse(s)),
              ),
            ),
          ),
          ListTile(
            title: Text("段间距"),
            subtitle: Text(config.paragraphPadding.toStringAsFixed(1)),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '段间距',
                config.paragraphPadding.toStringAsFixed(1),
                (s) => setState(() => config.paragraphPadding = double.parse(s)),
              ),
            ),
          ),
          ListTile(
            title: Text("分栏间距"),
            subtitle: Text(config.columnPadding.toStringAsFixed(1)),
            onTap: () => showDialog(
              context: context,
              builder: (context) => showTextDialog(
                context,
                '分栏间距',
                config.columnPadding.toStringAsFixed(1),
                (s) => setState(() => config.columnPadding = double.parse(s)),
              ),
            ),
          ),
        ],
      );
    },
  );
}
