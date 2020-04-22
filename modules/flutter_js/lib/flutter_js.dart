import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

class FlutterJs {
  static bool DEBUG = false;
  static const MethodChannel _channel =
  const MethodChannel('io.abner.flutter_js');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> initEngine() async {
    final int engineId = await _channel.invokeMethod("initEngine", new Random().nextInt(100));
    return engineId;
  }

  static Future<dynamic> evaluate(String command, int id) async {
    var arguments = {
      "engineId": id,
      "command": command
    };
    final rs = await _channel.invokeMethod("evaluate", arguments);
    if (DEBUG) {
      print("${DateTime.now().toIso8601String()} - JS RESULT : $rs");
    }
    return rs;
  }

  static Future<String> getString(String command, int id) async {
    final rs = await evaluate(command, id);
    return rs ?? '';
  }

  static Future<List<String>> getStringList(String command, int id) async {
    final rs = await evaluate(command, id);
    if (rs == null) return <String>[];
    return (jsonDecode(rs) as List).map((r) => '$r').toList();
  }

  static Future<Map<dynamic, dynamic>> getMap(String command, int id) async {
    final rs = await evaluate(command, id);
    return jsonDecode(rs) ?? Map<String, String>();
  }
}
