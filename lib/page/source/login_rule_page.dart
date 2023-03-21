import 'dart:async';

import 'package:eso/database/rule.dart';
import 'package:eso/main.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../fonticons_icons.dart';

class LoginRulePage extends StatelessWidget {
  final Rule rule;
  const LoginRulePage({this.rule, Key key}) : super(key: key);

  Future<bool> setCookies() async {
    return await MethodChannel('plugins.flutter.io/cookie_manager').invokeMethod<bool>(
      'setCookies',
      <String, dynamic>{
        'url': rule.loginUrl,
        'cookies': rule.cookies.split(RegExp(r';\s*')),
      },
    );
  }

  Future<String> getCookies() async {
    return await MethodChannel('plugins.flutter.io/cookie_manager').invokeMethod<String>(
      'getCookies',
      <String, String>{
        'url': rule.loginUrl,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Completer<WebViewController> _controller = Completer<WebViewController>();
    if (rule.cookies != null && rule.cookies.isNotEmpty) {
      setCookies();
    }
    return WillPopScope(
      onWillPop: () async {
        final controller = await _controller.future;
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        } else {
          Utils.toast("保存请按右上角\n取消请按左上角");
          return false;
        }
      },
      child: Container(
        decoration: globalDecoration,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.close,
                size: 28,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              "登录 ${rule.name}",
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                ),
                onPressed: () async {
                  final controller = await _controller.future;
                  if (await controller.canGoBack()) {
                    controller.goBack();
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                ),
                onPressed: () async {
                  final controller = await _controller.future;
                  if (await controller.canGoForward()) {
                    controller.goForward();
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  FIcons.check,
                  size: 28,
                ),
                onPressed: () async {
                  final cookies = await getCookies();
                  rule.cookies = cookies;
                  Navigator.of(context).pop(cookies);
                },
              ),
            ],
          ),
          body: WebView(
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            initialUrl: rule.loginUrl,
            userAgent: rule.userAgent.isNotEmpty
                ? rule.userAgent
                : 'Mozilla/5.0 (Linux; Android 9; MIX 2 Build/PKQ1.190118.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/80.0.3987.99 Mobile Safari/537.36',
          ),
        ),
      ),
    );
  }
}
