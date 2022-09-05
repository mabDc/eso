import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eso/api/api_js_engine.dart';
import 'package:eso/global.dart';
import 'package:flutter_webview/flutter_webview.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'analyzer.dart';

Future<dynamic> webviewIOS({
  String url,
  int duration,
  bool Function(dynamic args) callback,
  String ua,
  String cookies,
}) async {
  Completer c = new Completer();
  InAppWebViewController webViewController;
  Map<String, String> headers;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      userAgent: Global.userAgent,
      useOnLoadResource: true,
      clearCache: true,
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    ios: IOSInAppWebViewOptions(
      sharedCookiesEnabled: false,
      allowsInlineMediaPlayback: true,
    ),
  );
  onLoadResource(
      InAppWebViewController controller, LoadedResource resource) async {
    String url = resource.url.toString();
    Map args = {
      "headers": [
        {"Accept": "*/*"},
        {"User-Agent": Global.userAgent},
      ],
      "url": url
    };
    if (callback(args) == true && !c.isCompleted) {
      c.complete(args);
    }
  }

  onWebViewCreated(InAppWebViewController controller) {
    if (webViewController == null) {
      webViewController = controller;
    }
  }

  onLoadStop(InAppWebViewController controller, Uri uri) {
    if ((uri as String).isNotEmpty) {
      Future.delayed(Duration(seconds: duration), () {
        c.completeError("网络错误;嗅探失败!");
      });
    }
  }

  HeadlessInAppWebView hlswebview = HeadlessInAppWebView(
    shouldOverrideUrlLoading: (controller, navigationAction) async {
      headers = navigationAction.request.headers;
      return NavigationActionPolicy.ALLOW;
    },
    onLoadResource: onLoadResource,
    initialOptions: options,
    onWebViewCreated: onWebViewCreated,
    onLoadStop: onLoadStop,
  );
  await hlswebview.run();
  await webViewController.loadUrl(
    urlRequest: URLRequest(
      url: Uri.parse(url),
      headers: {
        'Cookie': (cookies != null && cookies.isNotEmpty) ? cookies : '',
      },
    ),
  );
  Future.delayed(Duration(seconds: duration * 5)).then((value) {
    if (!c.isCompleted)
      c.completeError("Webview Call timeout ${duration * 5} seconds.");
  });
  try {
    return await c.future;
  } finally {
    await webViewController.stopLoading();
    await hlswebview.dispose();
  }
}

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
        c.completeError(
            "Webview Call timeout $duration seconds after page completed.");
    }
    if (callback(args) == true && !c.isCompleted) {
      c.complete(args);
    }
    return;
  });
  if (ua != null && ua.isNotEmpty) await webview.setUserAgent(ua);
  if (!Platform.isWindows) {
    if (cookies != null && cookies.isNotEmpty)
      await webview.setCookies(url, cookies);
  }
  await webview.navigate(url);
  Future.delayed(Duration(seconds: duration * 5)).then((value) {
    if (!c.isCompleted)
      c.completeError("Webview Call timeout ${duration * 5} seconds.");
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
    print("嗅探正则:${r[0]}");

    if (Platform.isIOS) {
      await webviewIOS(
        url: url,
        duration: duration,
        callback: (args) {
          print("args.url:${args['url']}");
          if ((args["url"] as String).contains(RegExp(r[0]))) {
            result.add(covertHeaders(args));
            return true;
          }
          return false;
        },
        ua: JSEngine.rule.userAgent.trim().isNotEmpty
            ? JSEngine.rule.userAgent
            : Global.userAgent,
        cookies: JSEngine.rule.cookies,
      );
    } else if (Platform.isAndroid || Platform.isWindows) {
      await webview(
        url: url,
        duration: duration,
        callback: (args) {
          print("args.url:${args["url"]}");
          if ((args["url"] as String).contains(RegExp(r[0]))) {
            print("匹配成功 .args:${args}");
            if (Platform.isWindows) {
              Map requestMap = {
                "headers": [
                  {"Accept": "*/*"},
                  {"User-Agent": Global.userAgent},
                  {"Connection": "keep-alive"},
                  {"Accept-Encoding": "gzip, deflate"},
                  {
                    "Accept-Language":
                        "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
                  },
                ],
                "url": (args["url"] as String)
              };
              result.add(covertHeaders(requestMap));
            } else {
              result.add(covertHeaders(args));
            }
            return true;
          }
          return false;
        },
        ua: JSEngine.rule.userAgent.trim().isNotEmpty
            ? JSEngine.rule.userAgent
            : Global.userAgent,
        cookies: JSEngine.rule.cookies,
      );
    }

    return result;
  }
}
