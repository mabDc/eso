export 'global.dart';

import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

export 'package:cached_network_image/cached_network_image.dart';
export 'fonticons_icons.dart';
export 'ui/widgets/app_bar_button.dart';
export 'ui/widgets/app_bar_ex.dart';
export 'utils/size_utils.dart';

/// 事件bus
EventBus eventBus = EventBus();

class Utils {
  /// 时间字符串显示
  static String formatDuration(Duration d) {
    final s = d.toString().split(".")[0];
    if (d.inHours == 0) {
      return "${s.split(":")[1]}:${s.split(":")[2]}";
    } else {
      return s;
    }
  }

  static bool get isDesktop => Platform.isWindows || Platform.isMacOS;

  static bool empty(String value) {
    return value == null || value.isEmpty;
  }

  /// 延时指定毫秒
  static sleep(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// 显示 Toast 消息
  static toast(String msg,
      {Duration duration,
      ToastPosition position = ToastPosition.bottom,
      bool dismissOtherToast}) {
    if (empty(msg)) return;
    showToast(msg,
        position: position, duration: duration, dismissOtherToast: dismissOtherToast);
  }

  /// 清除输入焦点
  static unFocus(BuildContext context) {
    var f = FocusScope.of(context);
    if (f != null && f.hasFocus) f.unfocus(disposition: UnfocusDisposition.scope);
  }

  /// 开始一个页面，并等待结束
  static Future<Object> startPageWait(BuildContext context, Widget page,
      {bool replace}) async {
    if (page == null) return null;
    var rote = Platform.isIOS
        ? CupertinoPageRoute(builder: (context) => page)
        : MaterialPageRoute(builder: (_) => page);
    if (replace == true) return await Navigator.pushReplacement(context, rote);
    return await Navigator.push(context, rote);
  }

  static String _downloadPath;

  /// 提取文件名（不包含路径和扩展名）
  static String getFileName(final String file) {
    return path.basenameWithoutExtension(file);
  }

  /// 提取文件名（包扩展名）
  static String getFileNameAndExt(final String file) {
    return path.basename(file);
  }

  /// 检测路径是否存在
  static bool existPath(final String _path) {
    return Directory(_path).existsSync();
  }

  /// 获取下载目录
  static Future<String> getDownloadsPath() async {
    if (Platform.isIOS)
      return (await getApplicationDocumentsDirectory()).path;
    else {
      if (_downloadPath == null) {
        _downloadPath = (await getExternalStorageDirectory()).path;
        if (!(existPath(_downloadPath)))
          _downloadPath = (await getTemporaryDirectory()).path;
      }
      print("downloadPath: $_downloadPath");
      return _downloadPath;
    }
  }

  /// 连接字符串
  static _StrBuilder link(String a, String b, {String divider = ' '}) {
    return _StrBuilder(a, divider: divider).link(b);
  }
}

class _StrBuilder {
  String value;
  final String divider;
  _StrBuilder(this.value, {this.divider: ' '});

  _StrBuilder link(String value, {String divider}) {
    bool _a = this.value == null || this.value.isEmpty;
    bool _b = value == null || value.isEmpty;
    this.value = _a || _b
        ? (_a ? value : this.value)
        : (this.value + (divider == null ? (this.divider ?? ' ') : divider) + value);
    return this;
  }
}
