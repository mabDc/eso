import 'dart:async';

import 'package:eso/api/api_js_engine.dart';
import 'package:flutter_webview/flutter_webview.dart';

import 'analyzer.dart';

Future<dynamic> webview({
  String url,
  int duration,
  bool Function(dynamic args) callback,
  String ua,
  String cookies,
}) async {
  Completer c = new Completer();
  var webview = FlutterWebview();
  await webview.setMethodHandler((String method, dynamic args) async {
    if (method == "onNavigationCompleted") {
      await Future.delayed(Duration(seconds: duration));
      if (!c.isCompleted)
        c.completeError("Webview Call timeout $duration seconds after page completed.");
    }
    if (callback(args) == true && !c.isCompleted) {
      c.complete(args);
    }
    return;
  });
  if (ua != null && ua.isNotEmpty) await webview.setUserAgent(ua);
  if (cookies != null && cookies.isNotEmpty) await webview.setCookies(url, cookies);
  await webview.navigate(url);
  Future.delayed(Duration(seconds: duration * 5)).then((value) {
    if (!c.isCompleted) c.completeError("Webview Call timeout ${duration * 5} seconds.");
  });
  try {
    return await c.future;
  } finally {
    await webview.destroy();
  }
}

class AnalyzerFilter implements Analyzer {
  String url;

  @override
  AnalyzerFilter parse(content) {
    final host = JSEngine.rule.host;
    if (content is List) {
      final t = content.map((c) => "$c").where((c) => c.isNotEmpty).toList();
      if (t.isNotEmpty) {
        url = t.first.trim();
      } else {
        url = host;
      }
    } else if (content is Map) {
      url = "${content["url"]}";
    } else {
      url = "$content".trim();
    }
    if (url.startsWith("//")) {
      if (host.startsWith("https")) {
        url = "https:" + url;
      } else {
        url = "http:" + url;
      }
    } else if (url.startsWith("/")) {
      url = host + url;
    }
    return this;
  }

  @override
  Future<List<Map>> getElements(String rule) {
    return getStringList(rule);
  }

  @override
  Future<List<Map>> getString(String rule) async {
    return getStringList(rule);
  }

  Map covertHeaders(Map args) {
    args["headers"] = Map.fromIterable(
      args["headers"],
      key: (e) => (e as Map).keys.first,
      value: (e) => (e as Map).values.first,
    );
    return args;
  }

  @override
  Future<List<Map>> getStringList(String rule) async {
    List<Map> result = <Map>[];
    final r = rule.split("@@");
    if (url.contains(RegExp(r[0]))) {
      return [
        {"url": url},
      ];
    }
    final duration = r.length > 1 ? int.parse(r[1]) : 10;
    await webview(
      url: url,
      duration: duration,
      callback: (args) {
        if ((args["url"] as String).contains(RegExp(r[0]))) {
          result.add(covertHeaders(args));
          return true;
        }
        return false;
      },
      ua: JSEngine.rule.userAgent.trim().isNotEmpty
          ? JSEngine.rule.userAgent
          : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.42 Safari/537.36 Edg/86.0.622.19',
      cookies: JSEngine.rule.cookies,
    );
    return result;
  }
}
