import 'dart:async';

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
        c.completeError("Webview Call timeout $duration seconds after page completed.");
    }
    var callback = options[method];
    if (callback != null) if ((await callback(args)) == true) {
      if (!c.isCompleted) c.complete(args);
    }
    return;
  });
  if (options["ua"] != null) await webview.setUserAgent(options["ua"]);
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
  Rule _rule;

  AnalyzerFilter(Rule rule) {
    _rule = rule;
  }

  @override
  AnalyzerFilter parse(content) {
    if (content is List) {
      final t = content.map((c) => "$c").where((c) => c.isNotEmpty).toList();
      if (t.isNotEmpty) {
        url = t.first.trim();
      } else {
        url = _rule.host;
      }
    } else if (content is Map) {
      url = "${content["url"]}";
    } else {
      url = "$content".trim();
    }
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
    final duration = r.length > 1 ? int.parse(r[1]) : 8;
    await webview(url, duration, {
      "ua": _rule.userAgent.trim().isNotEmpty
          ? _rule.userAgent
          : 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.42 Safari/537.36 Edg/86.0.622.19',
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
