import 'dart:async';
import 'dart:io';

import 'package:eso/database/rule.dart';
import 'package:eso/ui/widgets/app_bar_button.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginRulePage extends StatelessWidget {
  final Rule rule;
  const LoginRulePage({this.rule, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Completer<WebViewController> _controller = Completer<WebViewController>();
    final CookieManager cookieManager = CookieManager();
    if (rule.cookies != null && rule.cookies.isNotEmpty) {
      final cookies = rule.cookies.split(RegExp(r";\s*")).map((cookie) {
        final p = cookie.indexOf("=");
        if (p == -1) {
          return Cookie(cookie, "");
        } else {
          return Cookie(cookie.substring(0, p), cookie.substring(p + 1));
        }
      }).toList();
      cookieManager.setCookies(rule.loginUrl, cookies);
    }
    return WillPopScope(
      onWillPop: () async {
        Toast.show("保存请按右上角\n取消请按左上角", context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppBarButton(
            icon: Icon(
              Icons.close,
              size: 28,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          title: Text("登录 ${rule.name}"),
          actions: [
            AppBarButton(
              icon: Icon(
                FIcons.check,
                size: 28,
              ),
              onPressed: () async {
                final cookies = await cookieManager.getCookies(rule.loginUrl);
                final cookiesString =
                    cookies.map((cookie) => cookie.toString()).join("; ");
                rule.cookies = cookiesString;
                Navigator.of(context).pop(cookiesString);
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
    );
  }
}
