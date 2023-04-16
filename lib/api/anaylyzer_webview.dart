import 'dart:async';
import 'dart:convert';
import 'dart:developer';

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

  // 格式形如 @web:[(baseUrl|result)@@][script]
  Future _eval(String rule) async {
    Completer c = Completer();
    rule = rule.trimLeft();
    var url = JSEngine.thisBaseUrl?.trim();

    if (rule.startsWith("result@@")) {
      url = _content;
      rule = rule.substring(8);
    } else if (rule.startsWith("baseUrl@@")) {
      rule = rule.substring(9);
    }
    if (url == null || url.isEmpty) {
      url = JSEngine.rule.host;
    }
    if (url.startsWith("//")) {
      url = JSEngine.rule.host.startsWith("https") ? "https://$url" : "http://$url";
    } else if (url.startsWith("/")) {
      url = Uri.parse(JSEngine.rule.host).resolve(url).toString();
    }
    var webview = FlutterWebview();
    await webview.setMethodHandler((String method, dynamic args) async {
      if (kDebugMode) {
        print(method);
      }
      if (method == "onNavigationCompleted") {
        for (var i = 0; i < 60; i++) {
          if (c.isCompleted) return;
          try {
            final s = await webview.evaluate(
                rule.trim().isEmpty ? "document.documentElement.outerHTML" : rule);
            final r = jsonDecode("$s");
            if (r != null && r != "") {
              c.complete(r);
              return;
            }
          } catch (e) {}
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
    });
    await webview.navigate(url);
    Future.delayed(Duration(seconds: 30)).then((value) {
      if (c.isCompleted) return;
      c.completeError("执行webview规则超过30秒 加载超时");
    });
    try {
      return await c.future;
    } finally {
      await webview.destroy();
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
