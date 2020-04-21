import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class FlutterJs {
  static bool DEBUG = false;
  static const MethodChannel _channel =
      const MethodChannel('io.abner.flutter_js');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> evaluateOrginal(String command, int id,
      {String convertTo = ""}) async {
    var arguments = {
      "engineId": id,
      "command": command,
      "convertTo": convertTo
    };
    final rs = await _channel.invokeMethod("evaluate", arguments);
    final String jsResult = rs is Map || rs is List ? json.encode(rs) : rs;
    if (DEBUG) {
      print("${DateTime.now().toIso8601String()} - JS RESULT : $jsResult");
    }
    return jsResult ?? "null";
  }

  static Future<int> initEngine() async {
    final int engineId = await _channel.invokeMethod("initEngine", 1);
    return engineId;
  }

  static Future<dynamic> evaluate(String command, int id,
      {String convertTo = ""}) async {
    var arguments = {
      "engineId": id,
      "command": command,
      "convertTo": convertTo
    };
    final rs = await _channel.invokeMethod("evaluate", arguments);
    if (DEBUG) {
      print("${DateTime.now().toIso8601String()} - JS RESULT : $rs");
    }
    return rs;
  }

  static Future<String> getString(String command, int id) async {
    final rs = await evaluate(command, id, convertTo: "String");
    return rs ?? '';
  }

  static Future<List<String>> getStringList(String command, int id) async {
    final rs = await evaluate(command, id, convertTo: "array");
    if (rs == null) return <String>[];
    return (rs as List).map((r) => '$r').toList();
  }

  static Future<Map<dynamic, dynamic>> getMap(String command, int id) async {
    final rs = await evaluate(command, id, convertTo: "object");
    return rs ?? Map<String, String>();
  }
}
