library text_composition;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const indentation = "　";

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
  return TextPage(height: dy + config.bottomPadding, lines: lines, index: 0);
}

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
      child:
          CustomPaint(painter: SimpleLinesPainter(page.lines, config, debug)),
    );
  }
}

class SimpleLinesPainter extends CustomPainter {
  final List<TextLine> lines;
  final TextCompositionConfig config;
  final bool debug;
  const SimpleLinesPainter(this.lines, this.config, this.debug);

  @override
  void paint(Canvas canvas, Size size) {
    if (debug)
      print("****** [TextComposition paint start] [${DateTime.now()}] ******");
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
    if (debug)
      print("****** [TextComposition paint end  ] [${DateTime.now()}] ******");
  }

  @override
  bool shouldRepaint(SimpleLinesPainter old) {
    return true;
  }
}

/// + 这里配置需要离线保存和加载
/// + 其他配置实时计算
///
/// - [animationTap]
/// - [animationDrag]
/// - [animationDragEnd]
/// - [justifyHeight]
/// - [showInfo]
/// - [topPadding]
/// - [leftPadding]
/// - [bottomPadding]
/// - [rightPadding]
/// - [titlePadding]
/// - [paragraphPadding]
/// - [columnPadding]
/// - [columns]
/// - [indentation]
/// - [fontColor]
/// - [fontSize]
/// - [fontHeight]
/// - [fontFamily]
/// - [background]
class TextCompositionConfig {
  /// bool
  bool animationTap;
  bool animationDrag;
  bool animationDragEnd;
  bool justifyHeight;
  bool showInfo; // info size - 100px, index/total percent - right 100px

  /// padding
  double topPadding;
  double leftPadding;
  double bottomPadding;
  double rightPadding;
  double titlePadding;
  double paragraphPadding;
  double columnPadding;

  /// font
  int columns; // <1 <==> auto
  int indentation;
  Color fontColor;
  double fontSize;
  double fontHeight;
  String? fontFamily;

  // string
  String background;

  TextCompositionConfig({
    this.animationTap = true,
    this.animationDrag = true,
    this.animationDragEnd = true,
    this.justifyHeight = true,
    this.showInfo = true,
    this.topPadding = 10,
    this.leftPadding = 10,
    this.bottomPadding = 10,
    this.rightPadding = 10,
    this.titlePadding = 30,
    this.paragraphPadding = 10,
    this.columnPadding = 30,
    this.columns = 0,
    this.indentation = 2,
    this.fontColor = const Color(0xFF303133),
    this.fontSize = 18,
    this.fontHeight = 1.6,
    this.fontFamily,
    this.background = '#FFFFFFCC',
  });

  bool updateTextCompositionConfig({
    bool? animationTap,
    bool? animationDrag,
    bool? animationDragEnd,
    bool? justifyHeight,
    bool? showInfo,
    double? topPadding,
    double? leftPadding,
    double? bottomPadding,
    double? rightPadding,
    double? titlePadding,
    double? paragraphPadding,
    double? columnPadding,
    int? columns,
    int? indentation,
    Color? fontColor,
    double? fontSize,
    double? fontHeight,
    String? background,
  }) {
    bool? update;

    if (animationTap != null && this.animationTap != animationTap) {
      this.animationTap = animationTap;
      update ??= true;
    }
    if (animationDrag != null && this.animationDrag != animationDrag) {
      this.animationDrag = animationDrag;
      update ??= true;
    }
    if (animationDragEnd != null && this.animationDragEnd != animationDragEnd) {
      this.animationDragEnd = animationDragEnd;
      update ??= true;
    }
    if (justifyHeight != null && this.justifyHeight != justifyHeight) {
      this.justifyHeight = justifyHeight;
      update ??= true;
    }
    if (showInfo != null && this.showInfo != showInfo) {
      this.showInfo = showInfo;
      update ??= true;
    }
    if (topPadding != null && this.topPadding != topPadding) {
      this.topPadding = topPadding;
      update ??= true;
    }
    if (leftPadding != null && this.leftPadding != leftPadding) {
      this.leftPadding = leftPadding;
      update ??= true;
    }
    if (bottomPadding != null && this.bottomPadding != bottomPadding) {
      this.bottomPadding = bottomPadding;
      update ??= true;
    }
    if (rightPadding != null && this.rightPadding != rightPadding) {
      this.rightPadding = rightPadding;
      update ??= true;
    }
    if (titlePadding != null && this.titlePadding != titlePadding) {
      this.titlePadding = titlePadding;
      update ??= true;
    }
    if (paragraphPadding != null && this.paragraphPadding != paragraphPadding) {
      this.paragraphPadding = paragraphPadding;
      update ??= true;
    }
    if (columnPadding != null && this.columnPadding != columnPadding) {
      this.columnPadding = columnPadding;
      update ??= true;
    }
    if (columns != null && this.columns != columns) {
      this.columns = columns;
      update ??= true;
    }
    if (indentation != null && this.indentation != indentation) {
      this.indentation = indentation;
      update ??= true;
    }
    if (fontColor != null && this.fontColor != fontColor) {
      this.fontColor = fontColor;
      update ??= true;
    }
    if (fontSize != null && this.fontSize != fontSize) {
      this.fontSize = fontSize;
      update ??= true;
    }
    if (fontHeight != null && this.fontHeight != fontHeight) {
      this.fontHeight = fontHeight;
      update ??= true;
    }
    if (fontFamily != null && this.fontFamily != fontFamily) {
      this.fontFamily = fontFamily;
      update ??= true;
    }
    if (background != null && this.background != background) {
      this.background = background;
      update ??= true;
    }

    return update == true;
  }

  /// Creates an instance of this class from a JSON object.
  factory TextCompositionConfig.fromJSON(Map<String, dynamic> encoded) {
    return TextCompositionConfig(
      // text: encoded['text'] as String,
      animationTap: encoded['animationTap'] ?? true,
      animationDrag: encoded['animationDrag'] ?? true,
      animationDragEnd: encoded['animationDragEnd'] ?? true,
      justifyHeight: encoded['justifyHeight'] ?? true,
      showInfo: encoded['showInfo'] ?? true,
      topPadding: encoded['topPadding'] ?? 10,
      leftPadding: encoded['leftPadding'] ?? 10,
      bottomPadding: encoded['bottomPadding'] ?? 10,
      rightPadding: encoded['rightPadding'] ?? 10,
      titlePadding: encoded['titlePadding'] ?? 30,
      paragraphPadding: encoded['paragraphPadding'] ?? 10,
      columnPadding: encoded['columnPadding'] ?? 30,
      columns: encoded['columns'] ?? 0,
      indentation: encoded['indentation'] ?? 2,
      fontColor: Color(encoded['fontColor'] ?? 0xFF303133),
      fontSize: encoded['fontSize'] ?? 18,
      fontHeight: encoded['fontHeight'] ?? 1.6,
      fontFamily: encoded['fontFamily'],
      background: encoded['background'] ?? '#FFFFFFCC',
    );
  }

  /// Returns a representation of this object as a JSON object.
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'animationTap': animationTap,
      'animationDrag': animationDrag,
      'animationDragEnd': animationDragEnd,
      'justifyHeight': justifyHeight,
      'showInfo': showInfo,
      'topPadding': topPadding,
      'leftPadding': leftPadding,
      'bottomPadding': bottomPadding,
      'rightPadding': rightPadding,
      'titlePadding': titlePadding,
      'paragraphPadding': paragraphPadding,
      'columnPadding': columnPadding,
      'columns': columns,
      'indentation': indentation,
      'fontColor': fontColor.value,
      'fontSize': fontSize,
      'fontHeight': fontHeight,
      'fontFamily': fontFamily,
      'background': background,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextCompositionConfig &&
        other.animationTap == animationTap &&
        other.animationDrag == animationDrag &&
        other.animationDragEnd == animationDragEnd &&
        other.justifyHeight == justifyHeight &&
        other.showInfo == showInfo &&
        other.topPadding == topPadding &&
        other.leftPadding == leftPadding &&
        other.bottomPadding == bottomPadding &&
        other.rightPadding == rightPadding &&
        other.titlePadding == titlePadding &&
        other.paragraphPadding == paragraphPadding &&
        other.columnPadding == columnPadding &&
        other.columns == columns &&
        other.indentation == indentation &&
        other.fontColor == fontColor &&
        other.fontSize == fontSize &&
        other.fontHeight == fontHeight &&
        other.fontFamily == fontFamily &&
        other.background == background;
  }

  @override
  int get hashCode => super.hashCode;
}

class TextPage {
  String info;
  double index;
  double total;
  double chIndex;
  double chTotal;
  final double height;
  final List<TextLine> lines;

  TextPage({
    required this.index,
    required this.height,
    required this.lines,
    this.info = '',
    this.total = 1,
    this.chIndex = 0,
    this.chTotal = 1,
  });
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

/// 样式设置与刷新
/// 动画设置与刷新
class TextCompositionController extends ValueNotifier<TextCompositionConfig> {
  TextCompositionController(TextCompositionConfig textCompositionConfig)
      : super(textCompositionConfig);
}

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
        this.pages.add(TextPage(lines: lines, height: dy, index: 0));
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
      this
          .pages
          .add(TextPage(lines: [], height: padding?.horizontal ?? 0, index: 0));
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
