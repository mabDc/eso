/*
 * @Description: quickjs engine
 * @Author: ekibun
 * @Date: 2020-08-08 08:29:09
 * @LastEditors: ekibun
 * @LastEditTime: 2020-08-25 23:22:01
 */
import 'dart:async';
import 'package:flutter/services.dart';

/// Handle function to manage js call with `dart(method, ...args)` function.
typedef MethodHandler = Future<dynamic> Function(String method, dynamic args);

/// return this in [MethodHandler] to mark method not implemented.
class MethodHandlerNotImplement {}

/// FlutterWebview instance.
/// Each [FlutterWebview] object creates a new webview instance.
/// Make sure call `destroy` when you don't need it.
class FlutterWebview {
  dynamic _webview;

  _ensureEngine() async {
    if (_webview == null) {
      _webview = await _FlutterWebview.instance._channel.invokeMethod("create");
      print(_webview);
    }
  }

  /// Set a handler to manage webview event.
  setMethodHandler(MethodHandler handler) async {
    await _ensureEngine();
    _FlutterWebview.instance.methodHandlers[_webview] = handler;
  }

  /// destroy webview and release memory.
  destroy() async {
    if (_webview != null) {
      await _FlutterWebview.instance._channel.invokeMethod("close", _webview);
      _webview = null;
    }
  }

  Future<void> setUserAgent(String ua) async {
    await _ensureEngine();
    var arguments = {"webview": _webview, "ua": ua};
    return _FlutterWebview.instance._channel.invokeMethod("setUserAgent", arguments);
  }

  Future<void> setCookies(String url, String cookies) async {
    await _ensureEngine();
    var arguments = {"webview": _webview, "cookies": cookies, "url": url};
    return _FlutterWebview.instance._channel.invokeMethod("setCookies", arguments);
  }

  Future<bool> navigate(String url, {String script}) async {
    await _ensureEngine();
    var arguments = {"webview": _webview, "url": url, "script": script ?? ""};
    return _FlutterWebview.instance._channel.invokeMethod("navigate", arguments);
  }

  Future<dynamic> evaluate(String script) async {
    await _ensureEngine();
    var arguments = {"webview": _webview, "script": script};
    return _FlutterWebview.instance._channel.invokeMethod("evaluate", arguments);
  }
}

class _FlutterWebview {
  factory _FlutterWebview() => _getInstance();
  static _FlutterWebview get instance => _getInstance();
  static _FlutterWebview _instance;
  MethodChannel _channel = const MethodChannel('soko.ekibun.flutter_webview');
  Map<dynamic, MethodHandler> methodHandlers = Map<dynamic, MethodHandler>();
  _FlutterWebview._internal() {
    _channel.setMethodCallHandler((call) async {
      try {
        var engine = call.arguments["webview"];
        var args = call.arguments["args"];
        if (methodHandlers[engine] == null) return call.noSuchMethod(null);
        var ret = await methodHandlers[engine](call.method, args);
        if (ret is MethodHandlerNotImplement) return call.noSuchMethod(null);
        return ret;
      } catch (e) {
        print(e);
      }
    });
  }

  static _FlutterWebview _getInstance() {
    if (_instance == null) {
      _instance = new _FlutterWebview._internal();
    }
    return _instance;
  }
}
