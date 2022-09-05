import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 按键类型
enum RawKeyboardKey {
  /// 方向键 - 左
  left,

  /// 方向键 - 上
  top,

  /// 方向键 - 下
  bottom,

  /// 方向键 - 右
  right,

  /// 方向键 - 中间（遥控器方向键中间的确认键）
  center,

  /// ESC键
  esc,

  /// + 号键
  inc,

  /// - 号键
  dec,

  /// 回车键
  enter,

  /// 空格键
  space,

  /// 播放或暂停
  playOrPause,

  /// 快退
  playBack,

  /// 快进
  playNext,

  /// 菜单
  menu,
}

typedef RawKeyCallback = bool Function(
    RawKeyboardKey key, FocusNode focusNode, bool down);
typedef RawKeyEventCallback = bool Function(
    RawKeyboardKey key, FocusNode focusNode, bool down, RawKeyEvent event);

class RawKeyboardEvent extends StatelessWidget {
  const RawKeyboardEvent({
    Key key,
    this.focusNode,
    this.autofocus = false,
    @required this.child,
    this.onlyDown = true,
    this.onKey,
    this.onRawKey,
  }) : super(key: key);

  final FocusNode focusNode;
  final Widget child;
  final bool autofocus;
  final RawKeyCallback onKey;
  final RawKeyEventCallback onRawKey;

  /// 只监听按下事件
  final bool onlyDown;
  static String _enPress = '';

  @override
  Widget build(BuildContext context) {
    final _focusNode = focusNode ?? FocusNode(canRequestFocus: autofocus);
    return Focus(
      focusNode: _focusNode,
      autofocus: autofocus,
      child: child,
      onKey: (node, event) {
        print("object");
        if (event.runtimeType.toString() != _enPress) {
          _enPress = event.runtimeType.toString();

          // 按下时触发
          final down = event is RawKeyDownEvent;
          if (onlyDown == true && !down) return KeyEventResult.ignored;

          final key = getRawKey(event);
          if (onRawKey != null && key != null) {
            return onRawKey(key, _focusNode, down, event)
                ? KeyEventResult.handled
                : KeyEventResult.ignored;
          }
          return key != null && onKey(key, _focusNode, down)
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
        } else {
          return KeyEventResult.ignored;
        }
      },
    );
  }

  static RawKeyboardKey getRawKey(RawKeyEvent event) {
    if (event.data is RawKeyEventDataMacOs) {
      RawKeyEventDataMacOs data = event.data as dynamic;
      switch (data.keyCode) {
        case 123: // 方向键左
          return RawKeyboardKey.left;
        case 124: // 方向键右
          return RawKeyboardKey.right;
        case 53: // esc
          return RawKeyboardKey.esc;
        case 27: // -
          return RawKeyboardKey.dec;
        case 24: // +
          return RawKeyboardKey.inc;
        case 36: //enter
          return RawKeyboardKey.enter;
      }
    } else if (event.data is RawKeyEventDataAndroid) {
      RawKeyEventDataAndroid data = event.data as dynamic;
      if (kDebugMode) {
        print(data.keyCode);
      }
      switch (data.keyCode) {
        case 21: // 方向键左
          return RawKeyboardKey.left;
        case 19: // 方向键上
          return RawKeyboardKey.top;
        case 22: // 方向键右
          return RawKeyboardKey.right;
        case 20: // 方向键下
          return RawKeyboardKey.bottom;
        case 53: // esc
          return RawKeyboardKey.esc;
        case 69: // -
          return RawKeyboardKey.dec;
        case 59: // +
          return RawKeyboardKey.inc;
        case 23: //电视摇控器方向键中间的确认键
          return RawKeyboardKey.center;
        case 66: //enter
          return RawKeyboardKey.enter;
        case 62: //space
          return RawKeyboardKey.space;
        case 82:
          return RawKeyboardKey.menu;
        case 85:
        case 126:
          return RawKeyboardKey.playOrPause;
        case 89:
          return RawKeyboardKey.playBack;
        case 87:
          return RawKeyboardKey.playNext;
        case 88:
          return RawKeyboardKey.playBack;
        case 0:
          if (data.scanCode == 208) {
            return RawKeyboardKey.playNext;
          }
          break;
      }
    } else if (event.data is RawKeyEventDataLinux) {
      RawKeyEventDataLinux data = event.data as dynamic;
      if (kDebugMode) {
        print(data.keyCode);
      }
    } else if (event.data is RawKeyEventDataWindows) {
      RawKeyEventDataWindows data = event.data as dynamic;
      if (kDebugMode) {
        print(data.keyCode);
      }
      switch (data.keyCode) {
        case 37: // 方向键左
          return RawKeyboardKey.left;
        case 38: // 方向键上
          return RawKeyboardKey.top;
        case 39: // 方向键右
          return RawKeyboardKey.right;
        case 40: // 方向键下
          return RawKeyboardKey.bottom;
        case 27: // esc
          return RawKeyboardKey.esc;
        case 109: // -
        case 189:
          return RawKeyboardKey.dec;
        case 107: // +
        case 187:
          return RawKeyboardKey.inc;
        case 13: //enter
          return RawKeyboardKey.enter;
        case 32: //space
          return RawKeyboardKey.space;
      }
    }
    return null;
  }
}
