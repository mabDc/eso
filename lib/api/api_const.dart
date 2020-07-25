/*
 * @Author: your name
 * @Date: 2020-07-17 11:19:01
 * @LastEditTime: 2020-07-25 17:10:43
 * @LastEditors: your name
 * @Description: In User Settings Edit
 * @FilePath: \eso\lib\api\api_const.dart
 */
import 'dart:convert';

import 'package:eso/database/rule.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

import '../global.dart';

class APIConst {
  static final pagePattern = RegExp(r"""(^|[^a-zA-Z'"_/-])page([^a-zA-Z0-9'"]|$)""");
  static final largeSpaceRegExp = RegExp(r"\n+\s*|\s{2,}");
  static final tagsSplitRegExp = RegExp(r"[　 ,/\|\&\%]+");
  static Future<int> initJSEngine(Rule rule, String baseUrl,
      {String lastResult = "", int engineId}) async {
    engineId = await FlutterJs.initEngine(engineId);
    await FlutterJs.evaluate(
        "host = ${jsonEncode(rule.host)}; cookie = ${jsonEncode(rule.cookies)};baseUrl = ${jsonEncode(baseUrl)}; lastResult = ${jsonEncode(lastResult)};",
        engineId);
    if (rule.loadJs.trim().isNotEmpty || rule.useCryptoJS) {
      final cryptoJS =
          rule.useCryptoJS ? await rootBundle.loadString(Global.cryptoJSFile) : "";
      await FlutterJs.evaluate(cryptoJS + ";1+1;" + rule.loadJs + ";1+1;", engineId);
    }
    return engineId;
  }
}
