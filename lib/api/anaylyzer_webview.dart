import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:eso/api/api_js_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webview/flutter_webview.dart';

import 'analyzer.dart';

class AnalyzerWebview implements Analyzer {
  String _content;
  @override
  AnalyzerWebview parse(content) {
    if (content == null) {
      _content = "";
    } else if (content is List && content.isEmpty) {
      _content = "";
    } else if (content is Map && content.isEmpty) {
      _content = "";
    } else {
      _content = "$content".trim();
    }
    return this;
  }

  // 格式形如 @web:[(baseUrl|result)@@]script0[\n\s*@@\s*\nscript1]
  Future _eval(String rule) async {
    Completer c = Completer();
    rule = rule.trimLeft();
    var url = JSEngine.thisBaseUrl?.trim();

    if (rule.startsWith("result@@")) {
      url = _content;
      rule.substring(8);
    } else if (rule.startsWith("baseUrl@@")) {
      rule.substring(9);
    }
    if (url == null || url.isEmpty) {
      url = JSEngine.rule.host;
    }
    if (url.startsWith("//")) {
      url = JSEngine.rule.host.startsWith("https") ? "https://$url" : "http://$url";
    } else if (url.startsWith("/")) {
      url = JSEngine.rule.host + url;
    }
    final script = rule.split(RegExp("\n\s*@@\s*\n"));
    if (Platform.isWindows || Platform.isAndroid) {
      var webview = FlutterWebview();
      await webview.setMethodHandler((String method, dynamic args) async {
        if (kDebugMode) {
          print(method);
        }
        if (method == "onNavigationCompleted" && !c.isCompleted) {
          try {
            final s = await webview.evaluate(script[0].trim().isEmpty
                ? "document.documentElement.outerHTML"
                : script[0]);
            c.complete(jsonDecode("$s"));
          } catch (e) {
            c.completeError(e);
          }
        }
      });
      await webview.navigate(url, script: script.length == 2 ? script[1] : "");
      Future.delayed(Duration(seconds: 10)).then((value) {
        if (!c.isCompleted) c.completeError("Webview Call timeout 10 seconds.");
      });
      try {
        return await c.future;
      } finally {
        await webview.destroy();
      }
    } else {
      throw "webview不支持";
    }
  }

  @override
  Future getElements(String rule) {
    return _eval(rule);
  }

  @override
  Future getString(String rule) {
    return _eval(rule);
  }

  @override
  Future getStringList(String rule) {
    return _eval(rule);
  }
}
