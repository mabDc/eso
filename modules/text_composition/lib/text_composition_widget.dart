import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'text_composition.dart';

class TextCompositionWidget extends StatelessWidget {
  final TextCompositionConfig config;
  final double? width;
  final List<String> paragraphs;
  final bool debug;

  const TextCompositionWidget({
    Key? key,
    this.width,
    this.debug = false,
    required this.config,
    required this.paragraphs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final page = getOnePage(paragraphs, config, width);
    return Container(
      height: page.height,
      width: width,
      child: CustomPaint(painter: SimpleWidgetPainter(key, page.lines, config, debug)),
    );
  }
}

TextPage getOnePage(
    List<String> paragraphs, TextCompositionConfig config, double? width) {
  width ??= ui.window.physicalSize.width / ui.window.devicePixelRatio;
  width -= config.leftPadding + config.rightPadding;
  final width2 = width - config.fontSize;
  final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
  final offset = Offset(width, 1);
  final lines = <TextLine>[];
  final style = TextStyle(
    fontSize: config.fontSize,
    fontFamily: config.fontFamily,
    color: config.fontColor,
  );
  var dx = config.leftPadding, dy = config.topPadding;
  for (var p in paragraphs) {
    p = indentation * config.indentation + p;
    while (true) {
      tp.text = TextSpan(text: p, style: style);
      tp.layout(maxWidth: width);
      final textCount = tp.getPositionForOffset(offset).offset;
      double? spacing;
      final text = p.substring(0, textCount);
      if (tp.width > width2) {
        tp.text = TextSpan(text: text, style: style);
        tp.layout();
        final _spacing = (width - tp.width) / textCount;
        if (_spacing < -0.1 || _spacing > 0.1) spacing = _spacing;
      }
      lines.add(TextLine(text, dx, dy, spacing));
      dy += tp.height;
      if (p.length == textCount) {
        dy += config.paragraphPadding;
        break;
      } else {
        p = p.substring(textCount);
      }
    }
  }
  return TextPage(height: dy + config.bottomPadding, lines: lines, number: 1, column: width, columns: 1);
}

class SimpleWidgetPainter extends CustomPainter {
  final List<TextLine> lines;
  final TextCompositionConfig config;
  final bool debug;
  final Key? key;
  const SimpleWidgetPainter(this.key, this.lines, this.config, this.debug);

  @override
  void paint(Canvas canvas, Size size) {
    if (debug) print("****** [TextComposition paint start] [${DateTime.now()}] ******");
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    lines.forEach((line) {
      tp.text = TextSpan(
          text: line.text,
          style: TextStyle(
            fontSize: config.fontSize,
            fontFamily: config.fontFamily,
            letterSpacing: line.letterSpacing,
            color: config.fontColor,
          ));
      final offset = Offset(line.dx, line.dy);
      if (debug) print("$offset ${line.text}");
      tp.layout();
      tp.paint(canvas, offset);
    });
    if (debug) print("****** [TextComposition paint end  ] [${DateTime.now()}] ******");
  }

  @override
  bool shouldRepaint(SimpleWidgetPainter old) {
    return key != key || lines.length != lines.length;
  }
}
