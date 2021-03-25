import 'dart:ui' as ui;

import 'package:flutter/material.dart';
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
  }
  if (config.showInfo) {
    final styleInfo = TextStyle(
      fontSize: 12,
      fontFamily: config.fontFamily,
      color: config.fontColor,
    );
    tp.text = TextSpan(text: page.info, style: styleInfo);
    tp.layout(maxWidth: size.width - config.leftPadding - config.rightPadding - 60);
    tp.paint(canvas, Offset(config.leftPadding, size.height - 24));

    tp.text = TextSpan(
      text: '${page.number}/${page.total} ${(100 * page.percent).toStringAsFixed(2)}%',
      style: styleInfo,
    );
    tp.layout();
    tp.paint(
        canvas, Offset(size.width - config.rightPadding - tp.width, size.height - 24));
  }
}

Widget menuBodyBuilder(BuildContext context, TextCompositionConfig config) {
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
      contentPadding: const EdgeInsets.all(6.0),
      content: TextField(controller: controller),
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

  return Material(
    child: StatefulBuilder(
      builder: (context, setState) {
        return ListView(
          children: [
            ListTile(title: Text("（注意：部分效果需要重进正文页或者下一章才生效，除背景图全部都可以生效")),
            Divider(),
            ListTile(title: Text("开关", style: style)),
            Divider(),
            SwitchListTile(
              value: config.justifyHeight,
              onChanged: (value) => setState(() => config.justifyHeight = value),
              title: Text("高度调整"),
              subtitle: Text("底部对齐 最底行对齐到相同位置"),
            ),
            SwitchListTile(
              value: config.showInfo,
              onChanged: (value) => setState(() => config.showInfo = value),
              title: Text("显示底部"),
              subtitle: Text("章节名（书名） 页数/总页数 百分比进度"),
            ),
            SwitchListTile(
              value: config.oneHand,
              onChanged: (value) => setState(() => config.oneHand = value),
              title: Text("单手模式"),
              subtitle: Text("点击左侧也是向下翻页"),
            ),
            ListTile(
              title: Row(
                children: [
                  Text("选择动画"),
                  Spacer(),
                  InkWell(
                    onTap: () => setState(() => config.animation = "cover"),
                    child: Text("覆盖", style: config.animation == "cover" ? style : null),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () => setState(() => config.animation = "curl"),
                    child: Text("仿真苹果", style: config.animation == "curl" ? style : null),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () => setState(() => config.animation = "simulation"),
                    child: Text("仿真安卓",
                        style: config.animation == "simulation" ? style : null),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text("动画时间（毫秒数）"),
              subtitle: Text(config.animationDuration.toString() + "（ms）"),
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
            Divider(),
            ListTile(
              title: Text("分栏数"),
              subtitle: Text("${config.columns}（0为自动 宽度超过590时两栏）"),
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
            ),
            ListTile(
              title: Text("背景 图片"),
              subtitle: Text(config.background),
            ),
            ListTile(
              title: Text("背景 纯色"),
              subtitle:
                  Text(config.backgroundColor.value.toRadixString(16).toUpperCase()),
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
    ),
  );
}
