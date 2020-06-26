import 'dart:async';
import 'dart:convert';

import 'package:eso/database/rule.dart';
import 'package:eso/ui/widgets/app_bar_button.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginRulePage extends StatelessWidget {
  final Rule rule;
  const LoginRulePage({this.rule, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Completer<WebViewController> _controller = Completer<WebViewController>();
    return Scaffold(
      appBar: AppBar(
        title: Text("登陆 ${rule.name}"),
        actions: [
          AppBarButton(
            icon: Icon(
              FIcons.check,
              size: 28,
            ),
            onPressed: () async {
              final controller = await _controller.future;
              final String cookies =
                  await controller.evaluateJavascript('document.cookie');
              rule.cookies = jsonDecode(cookies);
              Navigator.of(context).pop(cookies);
            },
          )
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
    );
  }
}
