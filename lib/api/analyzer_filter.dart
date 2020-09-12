import 'dart:async';
import 'dart:convert';

import 'package:eso/database/rule.dart';
import 'package:flutter_webview/flutter_webview.dart';

import 'analyzer.dart';

Future<dynamic> webview(String url, int duration, Map options) async {
  Completer c = new Completer();
  var webview = FlutterWebview();
  await webview.setMethodHandler((String method, dynamic args) async {
    if (method == "onNavigationCompleted") {
      await Future.delayed(Duration(seconds: duration));
      if (!c.isCompleted)
        c.completeError("Webview Call timeout 10 seconds after page completed.");
    }
    var callback = options[method];
    if (callback != null) if ((await callback(args)) == true) {
      if (!c.isCompleted) c.complete(args);
    }
    return;
  });
  if (options["ua"] != null) await webview.setUserAgent(options["ua"]);
  await webview.navigate(url);
  Future.delayed(Duration(seconds: 100)).then((value) {
    if (!c.isCompleted) c.completeError("Webview Call timeout 100 seconds.");
  });
  try {
    return await c.future;
  } finally {
    await webview.destroy();
  }
}

class AnalyzerFilter implements Analyzer {
  String url;
  Rule _rule;

  AnalyzerFilter(Rule rule) {
    _rule = rule;
  }

  @override
  AnalyzerFilter parse(content) {
    url = "$content".trim();
    if (url.startsWith("//")) {
      if (_rule.host.startsWith("https")) {
        url = "https:" + url;
      } else {
        url = "http:" + url;
      }
    } else if (url.startsWith("/")) {
      url = _rule.host + url;
    }
    return this;
  }

  @override
  Future<List<String>> getElements(String rule) {
    return getStringList(rule);
  }

  @override
  Future<List<String>> getString(String rule) async {
    return getStringList(rule);
  }

  String covertHeaders(Map args) {
    args["headers"] = Map.fromIterable(
      args["headers"],
      key: (e) => (e as Map).keys.first,
      value: (e) => (e as Map).values.first,
    );
    return jsonEncode(args);
  }

  @override
  Future<List<String>> getStringList(String rule) async {
    List<String> result = <String>[];
    final r = rule.split("@@");
    final duration = r.length > 1 ? int.parse(r[1]) : 10;
    await webview(url, duration, {
      "ua": _rule.userAgent.trim().isNotEmpty
          ? _rule.userAgent
          : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36',
      "onRequest": (args) {
        if ((args["url"] as String).contains(RegExp(r[0]))) {
          result.add(covertHeaders(args));
          return true;
        }
        return false;
      }
    });
    return result;
  }
}
