library text_composition;

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const indentation = "　";
T cast<T>(x, T defaultValue) => x is T ? x : defaultValue; // 安全转换

TextPage getOnePage(List<String> paragraphs, TextCompositionConfig config, double? width) {
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
  return TextPage(height: dy + config.bottomPadding, lines: lines, number: 1);
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
      child: CustomPaint(painter: SimpleLinesPainter(page.lines, config, debug)),
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
/// - [animation]
/// - [animationDuration]
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
  String animation;
  int animationDuration;

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
  String fontFamily;

  // string
  String background;

  TextCompositionConfig({
    this.animationTap = true,
    this.animationDrag = true,
    this.animationDragEnd = true,
    this.justifyHeight = true,
    this.showInfo = true,
    this.animation = 'curl',
    this.animationDuration = 300,
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
    this.fontFamily = '',
    this.background = '#FFFFFFCC',
  });

  bool updateConfig({
    bool? animationTap,
    bool? animationDrag,
    bool? animationDragEnd,
    bool? justifyHeight,
    bool? showInfo,
    String? animation,
    int? animationDuration,
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
    String? fontFamily,
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
    if (animation != null && this.animation != animation) {
      this.animation = animation;
      update ??= true;
    }
    if (animationDuration != null && this.animationDuration != animationDuration) {
      this.animationDuration = animationDuration;
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
      animationTap: cast(encoded['animationTap'], true),
      animationDrag: cast(encoded['animationDrag'], true),
      animationDragEnd: cast(encoded['animationDragEnd'], true),
      justifyHeight: cast(encoded['justifyHeight'], true),
      showInfo: cast(encoded['showInfo'], true),
      animation: cast(encoded['animation'], 'curl'),
      animationDuration: cast(encoded['animationDuration'], 300),
      topPadding: cast(encoded['topPadding'], 10),
      leftPadding: cast(encoded['leftPadding'], 10),
      bottomPadding: cast(encoded['bottomPadding'], 10),
      rightPadding: cast(encoded['rightPadding'], 10),
      titlePadding: cast(encoded['titlePadding'], 30),
      paragraphPadding: cast(encoded['paragraphPadding'], 10),
      columnPadding: cast(encoded['columnPadding'], 30),
      columns: cast(encoded['columns'], 0),
      indentation: cast(encoded['indentation'], 2),
      fontColor: Color(cast(encoded['fontColor'], 0xFF303133)),
      fontSize: cast(encoded['fontSize'], 18),
      fontHeight: cast(encoded['fontHeight'], 1.6),
      fontFamily: cast(encoded['fontFamily'], ''),
      background: cast(encoded['background'], '#FFFFFFCC'),
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
      'animation': animation,
      'animationDuration': animationDuration,
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
        other.animation == animation &&
        other.animationDuration == animationDuration &&
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
  double percent;
  int number;
  int total;
  int chIndex;
  String info;
  final double height;
  final List<TextLine> lines;

  TextPage({
    this.percent = 0.0,
    required this.number,
    this.total = 1,
    this.chIndex = 0,
    this.info = '',
    required this.height,
    required this.lines,
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
class TextCompositionController extends ChangeNotifier {
  final TextCompositionConfig config;
  late final Duration duration;
  final FutureOr<List<String>> Function(int chapterIndex) loadChapter;
  final FutureOr Function(TextCompositionConfig config, double percent)? onSave;
  final FutureOr Function()? onToggleMenu;
  final Widget Function()? buildMenu;
  final String? name;
  final List<String> chapters;
  int get chapterTotal => chapters.length;

  double _percent;
  double get percent => _percent;

  int? _pageIndex;
  int? get pageIndex => _pageIndex;
  late int _chapterIndex;
  int get chapterIndex => _chapterIndex;

  Map<int, List<TextPage>> cache;
  List<TextPage> pages;

  TextCompositionController({
    required this.config,
    required this.loadChapter,
    required this.chapters,
    this.name,
    this.onSave,
    this.onToggleMenu,
    this.buildMenu,
    percent = 0.0,
  })  : this._percent = percent,
        pages = <TextPage>[],
        cache = {} {
    _chapterIndex = (_percent * chapterTotal).floor();
    duration = Duration(milliseconds: config.animationDuration);
    init();
  }

  init() async {
    pages = await startX(_chapterIndex);
    notifyListeners();
    // Future.delayed(duration).then((value) async {
    //   if (!lastChapter) cache[_chapterIndex + 1] = await startX(_chapterIndex + 1);
    //   if (!firstChapter) cache[_chapterIndex - 1] = await startX(_chapterIndex - 1);
    // });
  }

  void updateConfig({
    bool? animationTap,
    bool? animationDrag,
    bool? animationDragEnd,
    bool? justifyHeight,
    bool? showInfo,
    String? animation,
    int? animationDuration,
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
    String? fontFamily,
    String? background,
  }) {
    if (config.updateConfig(
      animationTap: animationTap,
      animationDrag: animationDrag,
      animationDragEnd: animationDragEnd,
      justifyHeight: justifyHeight,
      showInfo: showInfo,
      animation: animation,
      animationDuration: animationDuration,
      topPadding: topPadding,
      leftPadding: leftPadding,
      bottomPadding: bottomPadding,
      rightPadding: rightPadding,
      titlePadding: titlePadding,
      paragraphPadding: paragraphPadding,
      columnPadding: columnPadding,
      columns: columns,
      indentation: indentation,
      fontColor: fontColor,
      fontSize: fontSize,
      fontHeight: fontHeight,
      fontFamily: fontFamily,
      background: background,
    )) notifyListeners();
  }

  bool get firstChapter => _chapterIndex <= 0;
  bool get lastChapter => _chapterIndex >= chapterTotal;

  Future<void> previousChapter() async {
    if (firstChapter) return;
    _chapterIndex = _chapterIndex - 1;
    if (cache[_chapterIndex] != null && cache[_chapterIndex]!.isNotEmpty) {
      pages = cache[_chapterIndex]!;
      notifyListeners();
    }
    // Future.delayed(duration).then((value) async {
    //   if (!firstChapter) cache[_chapterIndex - 1] = await startX(_chapterIndex - 1);
    // });
  }

  Future<void> nextChapter() async {
    if (lastChapter) return;
    _chapterIndex = _chapterIndex + 1;
    if (cache[_chapterIndex] != null && cache[_chapterIndex]!.isNotEmpty) {
      pages = cache[_chapterIndex]!;
      notifyListeners();
    }
    // Future.delayed(Duration(milliseconds: 300)).then((value) async {
    //   if (!firstChapter) cache[_chapterIndex + 1] = await startX(_chapterIndex + 1);
    // });
  }

  Future<List<TextPage>> startX(int index) async {
    final pages = <TextPage>[];
    final paragraphs = await loadChapter(index);
    final size = ui.window.physicalSize / ui.window.devicePixelRatio;
    final columns = config.columns > 0
        ? config.columns
        : size.width > 1200
            ? 3
            : size.width > 580
                ? 2
                : 1;
    final _width =
        (size.width - config.leftPadding - config.rightPadding - (columns - 1) * config.columnPadding) / columns;
    final _width2 = _width - config.fontSize;
    final _height = size.height - config.topPadding - config.bottomPadding - (config.showInfo ? 24 : 0);
    final _height2 = _height - config.fontSize * config.fontHeight;

    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    final offset = Offset(_width, 1);
    final _dx = config.leftPadding;
    final _dy = config.topPadding;

    var lines = <TextLine>[];
    var columnNum = 1;
    var dx = _dx;
    var dy = _dy;
    var startLine = 0;

    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: config.fontSize,
      fontFamily: config.fontFamily,
      color: config.fontColor,
    );
    final style = TextStyle(
      fontSize: config.fontSize,
      fontFamily: config.fontFamily,
      color: config.fontColor,
    );

    // String t = chapters[index].replaceAll(RegExp("^\s*|\n|\s\$"), "");
    final chapter = chapters[index];
    var _t = chapter.isEmpty ? "第$index章" : chapter;
    while (true) {
      tp.text = TextSpan(text: _t, style: titleStyle);
      tp.layout(maxWidth: _width);
      final textCount = tp.getPositionForOffset(offset).offset;
      final text = _t.substring(0, textCount);
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
      if (_t.length == textCount) {
        break;
      } else {
        _t = _t.substring(textCount);
      }
    }
    dy += config.titlePadding;

    var pageIndex = 1;

    /// 下一页 判断分页 依据: `_boxHeight` `_boxHeight2`是否可以容纳下一行
    void newPage([bool shouldJustifyHeight = true, bool lastPage = false]) {
      if (shouldJustifyHeight && config.justifyHeight) {
        final len = lines.length - startLine;
        double justify = (_height - dy) / (len - 1);
        for (var i = 0; i < len; i++) {
          lines[i + startLine].justifyDy(justify * i);
        }
      }
      if (columnNum == columns || lastPage) {
        pages.add(TextPage(lines: lines, height: dy, number: pageIndex++, info: chapter));
        lines = <TextLine>[];
        columnNum = 1;
        dx = _dx;
      } else {
        columnNum++;
        dx += _width + config.columnPadding;
      }
      dy = _dy;
      startLine = lines.length;
    }

    /// 新段落
    void newParagraph() {
      if (dy > _height2) {
        newPage();
      } else {
        dy += config.paragraphPadding;
      }
    }

    for (var p in paragraphs) {
      p = indentation * config.indentation + p;
      while (true) {
        tp.text = TextSpan(text: p, style: style);
        tp.layout(maxWidth: _width);
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
    if (pages.length == 0) {
      pages.add(TextPage(lines: [], height: config.topPadding + config.bottomPadding, number: 1, info: chapter));
    }

    final basePercent = index / chapterTotal;
    final total = pages.length;
    pages.forEach((page) {
      page.total = total;
      page.percent = (page.number / pages.length + index) / chapterTotal + basePercent;
    });
    return pages;
  }
}

class TextCompositionEffect extends CustomPainter {
  TextCompositionEffect({
    required this.amount,
    required this.backgroundColor,
    required this.page,
    required this.config,
    this.radius = 0.18,
  }) : super(repaint: amount);

  final Animation<double> amount;
  ui.Image? image;
  final Color backgroundColor;
  final double radius;
  final TextPage page;
  final TextCompositionConfig config;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final pos = amount.value;
    if (pos < 0.001) return;

    final movX = (1.0 - pos) * 0.85;
    final calcR = (movX < 0.20) ? radius * movX * 5 : radius;
    final wHRatio = 1 - calcR;

    final w = size.width.toDouble();
    final h = size.height.toDouble();
    final c = canvas;
    final shadowXf = (wHRatio - movX);
    final shadowSigma = Shadow.convertRadiusToSigma(8.0 + (32.0 * (1.0 - shadowXf)));
    final pageRect = Rect.fromLTRB(0.0, 0.0, w * shadowXf, h);
    c.drawRect(pageRect, Paint()..color = backgroundColor);
    c.drawRect(
      pageRect,
      Paint()
        ..color = Colors.black54
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, shadowSigma),
    );

    if (image == null) {
      final pic = ui.PictureRecorder();
      paintText(Canvas(pic), size);
      pic.endRecording().toImage(size.width.round(), size.height.round()).then((value) => image = value);
    }

    if (pos > 0.996) {
      paintText(canvas, size);
      return;
    }

    final hWRatio = image!.height / image!.width;
    final hWCorrection = (hWRatio - 1.0) / 2.0;
    final ip = Paint();
    if (config.animation == 'curl') {
      for (double x = 0; x < size.width; x++) {
        final xf = (x / w);
        final v = (calcR * (math.sin(math.pi / 0.5 * (xf - (1.0 - pos)))) + (calcR * 1.1));
        final xv = (xf * wHRatio) - movX;
        final sx = (xf * image!.width);
        final sr = Rect.fromLTRB(sx, 0.0, sx + 1.0, image!.height.toDouble());
        final yv = ((h * calcR * movX) * hWRatio) - hWCorrection;
        final ds = (yv * v);
        final dr = Rect.fromLTRB(xv * w, 0.0 - ds, xv * w + 1.0, h + ds);
        c.drawImageRect(image!, sr, dr, ip);
      }
    } else if (config.animation == 'cover') {
      c.drawImage(image!, Offset(-size.width + w * shadowXf, 0), ip);
    }
  }

  void paintText(ui.Canvas canvas, ui.Size size) {
    final lineCount = page.lines.length;
    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    final titleStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: config.fontSize,
      fontFamily: config.fontFamily,
      color: config.fontColor,
    );
    final style = TextStyle(
      fontSize: config.fontSize,
      fontFamily: config.fontFamily,
      color: config.fontColor,
    );
    for (var i = 0; i < lineCount; i++) {
      final line = page.lines[i];
      if (line.letterSpacing != null && (line.letterSpacing! < -0.1 || line.letterSpacing! > 0.1)) {
        tp.text = TextSpan(
          text: line.text,
          style: line.isTitle
              ? TextStyle(
                  letterSpacing: line.letterSpacing,
                  fontWeight: FontWeight.bold,
                  fontSize: config.fontSize,
                  fontFamily: config.fontFamily,
                  color: config.fontColor,
                )
              : TextStyle(
                  letterSpacing: line.letterSpacing,
                  fontSize: config.fontSize,
                  fontFamily: config.fontFamily,
                  color: config.fontColor,
                ),
        );
      } else {
        tp.text = TextSpan(text: line.text, style: line.isTitle ? titleStyle : style);
      }
      final offset = Offset(line.dx, line.dy);
      tp.layout();
      tp.paint(canvas, offset);
    }
    final style2 = TextStyle(
      fontSize: 10,
      fontFamily: config.fontFamily,
      color: config.fontColor,
    );

    tp.text = TextSpan(text: page.info, style: style2);
    tp.layout(
      maxWidth: size.width - config.leftPadding - config.rightPadding - 100,
    );
    tp.paint(canvas, Offset(config.leftPadding, size.height - 24));

    tp.text = TextSpan(
      text: '${page.number}/${page.total} ${(100 * page.percent).toStringAsFixed(2)}%',
      style: style2,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(size.width - config.rightPadding - tp.width, size.height - 24),
    );
  }

  @override
  bool shouldRepaint(TextCompositionEffect oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.amount.value != amount.value ||
        page.number != oldDelegate.page.number ||
        page.chIndex != oldDelegate.page.chIndex;
  }
}

class TextComposition extends StatefulWidget {
  TextComposition({
    Key? key,
    this.cutoffPrevious = 8,
    this.cutoffNext = 92,
    required this.controller,
    required this.lastPage,
  }) : super(key: key);

  final int cutoffNext;
  final int cutoffPrevious;
  final TextCompositionController controller;
  final Widget lastPage;

  @override
  TextCompositionState createState() => TextCompositionState();
}

class TextCompositionState extends State<TextComposition> with TickerProviderStateMixin {
  int pageNumber = 0;
  List<Widget> pages = [];

  List<AnimationController> _controllers = [];
  bool? _isForward;

  @override
  void didUpdateWidget(TextComposition oldWidget) {
    // if (oldWidget.duration != widget.duration) {
    //   _setUp();
    // }
    // if (oldWidget.backgroundColor != widget.backgroundColor) {
    //   _setUp();
    // }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _controllers.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      _setUp();
      setState(() {});
    });
    _setUp();
  }

  void _setUp() {
    final duration = Duration(milliseconds: widget.controller.config.animationDuration);
    if (widget.controller.pages.isEmpty) return;
    _controllers.clear();
    pages.clear();
    for (var i = 0; i < widget.controller.pages.length; i++) {
      final _controller = AnimationController(
        value: 1,
        duration: duration,
        vsync: this,
      );
      _controllers.add(_controller);
      var _child = CustomPaint(
        painter: TextCompositionEffect(
          amount: _controller,
          backgroundColor: const Color(0xFFFFFFCC),
          page: widget.controller.pages[i],
          config: widget.controller.config,
        ),
      );
      pages.add(_child);
    }
    pages = pages.reversed.toList();
    pageNumber = 0;
  }

  bool get _isLastPage => pages.length - 1 == pageNumber;

  bool get _isFirstPage => pageNumber == 0;

  void _turnPage(DragUpdateDetails details, BoxConstraints dimens) {
    final _ratio = details.delta.dx / dimens.maxWidth;
    if (_isForward == null) {
      if (details.delta.dx > 0) {
        _isForward = false;
      } else {
        _isForward = true;
      }
    }
    if (_isForward!) {
      _controllers[pageNumber].value += _ratio;
    } else if (!_isFirstPage) {
      _controllers[pageNumber - 1].value += _ratio;
    }
  }

  Future<void> _onDragFinish() async {
    if (_isForward != null) {
      if (_isForward!) {
        if (!_isLastPage && _controllers[pageNumber].value <= (widget.cutoffNext / 100 + 0.03)) {
          await nextPage();
        } else {
          await _controllers[pageNumber].forward();
          if (_isLastPage) {
            widget.controller.nextChapter();
          }
        }
      } else {
        if (!_isFirstPage && _controllers[pageNumber - 1].value >= (widget.cutoffPrevious / 100 + 0.05)) {
          await previousPage();
        } else {
          if (_isFirstPage) {
            await _controllers[pageNumber].forward();
            widget.controller.previousChapter();
          } else {
            await _controllers[pageNumber - 1].reverse();
          }
        }
      }
    }
    _isForward = null;
  }

  Future<void> nextPage() async {
    if (_isLastPage) {
      widget.controller.nextChapter();
      return;
    }
    if (mounted) {
      if (widget.controller.config.animationTap)
        _controllers[pageNumber].reverse();
      else
        _controllers[pageNumber].value = 0;
      setState(() {
        pageNumber++;
      });
    }
  }

  Future<void> previousPage() async {
    if (_isFirstPage) {
      widget.controller.previousChapter();
      return;
    }
    if (mounted) {
      if (widget.controller.config.animationTap)
        _controllers[pageNumber - 1].forward();
      else
        _controllers[pageNumber - 1].value = 1;
      setState(() {
        pageNumber--;
      });
    }
  }

  Future<void> goToPage(int index) async {
    if (mounted) {
      if (index > pageNumber) {
        _controllers[index - 1].reverse();
      } else {
        _controllers[index].forward();
      }
      setState(() {
        pageNumber = index;
      });
      for (var i = 0; i < _controllers.length; i++) {
        if (i < index - 1) {
          _controllers[i].value = 0;
        } else if (i > index) {
          _controllers[i].value = 1;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;
    return Material(
      child: LayoutBuilder(
        builder: (context, dimens) => RawKeyboardListener(
          focusNode: new FocusNode(),
          autofocus: true,
          onKey: (event) {
            if (event.runtimeType.toString() == 'RawKeyUpEvent') return;
            if (event.data is RawKeyEventDataMacOs ||
                event.data is RawKeyEventDataLinux ||
                event.data is RawKeyEventDataWindows) {
              final logicalKey = event.data.logicalKey;
              print(logicalKey);
              if (logicalKey == LogicalKeyboardKey.arrowUp) {
                previousPage();
              } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
                previousPage();
              } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
                nextPage();
              } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
                nextPage();
              } else if (logicalKey == LogicalKeyboardKey.home) {
                goToPage(0);
              } else if (logicalKey == LogicalKeyboardKey.end) {
                // goToPage(pages.length - 1);
              } else if (logicalKey == LogicalKeyboardKey.enter || logicalKey == LogicalKeyboardKey.numpadEnter) {
                //
              } else if (logicalKey == LogicalKeyboardKey.escape) {
                Navigator.of(context).pop();
              }
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragCancel: () => _isForward = null,
            onHorizontalDragUpdate: (details) => _turnPage(details, dimens),
            onHorizontalDragEnd: (details) => _onDragFinish(),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                widget.lastPage,
                // ...pages.map((p) {
                //   i++;
                //   final pn = pages.length - pageNumber;
                //   final ret = Offstage(offstage: !(i >= pn - 2 && i <= pn + 1), child: p);
                //   return ret;
                // }).toList(),
                ...pages,
                Positioned.fill(
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Flexible(
                        flex: 50 - widget.cutoffPrevious,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: previousPage,
                        ),
                      ),
                      Flexible(
                        flex: widget.cutoffNext - 50,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: nextPage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// /// * 暂不支持图片
// /// * 文本排版
// /// * 两端对齐
// /// * 底栏对齐
// class TextCompositionOri {
//   /// 待渲染文本段落
//   /// 已经预处理: 不重新计算空行 不重新缩进
//   final List<String> paragraphs;
//
//   /// 字体样式 字号 [size] 行高 [height] 字体 [family] 字色[Color]
//   final TextStyle style;
//
//   /// 标题
//   final String? title;
//
//   /// 标题样式
//   final TextStyle? titleStyle;
//
//   /// 标题正文间距
//   final double? titlePadding;
//
//   /// 段间距
//   final double paragraph;
//
//   /// 每一页内容
//   final List<TextPage> pages;
//
//   int get pageCount => pages.length;
//
//   /// 分栏个数
//   final int columnCount;
//
//   /// 分栏间距
//   final double columnGap;
//
//   /// 单栏宽度
//   final double columnWidth;
//
//   /// 容器大小
//   final Size boxSize;
//
//   /// 内部边距
//   final EdgeInsets? padding;
//
//   /// 是否底栏对齐
//   final bool shouldJustifyHeight;
//
//   /// 前景 页眉页脚 菜单等
//   final Widget Function(int pageIndex)? getForeground;
//
//   /// 背景 背景色或者背景图片
//   final ui.Image Function(int pageIndex)? getBackground;
//
//   /// 是否显示动画
//   bool showAnimation;
//
//   // final Pattern? linkPattern;
//   // final TextStyle? linkStyle;
//   // final String Function(String s)? linkText;
//
//   // canvas 点击事件不生效
//   // final void Function(String s)? onLinkTap;
//
//   /// * 文本排版
//   /// * 两端对齐
//   /// * 底栏对齐
//   /// * 多栏布局
//   ///
//   ///
//   /// * [text] 待渲染文本内容 已经预处理: 不重新计算空行 不重新缩进
//   /// * [paragraphs] 待渲染文本内容 已经预处理: 不重新计算空行 不重新缩进
//   /// * [paragraphs] 为空时使用[text], 否则忽略[text],
//   /// * [style] 字体样式 字号 [size] 行高 [height] 字体 [family] 字色[Color]
//   /// * [title] 标题
//   /// * [titleStyle] 标题样式
//   /// * [boxSize] 容器大小
//   /// * [paragraph] 段间距
//   /// * [shouldJustifyHeight] 是否底栏对齐
//   /// * [columnCount] 分栏个数
//   /// * [columnGap] 分栏间距
//   /// * onLinkTap canvas 点击事件不生效
//   TextCompositionOri({
//     String? text,
//     List<String>? paragraphs,
//     required this.style,
//     this.title,
//     this.titleStyle,
//     this.titlePadding,
//     Size? boxSize,
//     this.padding,
//     this.shouldJustifyHeight = true,
//     this.paragraph = 10.0,
//     this.columnCount = 1,
//     this.columnGap = 0.0,
//     this.getForeground,
//     this.getBackground,
//     this.debug = false,
//     List<TextPage>? pages,
//     this.showAnimation = true,
//     // this.linkPattern,
//     // this.linkStyle,
//     // this.linkText,
//     // this.onLinkTap,
//   })  : pages = pages ?? <TextPage>[],
//         paragraphs = paragraphs ?? text?.split("\n") ?? <String>[],
//         boxSize = boxSize ?? ui.window.physicalSize / ui.window.devicePixelRatio,
//         columnWidth = ((boxSize?.width ?? ui.window.physicalSize.width / ui.window.devicePixelRatio) -
//                 (padding?.horizontal ?? 0) -
//                 (columnCount - 1) * columnGap) /
//             columnCount {
//     // [_width2] [_height2] 用于调整判断
//     final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
//     final offset = Offset(columnWidth, 1);
//     final size = style.fontSize ?? 14;
//     final _dx = padding?.left ?? 0;
//     final _dy = padding?.top ?? 0;
//     final _width = columnWidth;
//     final _width2 = _width - size;
//     final _height = this.boxSize.height - (padding?.vertical ?? 0);
//     final _height2 = _height - size * (style.height ?? 1.0);
//
//     var lines = <TextLine>[];
//     var columnNum = 1;
//     var dx = _dx;
//     var dy = _dy;
//     var startLine = 0;
//
//     if (title != null && title!.isNotEmpty) {
//       String t = title!;
//       while (true) {
//         tp.text = TextSpan(text: title, style: titleStyle);
//         tp.layout(maxWidth: _width);
//         final textCount = tp.getPositionForOffset(offset).offset;
//         final text = t.substring(0, textCount);
//         double? spacing;
//         if (tp.width > _width2) {
//           tp.text = TextSpan(text: text, style: titleStyle);
//           tp.layout();
//           double _spacing = (_width - tp.width) / textCount;
//           if (_spacing < -0.1 || _spacing > 0.1) {
//             spacing = _spacing;
//           }
//         }
//         lines.add(TextLine(text, dx, dy, spacing, true));
//         dy += tp.height;
//         if (t.length == textCount) {
//           break;
//         } else {
//           t = t.substring(textCount);
//         }
//       }
//     }
//
//     /// 下一页 判断分页 依据: `_boxHeight` `_boxHeight2`是否可以容纳下一行
//     void newPage([bool shouldJustifyHeight = true, bool lastPage = false]) {
//       if (shouldJustifyHeight && this.shouldJustifyHeight) {
//         final len = lines.length - startLine;
//         double justify = (_height - dy) / (len - 1);
//         for (var i = 0; i < len; i++) {
//           lines[i + startLine].justifyDy(justify * i);
//         }
//       }
//       if (columnNum == columnCount || lastPage) {
//         this.pages.add(TextPage(lines: lines, height: dy, number: 1));
//         lines = <TextLine>[];
//         columnNum = 1;
//         dx = _dx;
//       } else {
//         columnNum++;
//         dx += columnWidth + columnGap;
//       }
//       dy = _dy;
//       startLine = lines.length;
//     }
//
//     /// 新段落
//     void newParagraph() {
//       if (dy > _height2) {
//         newPage();
//       } else {
//         dy += paragraph;
//       }
//     }
//
//     for (var p in this.paragraphs) {
//       while (true) {
//         tp.text = TextSpan(text: p, style: style);
//         tp.layout(maxWidth: columnWidth);
//         final textCount = tp.getPositionForOffset(offset).offset;
//         double? spacing;
//         final text = p.substring(0, textCount);
//         if (tp.width > _width2) {
//           tp.text = TextSpan(text: text, style: style);
//           tp.layout();
//           spacing = (_width - tp.width) / textCount;
//         }
//         lines.add(TextLine(text, dx, dy, spacing));
//         dy += tp.height;
//         if (p.length == textCount) {
//           newParagraph();
//           break;
//         } else {
//           p = p.substring(textCount);
//           if (dy > _height2) {
//             newPage();
//           }
//         }
//       }
//     }
//     if (lines.isNotEmpty) {
//       newPage(false, true);
//     }
//     if (this.pages.length == 0) {
//       this.pages.add(TextPage(lines: [], height: padding?.horizontal ?? 0, number: 1));
//     }
//   }
//
//   /// 调试模式 输出布局信息
//   bool debug;
//
//   Widget getPageWidget([int pageIndex = 0]) {
//     // if (pageIndex != null && !changePage(pageIndex)) return Container();
//     return Container(
//       width: boxSize.width,
//       height: boxSize.height.isInfinite ? pages[pageIndex].height : boxSize.height,
//       child: CustomPaint(painter: PagePainter(pageIndex, pages[pageIndex], style, titleStyle, debug)),
//     );
//   }
//
//   Future<ui.Image?> getImage(int pageIndex) async {
//     final recorder = ui.PictureRecorder();
//     final canvas = new Canvas(recorder, Rect.fromPoints(Offset.zero, Offset(boxSize.width, boxSize.height)));
//     PagePainter(pageIndex, pages[pageIndex], style, titleStyle, debug).paint(canvas, boxSize);
//     final picture = recorder.endRecording();
//     return await picture.toImage(boxSize.width.floor(), boxSize.height.floor());
//   }
//
//   void paint(int pageIndex, Canvas canvas) {
//     PagePainter(pageIndex, pages[pageIndex], style, titleStyle, debug).paint(canvas, boxSize);
//   }
// }
//
// class PagePainter extends CustomPainter {
//   final TextPage page;
//   final TextStyle style;
//   final TextStyle? titleStyle;
//   final int pageIndex;
//   final bool debug;
//   const PagePainter(this.pageIndex, this.page, this.style, this.titleStyle, [this.debug = false]);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (debug) print("****** [TextComposition paint start] [${DateTime.now()}] ******");
//     final lineCount = page.lines.length;
//     final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
//     for (var i = 0; i < lineCount; i++) {
//       final line = page.lines[i];
//       if (line.letterSpacing != null && (line.letterSpacing! < -0.1 || line.letterSpacing! > 0.1)) {
//         tp.text = TextSpan(
//           text: line.text,
//           style: line.isTitle
//               ? titleStyle?.copyWith(letterSpacing: line.letterSpacing)
//               : style.copyWith(letterSpacing: line.letterSpacing),
//         );
//       } else {
//         tp.text = TextSpan(text: line.text, style: line.isTitle ? titleStyle : style);
//       }
//       final offset = Offset(line.dx, line.dy);
//       if (debug) print("$offset ${line.text}");
//       tp.layout();
//       tp.paint(canvas, offset);
//     }
//     if (debug) print("****** [TextComposition paint end  ] [${DateTime.now()}] ******");
//   }
//
//   @override
//   bool shouldRepaint(PagePainter old) {
//     print("shouldRepaint");
//     return old.pageIndex != pageIndex;
//   }
// }
