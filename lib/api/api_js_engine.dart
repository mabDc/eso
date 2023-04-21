/*
 * @Author: your name
 * @Date: 2020-07-17 11:19:01
 * @LastEditTime: 2020-07-25 17:10:43
 * @LastEditors: your name
 * @Description: In User Settings Edit
 * @FilePath: \eso\lib\api\api_const.dart
 */
import 'dart:convert';

import 'package:eso/api/analyze_hetu.dart';
import 'package:eso/api/analyzer_html.dart';
import 'package:eso/api/analyzer_js.dart';
import 'package:eso/api/analyzer_xpath.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/decode_body.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
// import 'package:xpath_parse/xpath_selector.dart';
import 'package:xpath_selector/xpath_selector.dart';
import 'package:http/http.dart' as http;
import '../global.dart';
import '../main.dart';
import 'analyze_url.dart';

class APIConst {
  static final pagePattern =
      RegExp(r"""(\$page)|((^|[^a-zA-Z'"_/-])page([^a-zA-Z0-9'"]|$))""");
  static final largeSpaceRegExp = RegExp(r"\n+\s*|\s{2,}");
  static final tagsSplitRegExp = RegExp(r"[　,/\|\&\%]+");
}

class JSEngine {
  static IsolateQjs _engine;
  static Rule _rule;
  static Rule get rule => _rule;
  static Future<void> initEngine() async {
    if (_engine != null) return;
    final cryptoJS = await rootBundle.loadString(Global.cryptoJSFile);
    _engine = IsolateQjs(stackSize: 1024 * 1024);
    final setToGlobalObject = await _engine.evaluate(";window = globalThis;" +
        cryptoJS +
        ";1+1;" +
        "(key, val) => { this[key] = val; }");
    await setToGlobalObject.invoke([
      "__http__",
      IsolateFunction((dynamic url) async {
        final res = await AnalyzeUrl.parser(url, _rule);
        return DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
      }),
    ]);
    await setToGlobalObject.invoke([
      "__http_byte__",
      IsolateFunction((dynamic url) async {
        final res = await AnalyzeUrl.parser(url, _rule);
        return {"bytes": res.bodyBytes.toList(), "headers": res.headers};
      }),
    ]);
    await setToGlobalObject.invoke([
      "require",
      IsolateFunction((dynamic url) async {
        if (url == null) return null;
        final module = url.toString();
        if (module.startsWith("http")) {
          final res = await http.get(Uri.parse(module));
          return await _engine.evaluate(res.body + ";0;");
        } else {
          try {
            final js = await rootBundle.loadString(
                "lib/assets/" + module.replaceFirst(new RegExp(r".js$"), "") + ".js");
            return await _engine.evaluate(js + ";0;");
          } catch (e) {
            return null;
          }
        }
      }),
    ]);
    await setToGlobalObject.invoke([
      "xpath",
      IsolateFunction((String html, String xpath) async {
        return AnalyzerXPath().parse(html).getString(xpath);
      }),
    ]);
    await setToGlobalObject.invoke([
      "css",
      IsolateFunction((String html, String css) async {
        return AnalyzerHtml().parse(html).getString(css);
      }),
    ]);
    await setToGlobalObject.invoke([
      "toast",
      IsolateFunction((dynamic msg) {
        Utils.toast("$msg");
      }),
    ]);
    setToGlobalObject.free();
    await _engine.evaluate("""
    var http = (url) => __http__(url);
    var httpByte = (url) => __http_byte__(url);
    http.get = (url) => http(url);
    http.post = (url, body, headers) => {
      headers = headers ?? {};
      if(headers["content-type"] === undefined){
        if(typeof(body) === "string"){
          if(body.indexOf("=") > -1){
            headers["content-type"] = "application/x-www-form-urlencoded";
          }else{
            headers["content-type"] = "application/json";
          }
        }else{
          body = JSON.stringify(body);
          headers["content-type"] = "application/json";
        }
      }
      return http({
        url,
        body,
        method: "POST",
        headers
      });
    };
    http.put = (url, body, headers) => {
      headers = headers ?? {};
      if(headers["content-type"] === undefined){
        if(typeof(body) === "string"){
          if(body.indexOf("=") > -1){
            headers["content-type"] = "application/x-www-form-urlencoded";
          }else{
            headers["content-type"] = "application/json";
          }
        }else{
          body = JSON.stringify(body);
          headers["content-type"] = "application/json";
        }
      }
      return http({
        url,
        body,
        method: "PUT",
        headers
      });
    };
    var print = (s, isUrl) => {
      try{
        __print(s, !!isUrl);
      }catch(e){}
    }
    1+1;
    """);
  }

  static Future<void> setFunction(String name, IsolateFunction fun) async {
    await initEngine();
    final setToGlobalObject =
        await _engine.evaluate("(key, val) => { this[key] = val; }");
    await setToGlobalObject.invoke([name, fun]);
    setToGlobalObject.free();
  }

  static String thisBaseUrl;

  static String environment;

  static Future<void> setEnvironment(
    int page,
    Rule rule,
    String result,
    String baseUrl,
    String keyword,
    String lastResult,
  ) async {
    await initEngine();
    _rule = rule;
    thisBaseUrl = baseUrl;
    AnalyzerJS.needSetEnvironmentFlag = true;
    AnalyzerHetu.needSetEnvironmentFlag = true;
    environment = """
page = ${jsonEncode(page)};
host = ${jsonEncode(rule.host)};
cookie = ${jsonEncode(rule.cookies)};
result = ${jsonEncode(result)};
baseUrl = ${jsonEncode(baseUrl)};
keyword = ${jsonEncode(keyword)};
lastResult = ${jsonEncode(lastResult)};""";
//     await _engine.evaluate("""
// page = ${jsonEncode(page)};
// host = ${jsonEncode(rule.host)};
// cookie = ${jsonEncode(rule.cookies)};
// result = ${jsonEncode(result)};
// baseUrl = ${jsonEncode(baseUrl)};
// keyword = ${jsonEncode(keyword)};
// lastResult = ${jsonEncode(lastResult)};
// 1+1;""" +
//         rule.loadJs +
//         ";1+1;");
  }

  static Future<dynamic> evaluate(String command) async {
    await initEngine();
    return _engine.evaluate(command.replaceAll("let ", "var "));
  }

  // static void close() {
  //   _engine.close();
  //   _engine = null;
  // }
}
