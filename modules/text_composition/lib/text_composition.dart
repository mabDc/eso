library text_composition;

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'memory_cache.dart';
import 'text_composition_effect_refactor.dart';
import 'text_composition_const.dart';
import 'text_composition_config.dart';
import 'text_composition_widget.dart';

export 'text_composition_config.dart';
export 'text_composition_effect_refactor.dart';
export 'text_composition_page.dart';
export 'text_composition_widget.dart';
export 'text_composition_const.dart';

class TextPage {
  double percent;
  int number;
  int total;
  int chIndex;
  String info;
  final double height;
  final double column;
  final List<TextLine> lines;
  final int columns;

  TextPage({
    this.percent = 0.0,
    this.total = 1,
    this.chIndex = 0,
    this.info = '',
    required this.column,
    required this.number,
    required this.height,
    required this.lines,
    required this.columns,
  });
}

class TextPageRefactor {
  final int chIndex;
  final ui.Picture picture;
  double percent;

  TextPageRefactor({
    required this.percent,
    required this.chIndex,
    required this.picture,
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
class TextComposition extends ChangeNotifier {
  final TextCompositionConfig config;
  final Duration duration;
  final FutureOr<List<String>> Function(int chapterIndex) loadChapter;
  final FutureOr Function(TextCompositionConfig config, double percent)? onSave;
  final Widget Function(TextComposition textComposition)? menuBuilder;
  final String? name;
  final List<String> chapters;
  final List<AnimationController> _controllers;

  double _initPercent;
  int _firstChapterIndex;
  int get firstChapterIndex => _firstChapterIndex;
  int _lastChapterIndex;

  int _firstIndex, _currentIndex, _lastIndex;
  int get firstIndex => _firstIndex;
  int get currentIndex => _currentIndex;
  int get lastIndex => _lastIndex;
  bool get _isFirstPage => _currentIndex <= _firstIndex;
  bool get _isLastPage => _currentIndex >= _lastIndex;

  final Map<int, TextPage> textPages;
  final MemoryCache<int, ui.Picture> pictures;
  ui.Image? _backImage;
  ui.Image? get backImage => _backImage;
  bool get animationWithImage => _backImage != null && config.animationWithImage == true;

  Future<void> _getBackImage() async {
    try {
      final background = config.background;
      final size = ui.window.physicalSize / ui.window.devicePixelRatio;
      if (background.isEmpty || background == 'null') {
        _backImage = null;
        return;
      } else if (background.startsWith("asset")) {
        final data = await rootBundle.load(background);
        ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
            targetWidth: size.width.round(), targetHeight: size.height.round());
        ui.FrameInfo fi = await codec.getNextFrame();
        _backImage = fi.image;
      } else {
        final data = await File(background).readAsBytes();
        ui.Codec codec = await ui.instantiateImageCodec(data,
            targetWidth: size.width.round(), targetHeight: size.height.round());
        ui.FrameInfo fi = await codec.getNextFrame();
        _backImage = fi.image;
      }
    } catch (e) {}
  }

  // drawBackImage(ui.Canvas canvas, [Rect? rect]) {
  //   if (_backImage == null) return;
  //   if (rect != null) {
  //     canvas.drawImageRect(_backImage!, rect, rect, Paint());
  //   } else {
  //     canvas.drawImage(_backImage!, Offset.zero, Paint());
  //   }
  // }

  ui.Picture? getPicture(int index, Size size) => pictures.getValueOrSet(index, () {
        final textPage = textPages[index];
        if (textPage == null) return null;
        final pic = ui.PictureRecorder();
        final c = Canvas(pic);
        if (animation == AnimationType.simulation || animation == AnimationType.flip) {
          final pageRect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
          c.drawRect(pageRect, Paint()..color = config.backgroundColor);
          if (_backImage != null) c.drawImage(_backImage!, Offset.zero, Paint());
        }
        if (animationWithImage && animation == AnimationType.curl) {
          c.drawImage(_backImage!, Offset.zero, Paint());
        }
        paintText(c, size, textPage, config);
        return pic.endRecording();
      });
  AnimationType get animation => config.animation;
  Color get backgroundColor => config.backgroundColor;
  bool get shouldClipStatus => config.showStatus && !config.animationStatus;

  final int cutoffNext;
  final int cutoffPrevious;

  int _tapWithoutNoCounter;
  bool _disposed;
  bool? isForward;
  bool _isShowMenu;
  bool get isShowMenu => _isShowMenu;
  static const BASE = 8;
  static const QUARTER = BASE * 8;
  static const HALF = QUARTER * 2;
  static const TOTAL = HALF * 2;
  TextComposition({
    required this.config,
    required this.loadChapter,
    required this.chapters,
    this.name,
    this.onSave,
    this.menuBuilder,
    percent = 0.0,
    this.cutoffPrevious = 8,
    this.cutoffNext = 92,
  })  : this._initPercent = percent,
        textPages = {},
        pictures = MemoryCache(),
        _lastSaveTime = DateTime.now().add(saveDelay).millisecondsSinceEpoch,
        _controllers = [],
        _firstChapterIndex = (percent * chapters.length).floor(),
        _lastChapterIndex = (percent * chapters.length).floor(),
        _firstIndex = -1,
        _currentIndex = -1,
        _lastIndex = -1,
        duration = Duration(milliseconds: config.animationDuration),
        _tapWithoutNoCounter = 0,
        _disposed = false,
        _isShowMenu = false;
  //  {
  // _pages = [
  //   Container(
  //     color: const Color(0xFFFFFFCC),
  //     width: double.infinity,
  //     height: double.infinity,
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(name ?? ""),
  //         SizedBox(height: 10),
  //         Text("加载第${_lastChapterIndex + 1}个章节"),
  //         SizedBox(height: 10),
  //         Text("${chapters[_lastChapterIndex]}"),
  //         SizedBox(height: 30),
  //         CupertinoActivityIndicator(),
  //       ],
  //     ),
  //   )
  // ];
  // }

  toggleMenuDialog(BuildContext context) {
    _isShowMenu = !_isShowMenu;
    if (menuBuilder == null) {
      if (_isShowMenu) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('阅读设置'),
                  titlePadding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  contentPadding: EdgeInsets.zero,
                  content: Container(
                    width: 520,
                    child: configSettingBuilder(
                      context,
                      config,
                      (Color color, void Function(Color color) onChange) {
                        print("选择颜色");
                      },
                      (String s, void Function(String s) onChange) {
                        print("选择背景");
                      },
                      (String s, void Function(String s) onChange) {
                        print("选择字体");
                      },
                    ),
                  ),
                )).then((value) {
          _isShowMenu = false;
          notifyListeners();
          _getBackImage();
        });
      } else {
        Navigator.of(context).pop();
      }
    } else if (!_isShowMenu) {
      _getBackImage();
    }
    notifyListeners();
  }

  gotoNextChapter() {
    final cPage = textPages[_currentIndex];
    if (cPage == null) return;
    final nextIndex = cPage.total - cPage.number + _currentIndex + 1;
    goToPage(nextIndex);
  }

  gotoPreviousChapter() {
    final cPage = textPages[_currentIndex];
    if (cPage == null) return;
    final previousIndex = _currentIndex - cPage.number;
    goToPage(previousIndex);
  }

  gotoChapter(int index) async {
    // 如果章节在加载范围内
    if (_disposed) return;
    if (index <= _lastChapterIndex && index >= _firstChapterIndex) {
      var ci = index - textPages[_currentIndex]!.chIndex;
      if (ci > 0) {
        int nextIndex = _currentIndex;
        for (var i = 0; i < ci; i++) {
          final cPage = textPages[nextIndex]!;
          nextIndex += cPage.total - cPage.number + 1;
        }
        goToPage(nextIndex);
      } else if (ci < 0) {
        int previousIndex = _currentIndex;
        for (var i = 0; i > ci; i--) {
          final cPage = textPages[previousIndex]!;
          previousIndex -= cPage.number;
        }
        goToPage(previousIndex);
      }
    } else {
      // 不在范围
      if (index < 0 || index > chapters.length) return;
      if (_disposed) return;
      final pages = await startX(index);
      if (_disposed) return;
      pictures.clear();
      textPages.clear();
      _firstChapterIndex = index;
      _lastChapterIndex = index;
      _currentIndex = TOTAL * 12345 + HALF;
      _firstIndex = _currentIndex;
      _lastIndex = _firstIndex + pages.length - 1;
      for (var i = 0; i < pages.length; i++) {
        this.textPages[_firstIndex + i] = pages[i];
      }
      final c = _currentIndex % TOTAL;
      for (var i = c - HALF, end = c; i < end; i++) {
        _controllers[i % TOTAL].value = 0;
      }
      for (var i = c, end = c + HALF; i < end; i++) {
        _controllers[i % TOTAL].value = 1;
      }
      _tapWithoutNoCounter = BASE;
      notifyListeners();
      previousChapter();
      nextChapter();
    }
  }

  Future<void> init(
      void Function(List<AnimationController> _controller) initControllers) async {
    initControllers(_controllers);
    await _getBackImage();
    if (_disposed) return;
    final pages = await startX(_firstChapterIndex);
    if (_disposed) return;
    _currentIndex = TOTAL * 12345 + HALF;
    final n =
        ((_initPercent * chapters.length - _firstChapterIndex) * pages.length).round();
    if (n < 2) {
      _firstIndex = _currentIndex;
    } else if (n < pages.length) {
      _firstIndex = _currentIndex - n + 1;
    } else {
      _firstIndex = _currentIndex - pages.length + 1;
    }
    _lastIndex = _firstIndex + pages.length - 1;
    for (var i = 0; i < pages.length; i++) {
      this.textPages[_firstIndex + i] = pages[i];
    }
    final c = _currentIndex % TOTAL;
    for (var i = c - HALF, end = c; i < end; i++) {
      _controllers[i % TOTAL].value = 0;
    }
    for (var i = c, end = c + HALF; i < end; i++) {
      _controllers[i % TOTAL].value = 1;
    }
    _tapWithoutNoCounter = BASE;
    notifyListeners();
    Future.delayed(duration).then((value) {
      previousChapter();
      nextChapter();
    });
  }

  List<Widget> get pages {
    if (textPages.isEmpty) {
      return [CircularProgressIndicator()];
    }
    return [
      for (var i = _currentIndex + HALF, last = _currentIndex - HALF; i > last; i--)
        CustomPaint(
          painter: TextCompositionEffect(
            amount: _controllers[i % TOTAL],
            index: i,
            textComposition: this,
          ),
        ),
    ];
  }

  double getAnimationPostion(int index) => _controllers[index % TOTAL].value;

  void _checkController(int index, [bool next = false]) {
    if (_disposed || _controllers.length != TOTAL) return;
    (next
            ? _controllers[index % TOTAL].reverse()
            : _controllers[(index - 1) % TOTAL].forward())
        .then((value) {
      if (_disposed || _controllers.length != TOTAL) return;
      if (_firstChapterIndex == textPages[index]!.chIndex) previousChapter();
      if (_lastChapterIndex == textPages[index]!.chIndex) nextChapter();
      if (_tapWithoutNoCounter == HALF - BASE) {
        final c = index % TOTAL;
        for (var i = c - HALF, end = c - BASE; i < end; i++) {
          _controllers[i % TOTAL].value = 0;
        }
        for (var i = c + BASE, end = c + HALF; i < end; i++) {
          _controllers[i % TOTAL].value = 1;
        }
        _tapWithoutNoCounter = BASE;
        notifyListeners();
      } else {
        _tapWithoutNoCounter++;
      }
    });
  }

  int _lastSaveTime;
  static const saveDelay = const Duration(seconds: 10);
  checkSave() {
    if (onSave == null) return;
    _lastSaveTime = DateTime.now().add(saveDelay).millisecondsSinceEpoch;
    Future.delayed(saveDelay).then((value) {
      if (_disposed || DateTime.now().millisecondsSinceEpoch < _lastSaveTime) return;
      print("checkSave ${DateTime.now()}");
      onSave?.call(config, textPages[_currentIndex]!.percent);
    });
  }

  void previousPage() {
    if (_disposed || _isFirstPage) return;
    _checkController(_currentIndex);
    _currentIndex--;
    checkSave();
  }

  void nextPage() {
    if (_disposed || _isLastPage) return;
    _checkController(_currentIndex, true);
    _currentIndex++;
    checkSave();
  }

  Future<void> goToPage(int index) async {
    if (_disposed ||
        _controllers.length != TOTAL ||
        index > _lastIndex ||
        index < _firstIndex) return;
    final c = index % TOTAL;
    for (var i = c - HALF, end = c; i < end; i++) {
      _controllers[i % TOTAL].value = 0;
    }
    for (var i = c, end = c + HALF; i < end; i++) {
      _controllers[i % TOTAL].value = 1;
    }
    _tapWithoutNoCounter = BASE;

    if (index > _currentIndex) {
      _controllers[(index - 1) % TOTAL].reverse(from: 1);
    } else {
      _controllers[index % TOTAL].forward(from: 0);
    }

    _currentIndex = index;
    checkSave();
    notifyListeners();
    Future.delayed(duration).then((value) {
      if (_firstChapterIndex == textPages[index]!.chIndex) previousChapter();
      if (_lastChapterIndex == textPages[index]!.chIndex) nextChapter();
    });
  }

  void turnPage(DragUpdateDetails details, BoxConstraints dimens,
      {bool vertical = false}) {
    if (_disposed) return;
    TextCompositionEffect.autoVerticalDrag = vertical;
    final offset = vertical ? details.delta.dy : details.delta.dx;
    final _ratio = vertical ? (offset / dimens.maxHeight) : (offset / dimens.maxWidth);
    if (isForward == null) {
      if (offset > 0) {
        isForward = false;
      } else {
        isForward = true;
      }
    }
    if (isForward!) {
      _controllers[currentIndex % TOTAL].value += _ratio;
    } else if (!_isFirstPage) {
      _controllers[(currentIndex - 1) % TOTAL].value += _ratio;
    }
  }

  Future<void> onDragFinish() async {
    if (_disposed) return;
    if (isForward != null) {
      if (isForward!) {
        if (!_isLastPage &&
            _controllers[currentIndex % TOTAL].value <= (cutoffNext / 100 + 0.03)) {
          nextPage();
        } else {
          _controllers[currentIndex % TOTAL].forward();
        }
      } else {
        if (!_isFirstPage &&
            _controllers[(currentIndex - 1) % TOTAL].value >=
                (cutoffPrevious / 100 + 0.05)) {
          previousPage();
        } else {
          if (_isFirstPage) {
            _controllers[currentIndex % TOTAL].forward();
          } else {
            _controllers[(currentIndex - 1) % TOTAL].reverse();
          }
        }
      }
    }
    isForward = null;
  }

  @override
  void dispose() {
    _disposed = true;
    if (textPages[currentIndex] != null) {
      onSave?.call(config, textPages[_currentIndex]!.percent);
    }
    _controllers.forEach((c) => c.dispose());
    _controllers.clear();
    textPages.forEach((key, value) => value.lines.clear());
    // textPages.forEach((key, value) => value.picture.dispose());
    textPages.clear();
    pictures.clear();
    super.dispose();
  }

  var _previousChapterLoading = false;
  Future<void> previousChapter() async {
    if (_disposed || _firstChapterIndex <= 0 || _previousChapterLoading) return;
    _previousChapterLoading = true;
    final pages = await startX(_firstChapterIndex - 1);
    if (_disposed) return;
    for (var i = 0; i < pages.length; i++) {
      this.textPages[_firstIndex - pages.length + i] = pages[i];
    }
    _firstIndex -= pages.length;
    _firstChapterIndex--;
    _previousChapterLoading = false;
  }

  var _nextChapterLoading = false;
  Future<void> nextChapter([bool animation = true]) async {
    if (_disposed || _lastChapterIndex >= chapters.length - 1 || _nextChapterLoading)
      return;
    _nextChapterLoading = true;
    final pages = await startX(_lastChapterIndex + 1);
    if (_disposed) return;
    for (var i = 0; i < pages.length; i++) {
      this.textPages[_lastIndex + 1 + i] = pages[i];
    }
    _lastIndex += pages.length;
    _lastChapterIndex++;
    _nextChapterLoading = false;
  }

  Future<List<TextPage>> startX(int index) async {
    if (_disposed) return <TextPage>[];
    final paragraphs = await loadChapter(index);
    if (_disposed) return <TextPage>[];
    final pages = <TextPage>[];
    final size = ui.window.physicalSize / ui.window.devicePixelRatio;
    final columns = config.columns > 0
        ? config.columns
        : size.width > 580
            ? 2
            : 1;
    final _width = (size.width -
            config.leftPadding -
            config.rightPadding -
            (columns - 1) * config.columnPadding) /
        columns;
    final _width2 = _width - config.fontSize;
    final _height = size.height - (config.showInfo ? 24 : 0) - config.bottomPadding;
    final _height2 = _height - config.fontSize * config.fontHeight;

    final tp = TextPainter(textDirection: TextDirection.ltr, maxLines: 1);
    final offset = Offset(_width, 1);
    final _dx = config.leftPadding;
    final _dy = config.topPadding +
        (config.showStatus ? ui.window.padding.top / ui.window.devicePixelRatio : 0);

    var lines = <TextLine>[];
    var columnNum = 1;
    var dx = _dx;
    var dy = _dy;
    var startLine = 0;

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

    // String t = chapters[index].replaceAll(RegExp("^\s*|\n|\s\$"), "");
    final chapter = chapters[index].isEmpty ? "第$index章" : chapters[index];
    var _t = chapter;
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
        pages.add(TextPage(
            lines: lines,
            height: dy,
            number: pageIndex++,
            info: chapter,
            chIndex: index,
            column: _width,
            columns: columns));
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
          if (dy > _height2) {
            newPage();
          } else {
            dy += config.paragraphPadding;
          }
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
      pages.add(TextPage(
        lines: [],
        height: config.topPadding + config.bottomPadding,
        number: 1,
        info: chapter,
        chIndex: index,
        column: _width,
        columns: columns,
      ));
    }

    final basePercent = index / chapters.length;
    final total = pages.length;
    pages.forEach((page) {
      page.total = total;
      page.percent = page.number / pages.length / chapters.length + basePercent;
    });
    if (name != null) {
      pages[0].info = name!;
    }

    return pages;

    // return pages.map((textPage) {
    //   final pic = ui.PictureRecorder();
    //   final c = Canvas(pic);
    //   final pageRect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    //   c.drawRect(pageRect, Paint()..color = config.backgroundColor);
    //   paintText(c, size, textPage, config);
    //   final picture = pic.endRecording();
    //   return TextPageRefactor(
    //     chIndex: index,
    //     percent: textPage.percent,
    //     picture: picture,
    //   );
    // }).toList();
  }
}
