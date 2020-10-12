import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'lyric.dart';
import 'lyric_controller.dart';
import 'lyric_painter.dart';

class LyricWidget extends StatefulWidget {
  final List<Lyric> lyrics;
  final List<Lyric> remarkLyrics;
  final Size size;
  final LyricController controller;
  final TextStyle lyricStyle;
  final TextStyle remarkStyle;
  final TextStyle currLyricStyle;
  final TextStyle _currRemarkLyricStyle;
  final TextStyle _draggingLyricStyle;
  final TextStyle _draggingRemarkLyricStyle;
  final double lyricGap;
  final double remarkLyricGap;
  final bool enableDrag;

  //歌词画笔数组
  final  List<TextPainter> lyricTextPaints = [];

  //翻译/音译歌词画笔数组
  final List<TextPainter> subLyricTextPaints = [];

  //字体最大宽度
  final double lyricMaxWidth;

  LyricWidget(
      {Key key,
      @required this.lyrics,
      this.remarkLyrics,
      @required this.size,
      this.controller,
      this.lyricStyle = const TextStyle(color: Colors.grey, fontSize: 14),
      this.remarkStyle = const TextStyle(color: Colors.black, fontSize: 14),
      this.currLyricStyle = const TextStyle(color: Colors.red, fontSize: 14),
      this.lyricGap: 10,
      this.remarkLyricGap: 20,
      TextStyle draggingLyricStyle,
      TextStyle draggingRemarkLyricStyle,
      this.enableDrag: true,
      this.lyricMaxWidth,
      TextStyle currRemarkLyricStyle})
      : assert(enableDrag != null),
        assert(lyrics != null && lyrics.isNotEmpty),
        assert(size != null),
        this._currRemarkLyricStyle = currRemarkLyricStyle ?? currLyricStyle,
        this._draggingLyricStyle = draggingLyricStyle ?? lyricStyle.copyWith(color: Colors.greenAccent),
        this._draggingRemarkLyricStyle = draggingRemarkLyricStyle ?? remarkStyle.copyWith(color: Colors.greenAccent),
        assert(controller != null)
  {
      //歌词转画笔
      lyricTextPaints.addAll(lyrics
          .map(
            (l) => TextPainter(
                text: TextSpan(text: l.lyric, style: lyricStyle),
                textDirection: TextDirection.ltr),
          )
          .toList());

      //翻译/音译歌词转画笔
      if (remarkLyrics != null && remarkLyrics.isNotEmpty) {
        subLyricTextPaints.addAll(remarkLyrics
            .map((l) => TextPainter(
                text: TextSpan(text: l.lyric, style: remarkStyle),
                textDirection: TextDirection.ltr))
            .toList());
      }
  }

  @override
  _LyricWidgetState createState() => _LyricWidgetState();
}

class _LyricWidgetState extends State<LyricWidget> {
  LyricPainter _lyricPainter;
  AnimationController _animationController;
  Animation<double> animation;
  double lyricMaxWidth;
  double totalHeight = 0;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: widget.controller.vsync,
        duration: Duration(milliseconds: 500));
    _animationController.addListener(_updateOffset);

    lyricMaxWidth = widget.lyricMaxWidth;
    widget.controller.draggingComplete = () {
      cancelTimer();
      widget.controller.progress = widget.controller.draggingProgress;
      _lyricPainter.draggingLine = null;
      widget.controller.isDragging = false;
    };
    WidgetsBinding.instance.addPostFrameCallback((call) {
      totalHeight = computeScrollY(widget.lyrics.length - 1);
    });
    widget.controller.addListener(() {
      var curLine =
          findLyricIndexByDuration(widget.controller.progress, widget.lyrics);
      if (widget.controller.oldLine != curLine) {
        _lyricPainter.currentLyricIndex = curLine;
        if (!widget.controller.isDragging) {
          if (widget.controller.vsync == null) {
            _lyricPainter.offset = -computeScrollY(curLine);
          } else {
            animationScrollY(curLine, widget.controller.vsync);
          }
        }
        widget.controller.oldLine = curLine;
      }
    });
    super.initState();
  }

  static double _lastOffset = 0.0;

  _updateOffset() {
    // print("$aniBegin, $aniEnd, ${_animationController.value}");
    _lyricPainter.offset = -(aniBegin + (aniEnd - aniBegin) * _animationController.value);
    _lastOffset = _lyricPainter.offset;
  }

  ///因空行高度与非空行高度不一致，获取非空行的位置
  int getNotEmptyLineHeight(List<Lyric> lyrics) =>
      lyrics.indexOf(lyrics.firstWhere((lyric) => lyric.lyric.trim().isNotEmpty,
          orElse: () => lyrics.first));

  @override
  Widget build(BuildContext context) {
    if (lyricMaxWidth == null || lyricMaxWidth == double.infinity) {
      lyricMaxWidth = MediaQuery.of(context).size.width;
    }
    _lyricPainter = LyricPainter(
        widget.lyrics, widget.lyricTextPaints, widget.subLyricTextPaints,
        // vsync: widget.controller.vsync,
        subLyrics: widget.remarkLyrics,
        lyricTextStyle: widget.lyricStyle,
        subLyricTextStyle: widget.remarkStyle,
        currLyricTextStyle: widget.currLyricStyle,
        lyricGapValue: widget.lyricGap,
        lyricMaxWidth: lyricMaxWidth,
        subLyricGapValue: widget.remarkLyricGap,
        draggingLyricTextStyle: widget._draggingLyricStyle,
        draggingSubLyricTextStyle: widget._draggingRemarkLyricStyle,
        currSubLyricTextStyle: widget._currRemarkLyricStyle);
    _lyricPainter.currentLyricIndex =
        findLyricIndexByDuration(widget.controller.progress, widget.lyrics);
    if (widget.controller.isDragging) {
      _lyricPainter.draggingLine = widget.controller.draggingLine;
      _lyricPainter.offset = widget.controller.draggingOffset;
    } else {
      _lyricPainter.offset = _lastOffset;
    }
    return widget.enableDrag
        ? GestureDetector(
            onVerticalDragUpdate: (e) {
              cancelTimer();
              double temOffset = (_lyricPainter.offset + e.delta.dy);
              if (temOffset < 0 && temOffset >= -totalHeight) {
                widget.controller.draggingOffset = temOffset;
                widget.controller.draggingLine =
                    getCurrentDraggingLine(temOffset+widget.lyricGap);
                _lyricPainter.draggingLine = widget.controller.draggingLine;
                widget.controller.draggingProgress =
                    widget.lyrics[widget.controller.draggingLine].startTime +
                        Duration(milliseconds: 1);
                widget.controller.isDragging = true;
                _lyricPainter.offset = temOffset;
              }
            },
            onVerticalDragEnd: (e) {
              cancelTimer();
              widget.controller.draggingTimer = Timer(
                  widget.controller.draggingTimerDuration ??
                      Duration(seconds: 3), () {
                resetDragging();
              });
            },
            child: buildCustomPaint(),
          )
        : buildCustomPaint();
  }

  CustomPaint buildCustomPaint() {
    return CustomPaint(
      painter: _lyricPainter,
      size: widget.size,
    );
  }

  void resetDragging() {
    _lyricPainter.currentLyricIndex =
        findLyricIndexByDuration(widget.controller.progress, widget.lyrics);

    widget.controller.previousRowOffset = -widget.controller.draggingOffset;
    animationScrollY(_lyricPainter.currentLyricIndex, widget.controller.vsync);
    _lyricPainter.draggingLine = null;
    widget.controller.isDragging = false;
  }

  int getCurrentDraggingLine(double offset) {
    for (int i = 0; i < widget.lyrics.length; i++) {
      var scrollY = computeScrollY(i);
      if (offset > -1) {
        offset = 0;
      }
      if (offset >= -scrollY) {
        return i;
      }
    }
    return widget.lyrics.length;
  }

  void cancelTimer() {
    if (widget.controller.draggingTimer != null) {
      if (widget.controller.draggingTimer.isActive) {
        widget.controller.draggingTimer.cancel();
        widget.controller.draggingTimer = null;
      }
    }
  }

  double aniBegin = 0.0;
  double aniEnd = 0.0;

  animationScrollY(currentLyricIndex, TickerProvider tickerProvider) {
    if (!this.mounted) return;
    // 计算当前行偏移量
    var currentRowOffset = computeScrollY(currentLyricIndex);
    //如果偏移量相同不执行动画
    if (currentRowOffset == widget.controller.previousRowOffset)
      return;
    // 起始为上一行，结束点为当前行
    _animationController.stop();
    aniBegin = widget.controller.previousRowOffset;
    aniEnd = currentRowOffset;
    widget.controller.previousRowOffset = currentRowOffset;
    _animationController.forward(from: 0);
  }

  //根据当前时长获取歌词位置
  int findLyricIndexByDuration(Duration curDuration, List<Lyric> lyrics) {
    for (int i = 0; i < lyrics.length; i++) {
      if (curDuration >= lyrics[i].startTime &&
          curDuration <= lyrics[i].endTime) {
        return i;
      }
    }
    return 0;
  }

  /// 计算传入行和第一行的偏移量
  double computeScrollY(int curLine) {
    double totalHeight = 0;
    for (var i = 0; i < curLine; i++) {
      var currPaint = widget.lyricTextPaints[i]
        ..text =
            TextSpan(text: widget.lyrics[i].lyric, style: widget.lyricStyle);
      currPaint.layout(maxWidth: lyricMaxWidth);
      totalHeight += currPaint.height + widget.lyricGap;
    }
    if (widget.remarkLyrics != null) {
      //增加 当前行之前的翻译歌词的偏移量
      widget.remarkLyrics
          .where(
              (subLyric) => subLyric.endTime <= widget.lyrics[curLine].endTime)
          .toList()
          .forEach((subLyric) {
        var currentPaint = widget
            .subLyricTextPaints[widget.remarkLyrics.indexOf(subLyric)]
          ..text = TextSpan(text: subLyric.lyric, style: widget.remarkStyle);
        currentPaint.layout(maxWidth: lyricMaxWidth);
        totalHeight += widget.remarkLyricGap + currentPaint.height;
      });
    }
    return totalHeight;
  }
}
