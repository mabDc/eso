import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

class LinyuanPage extends StatelessWidget {
  const LinyuanPage({Key key}) : super(key: key);

  final yuque = "https://www.yuque.com/mrlinyuan";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("施工ing")),
    );
    final WebviewController webviewController = WebviewController();
    (() async {
      if (!webviewController.value.isInitialized) await webviewController.initialize();
      webviewController.loadUrl(yuque);
    })();
    return Scaffold(
      body: Webview(webviewController),
    );
  }
}
