import 'dart:async';

import 'package:flutter/cupertino.dart';

class LyricController extends ChangeNotifier {
  //当前进度
  Duration _progress = Duration();

  set progress(Duration value) {
    _progress = value;
    notifyListeners();
  }

  Duration get progress => _progress;

  //滑动保持器
  Timer draggingTimer;

  //滑动保持时间
  Duration draggingTimerDuration;

  bool _isDragging = false;

  get isDragging => _isDragging;

  set isDragging(value) {
    _isDragging = value;
    notifyListeners();
  }

  Duration draggingProgress;

  Function draggingComplete;

  double draggingOffset;

  //启用动画
  TickerProvider vsync;

  //动画 存放上一次偏移量
  double previousRowOffset = 0;

  int oldLine = 0;
  int draggingLine = 0;

  LyricController({this.vsync, this.draggingTimerDuration});

  @override
  void dispose() {
    super.dispose();
  }
}
