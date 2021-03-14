// @dart = 2.12
library text_composition;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// * 暂不支持图片
/// * 文本排版
/// * 两端对齐
/// * 底栏对齐
class TextComposition {
  /// 待渲染文本内容
  /// 已经预处理: 不重新计算空行 不重新缩进
  final String? text;

  /// 待渲染文本内容
  /// 已经预处理: 不重新计算空行 不重新缩进
  late final List<String> _paragraphs;
  List<String> get paragraphs => _paragraphs;

  /// 容器大小
  final Size boxSize;

  /// 字体样式 字号 [size] 行高 [height] 字体 [family] 字色[Color]
  final TextStyle style;

  /// 标题
  final String? title;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 是否底栏对齐
  final bool shouldJustifyHeight;

  /// 段间距
  late final double paragraph;

  /// 每一页内容
  late final List<TextPage> _pages;
  List<TextPage> get pages => _pages;
  int get pageCount => _pages.length;

  /// 全部内容
  late final List<TextLine> _lines;
  List<TextLine> get lines => _lines;
  int get lineCount => _lines.length;

  final Pattern? linkPattern;
  final TextStyle? linkStyle;
  final String Function(String s)? linkText;
  // canvas 点击事件不生效
  // final void Function(String s)? onLinkTap;

  /// * 文本排版
  /// * 两端对齐
  /// * 底栏对齐
  ///
  ///
  /// * [text] 待渲染文本内容 已经预处理: 不重新计算空行 不重新缩进
  /// * [paragraphs] 待渲染文本内容 已经预处理: 不重新计算空行 不重新缩进
  /// * [paragraphs] 为空时使用[text], 否则忽略[text],
  /// * [style] 字体样式 字号 [size] 行高 [height] 字体 [family] 字色[Color]
  /// * [title] 标题
  /// * [titleStyle] 标题样式
  /// * [boxSize] 容器大小
  /// * [paragraph] 段间距
  /// * [shouldJustifyHeight] 是否底栏对齐
  /// * onLinkTap canvas 点击事件不生效
  TextComposition({
    List<String>? paragraphs,
    this.text,
    required this.style,
    this.title,
    this.titleStyle,
    required this.boxSize,
    this.paragraph = 10.0,
    this.shouldJustifyHeight = true,
    this.linkPattern,
    this.linkStyle,
    this.linkText,
    // this.onLinkTap,
  }) {
    _paragraphs = paragraphs ?? text?.split("\n") ?? <String>[];
    _pages = <TextPage>[];
    _lines = <TextLine>[];

    /// [tp] 只有一行的`TextPainter` [offset] 只有一行的`offset`
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    final offset = Offset(boxSize.width, 1);
    final size = style.fontSize ?? 14;
    // [_boxWidth] 仅用于判断段尾是否需要调整 [size] 准确性不重要
    final _boxWidth = boxSize.width - size;
    // [_boxHeight] 仅用作判断容纳下一行依据 [_height] 是否实际行高不重要
    final _boxHeight = boxSize.height - size * (style.height ?? 1.0);

    var pageHeight = 0.0;
    var startLine = 0;
    var isTitlePage = false;

    if (title != null && title!.isNotEmpty) {
      tp
        ..maxLines = null
        ..text = TextSpan(text: title, style: titleStyle)
        ..layout();
      pageHeight += tp.height + paragraph;
      tp.maxLines = 1;
      isTitlePage = true;
    }

    /// 下一页 判断分页 依据: `_boxHeight` `_boxHeight2`是否可以容纳下一行
    void newPage([bool shouldJustifyHeight = true]) {
      final endLine = lines.length;
      _pages.add(
          TextPage(startLine, endLine, pageHeight, isTitlePage, shouldJustifyHeight));
      pageHeight = 0;
      startLine = endLine;
      if (isTitlePage) isTitlePage = false;
    }

    /// 新段落
    void newParagraph() {
      if (pageHeight > _boxHeight) {
        newPage();
      } else {
        pageHeight += paragraph;
      }
    }

    for (var p in _paragraphs) {
      if (linkPattern != null && p.startsWith(linkPattern!)) {
        tp.text = TextSpan(text: p, style: linkStyle);
        tp.layout();
        lines.add(TextLine(link: true, text: p, height: pageHeight));
        pageHeight += tp.height;
        newParagraph();
      } else
        while (true) {
          tp.text = TextSpan(text: p, style: style);
          tp.layout(maxWidth: boxSize.width);
          final textCount = tp.getPositionForOffset(offset).offset;
          if (p.length == textCount) {
            lines.add(TextLine(
              text: p,
              height: pageHeight,
              shouldJustifyWidth: tp.width > _boxWidth,
            ));
            pageHeight += tp.height;
            newParagraph();
            break;
          } else {
            lines.add(TextLine(
                text: p.substring(0, textCount),
                height: pageHeight,
                shouldJustifyWidth: true));
            pageHeight += tp.height;
            p = p.substring(textCount);
            if (pageHeight > _boxHeight) {
              newPage();
            }
          }
        }
    }
    if (lines.length > startLine) {
      newPage(false);
    }
  }

  void paint(TextPage page, Canvas canvas, Size size, [bool debugPrint = false]) {
    if (debugPrint)
      print("****** [TextComposition paint start] [${DateTime.now()}] ******");
    final justify = shouldJustifyHeight && page.shouldJustifyHeight
        ? (boxSize.height - page.height) / (page.endLine - page.startLine)
        : 0.0;
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    if (page.isTitlePage) {
      tp.text = TextSpan(text: title, style: titleStyle);
      tp.layout();
      tp.paint(canvas, Offset.zero);
    }
    for (var i = 0, end = page.endLine - page.startLine; i < end; i++) {
      final line = lines[i + page.startLine];
      if (line.text.isEmpty) {
        continue;
      } else if (line.link) {
        tp.text = TextSpan(
          text: linkText?.call(line.text) ?? line.text,
          style: linkStyle,
        );
      } else if (line.shouldJustifyWidth) {
        tp.text = TextSpan(text: line.text, style: style);
        tp.layout();
        tp.text = TextSpan(
          text: line.text,
          style: style.copyWith(
            letterSpacing: (boxSize.width - tp.width) / line.text.length,
          ),
        );
      } else {
        tp.text = TextSpan(text: line.text, style: style);
      }
      final offset = Offset(0, line.height + justify * i);
      if (debugPrint) print("$offset ${line.text}");
      tp.layout();
      tp.paint(canvas, offset);
    }
    if (debugPrint)
      print("****** [TextComposition paint end  ] [${DateTime.now()}] ******");
  }

  /// [debug] 查看时间输出
  Widget getPageWidget(TextPage page, [bool debugPrint = false]) {
    final child = CustomPaint(painter: PagePainter(this, page, debugPrint));
    return Container(
      width: boxSize.width,
      height: boxSize.height.isInfinite ? page.height : boxSize.height,
      child: child,
    );
  }
}

class PagePainter extends CustomPainter {
  final TextComposition textComposition;
  final TextPage page;
  final bool debugPrint;
  PagePainter(this.textComposition, this.page, this.debugPrint);

  @override
  void paint(Canvas canvas, Size size) {
    textComposition.paint(page, canvas, size, debugPrint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}

class TextPage {
  final int startLine;
  final int endLine;
  final double height;
  final bool isTitlePage;
  final bool shouldJustifyHeight;
  TextPage(
    this.startLine,
    this.endLine,
    this.height,
    this.isTitlePage,
    this.shouldJustifyHeight,
  );
}

class TextLine {
  final bool link;
  final String text;
  final double height;
  final bool shouldJustifyWidth;
  TextLine({
    this.link = false,
    required this.text,
    required this.height,
    this.shouldJustifyWidth = false,
  });
}
