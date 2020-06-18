export 'global.dart';

import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

export 'package:cached_network_image/cached_network_image.dart';

/// 事件bus
EventBus eventBus = EventBus();

class Utils {

  static bool empty(String value) {
    return value == null || value.isEmpty;
  }

  /// 延时指定毫秒
  static sleep(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// 清除输入焦点
  static unFocus(BuildContext context) {
    var f = FocusScope.of(context);
    if (f != null && f.hasFocus)
      f.unfocus(disposition: UnfocusDisposition.scope);
  }


  /// 开始一个页面，并等待结束
  static Future<Object> startPageWait(BuildContext context, Widget page) async {
    if (page == null) return null;
    var rote = Platform.isIOS ? CupertinoPageRoute(builder: (context) => page) :
      MaterialPageRoute(builder: (_) => page);
    return await Navigator.push(context, rote);
  }

}