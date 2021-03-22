library text_composition;

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// * 暂不支持图片
/// * 文本排版
/// * 两端对齐
/// * 底栏对齐
class TextComposition {
  /// 待渲染文本段落
  /// 已经预处理: 不重新计算空行 不重新缩进
  final List<String> paragraphs;

  /// 字体样式 字号 [size] 行高 [height] 字体 [family] 字色[Color]
  final TextStyle style;

  /// 标题
  final String? title;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 标题正文间距
  final double? titlePadding;

  /// 段间距
  final double paragraph;

  /// 每一页内容
  final List<TextPage> pages;

  int get pageCount => pages.length;

  /// 分栏个数
  final int columnCount;

  /// 分栏间距
  final double columnGap;

  /// 单栏宽度
  final double columnWidth;

  /// 容器大小
  final Size boxSize;

  /// 内部边距
  final EdgeInsets? padding;

  /// 是否底栏对齐
  final bool shouldJustifyHeight;

  /// 前景 页眉页脚 菜单等
  final Widget Function(int pageIndex)? getForeground;

  /// 背景 背景色或者背景图片
  final ui.Image Function(int pageIndex)? getBackground;

  /// 是否显示动画
  bool showAnimation;

  // final Pattern? linkPattern;
  // final TextStyle? linkStyle;
  // final String Function(String s)? linkText;

  // canvas 点击事件不生效
  // final void Function(String s)? onLinkTap;

  /// * 文本排版
  /// * 两端对齐
  /// * 底栏对齐
  /// * 多栏布局
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
  /// * [columnCount] 分栏个数
  /// * [columnGap] 分栏间距
  /// * onLinkTap canvas 点击事件不生效
  TextComposition({
    String? text,
    List<String>? paragraphs,
    required this.style,
    this.title,
    this.titleStyle,
    this.titlePadding,
    Size? boxSize,
    this.padding,
    this.shouldJustifyHeight = true,
    this.paragraph = 10.0,
    this.columnCount = 1,
    this.columnGap = 0.0,
    this.getForeground,
    this.getBackground,
    this.debug = false,
    List<TextPage>? pages,
    this.showAnimation = true,
    // this.linkPattern,
    // this.linkStyle,
    // this.linkText,
    // this.onLinkTap,
  })  : pages = pages ?? <TextPage>[],
        paragraphs = paragraphs ?? text?.split("\n") ?? <String>[],
        boxSize =
            boxSize ?? ui.window.physicalSize / ui.window.devicePixelRatio,
        columnWidth = ((boxSize?.width ??
                    ui.window.physicalSize.width / ui.window.devicePixelRatio) -
                (padding?.horizontal ?? 0) -
                (columnCount - 1) * columnGap) /
            columnCount {
    // [_width2] [_height2] 用于调整判断
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    final offset = Offset(columnWidth, 1);
    final size = style.fontSize ?? 14;
    final _dx = padding?.left ?? 0;
    final _dy = padding?.top ?? 0;
    final _width = columnWidth;
    final _width2 = _width - size;
    final _height = this.boxSize.height - (padding?.vertical ?? 0);
    final _height2 = _height - size * (style.height ?? 1.0);

    var lines = <TextLine>[];
    var columnNum = 1;
    var dx = _dx;
    var dy = _dy;
    var startLine = 0;

    if (title != null && title!.isNotEmpty) {
      String t = title!;
      while (true) {
        tp.text = TextSpan(text: title, style: titleStyle);
        tp.layout(maxWidth: _width);
        final textCount = tp.getPositionForOffset(offset).offset;
        final text = t.substring(0, textCount);
        double? spacing;
        if (tp.width > _width2) {
          tp.text = TextSpan(text: text, style: titleStyle);
          tp.layout();
          double _spacing = (_width - tp.width) / textCount;
          if (_spacing < -0.1 || _spacing > 0.1) {
            spacing = _spacing;
          }
        }
        lines.add(TextLine(text, dx, dy, spacing, true));
        dy += tp.height;
        if (t.length == textCount) {
          break;
        } else {
          t = t.substring(textCount);
        }
      }
    }

    /// 下一页 判断分页 依据: `_boxHeight` `_boxHeight2`是否可以容纳下一行
    void newPage([bool shouldJustifyHeight = true, bool lastPage = false]) {
      if (shouldJustifyHeight && this.shouldJustifyHeight) {
        final len = lines.length - startLine;
        double justify = (_height - dy) / (len - 1);
        for (var i = 0; i < len; i++) {
          lines[i + startLine].justifyDy(justify * i);
        }
      }
      if (columnNum == columnCount || lastPage) {
        this.pages.add(TextPage(lines, dy));
        lines = <TextLine>[];
        columnNum = 1;
        dx = _dx;
      } else {
        columnNum++;
        dx += columnWidth + columnGap;
      }
      dy = _dy;
      startLine = lines.length;
    }

    /// 新段落
    void newParagraph() {
      if (dy > _height2) {
        newPage();
      } else {
        dy += paragraph;
      }
    }

    for (var p in this.paragraphs) {
      while (true) {
        tp.text = TextSpan(text: p, style: style);
        tp.layout(maxWidth: columnWidth);
        final textCount = tp.getPositionForOffset(offset).offset;
        double? spacing;
        final text = p.substring(0, textCount);
        if (tp.width > _width2) {
          tp.text = TextSpan(text: text, style: style);
          tp.layout();
          spacing = (_width - tp.width) / textCount;
        }
        lines.add(TextLine(text, dx, dy, spacing));
        dy += tp.height;
        if (p.length == textCount) {
          newParagraph();
          break;
        } else {
          p = p.substring(textCount);
          if (dy > _height2) {
            newPage();
          }
        }
      }
    }
    if (lines.isNotEmpty) {
      newPage(false, true);
    }
    if (this.pages.length == 0) {
      this.pages.add(TextPage([], 0));
    }
  }

  /// 调试模式 输出布局信息
  bool debug;

  Widget getPageWidget([int pageIndex = 0]) {
    // if (pageIndex != null && !changePage(pageIndex)) return Container();
    return Container(
      width: boxSize.width,
      height:
          boxSize.height.isInfinite ? pages[pageIndex].height : boxSize.height,
      child: CustomPaint(
          painter: PagePainter(
              pageIndex, pages[pageIndex], style, titleStyle, debug)),
    );
  }

  Future<ui.Image?> getImage(int pageIndex) async {
    final recorder = ui.PictureRecorder();
    final canvas = new Canvas(recorder,
        Rect.fromPoints(Offset.zero, Offset(boxSize.width, boxSize.height)));
    PagePainter(pageIndex, pages[pageIndex], style, titleStyle, debug)
        .paint(canvas, boxSize);
    final picture = recorder.endRecording();
    return await picture.toImage(boxSize.width.floor(), boxSize.height.floor());
  }

  void paint(int pageIndex, Canvas canvas) {
    PagePainter(pageIndex, pages[pageIndex], style, titleStyle, debug)
        .paint(canvas, boxSize);
  }
}

class PagePainter extends CustomPainter {
  final TextPage page;
  final TextStyle style;
  final TextStyle? titleStyle;
  final int pageIndex;
  final bool debug;
  const PagePainter(this.pageIndex, this.page, this.style, this.titleStyle,
      [this.debug = false]);

  @override
  void paint(Canvas canvas, Size size) {
    if (debug)
      print("****** [TextComposition paint start] [${DateTime.now()}] ******");
    final lineCount = page.lines.length;
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    for (var i = 0; i < lineCount; i++) {
      final line = page.lines[i];
      if (line.letterSpacing != null &&
          (line.letterSpacing! < -0.1 || line.letterSpacing! > 0.1)) {
        tp.text = TextSpan(
          text: line.text,
          style: line.isTitle
              ? titleStyle?.copyWith(letterSpacing: line.letterSpacing)
              : style.copyWith(letterSpacing: line.letterSpacing),
        );
      } else {
        tp.text =
            TextSpan(text: line.text, style: line.isTitle ? titleStyle : style);
      }
      final offset = Offset(line.dx, line.dy);
      if (debug) print("$offset ${line.text}");
      tp.layout();
      tp.paint(canvas, offset);
    }
    if (debug)
      print("****** [TextComposition paint end  ] [${DateTime.now()}] ******");
  }

  @override
  bool shouldRepaint(PagePainter old) {
    print("shouldRepaint");
    return old.pageIndex != pageIndex;
  }
}

class TextPage {
  final List<TextLine> lines;
  final double height;
  const TextPage(this.lines, this.height);
}

class TextLine {
  final String text;
  double dx;
  double _dy;
  double get dy => _dy;
  final double? letterSpacing;
  final bool isTitle;
  TextLine(
    this.text,
    this.dx,
    double dy, [
    this.letterSpacing = 0,
    this.isTitle = false,
  ]) : _dy = dy;

  justifyDy(double offsetDy) {
    _dy += offsetDy;
  }
}
