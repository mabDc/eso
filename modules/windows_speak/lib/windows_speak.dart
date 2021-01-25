import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class WindowsSpeak {
  static const MethodChannel _channel = const MethodChannel('windows_speak');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static VoidCallback handleComplete;

  static Future<bool> speak(String s) async {
    if (s == null) return false;
    final r = await _channel.invokeMethod('speak', s);
    if (r is bool && r == true) {
      if (handleComplete != null) handleComplete();
      return true;
    }
    return false;
  }
}
