import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';

class FlutterJs {
  static const MethodChannel _channel = const MethodChannel('io.abner.flutter_js');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> initEngine([int id]) async {
    final int engineId =
        await _channel.invokeMethod("initEngine", id ?? new Random().nextInt(1000));
    return engineId;
  }

  static Future<dynamic> evaluate(String command, int id) async {
    if (Platform.isLinux) return null;
    var arguments = {"engineId": id, "command": command};
    final rs = await _channel.invokeMethod("evaluate", arguments);
    if (Platform.isAndroid || Platform.isWindows) return jsonDecode(rs);
    return rs;
  }

  static Future<bool> close(int id) async {
    if (id == null) return false;
    if (Platform.isLinux) return false;
    var arguments = {"engineId": id};
    _channel.invokeMethod("close", arguments);
    return true;
  }
}
