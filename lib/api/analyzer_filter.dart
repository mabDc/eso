import 'dart:async';

import 'package:eso/database/rule.dart';
import 'package:flutter_webview/flutter_webview.dart';

import 'analyzer.dart';

Future<dynamic> webview(String url, Map options) async {
  Completer c = new Completer();
  var webview = FlutterWebview();
  await webview.setMethodHandler((String method, dynamic args) async {
    print("$method($args)");
    if (method == "onNavigationCompleted") {
      await Future.delayed(Duration(seconds: 10));
      if (!c.isCompleted)
        c.completeError("Webview Call timeout 10 seconds after page completed.");
    }
    var callback = options[method];
    if (callback != null) if ((await callback([args])) == true) {
      print(args);
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
  Future<String> getElements(String rule) {
    return getString(rule);
  }

  @override
  Future<String> getString(String rule) async {
    final r = await webview(url, {
      "ua": _rule.userAgent.trim().isNotEmpty
          ? _rule.userAgent
          : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36',
      "onRequest": (o) {
        if (o["url"].includes(RegExp(rule))) return true;
        return false;
      }
    });
    return null == r ? "" : "$r";
  }

  @override
  Future<String> getStringList(String rule) {
    return getString(rule);
  }
}
