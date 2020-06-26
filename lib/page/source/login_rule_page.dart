import 'package:eso/database/rule.dart';
import 'package:eso/ui/widgets/app_bar_button.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginRulePage extends StatelessWidget {
  final Rule rule;
  const LoginRulePage({this.rule, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${rule.name} 登陆"),
        actions: [
          AppBarButton(
            child: Text("完成登陆 ✅ "),
            onPressed: () {
              rule.cookies = "";
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: WebView(
        initialUrl: rule.loginUrl,
        userAgent: rule.userAgent.isNotEmpty
            ? rule.userAgent
            : 'Mozilla/5.0 (Linux; Android 9; MIX 2 Build/PKQ1.190118.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/80.0.3987.99 Mobile Safari/537.36',
      ),
    );
  }
}
