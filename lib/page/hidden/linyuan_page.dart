import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';

import '../../utils.dart';

class LinyuanPage extends StatelessWidget {
  const LinyuanPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final yuque = "https://www.yuque.com/mrlinyuan";
    final icon =
        "https://cdn.nlark.com/yuque/0/2021/png/12924434/1628124182247-avatar/48d73035-8ee5-44ac-bbb2-0583092a4985.png?x-oss-process=image%2Fresize%2Cm_fill%2Cw_328%2Ch_328%2Fformat%2Cpng";
    return LaunchUrlWithWebview(
      title: "临渊的语雀",
      url: yuque,
      icon: icon,
    );
  }
}

class LaunchUrlWithWebview extends StatelessWidget {
  final String url;
  final String title;
  final String icon;
  const LaunchUrlWithWebview({Key key, this.url, this.title, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isWindows
        ? WebInAppWindows(url: url, title: title, icon: icon)
        : Platform.isAndroid
            ? WebInAppAndroid(url: url, title: title, icon: icon)
            : Scaffold(
                appBar: AppBar(
                  leadingWidth: 30,
                  title: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(icon),
                    ),
                    title: Text(title),
                    subtitle: Text(url),
                  ),
                  //Column(children: [Text(title)]),
                  actions: [
                    IconButton(
                        onPressed: () {
                          launchUrl(Uri.parse(url));
                        },
                        tooltip: "在浏览器打开",
                        icon: Icon(Icons.open_in_browser))
                  ],
                ),
                body: Container(
                  child: Text(url),
                ));
  }
}

class WebInAppAndroid extends StatelessWidget {
  final String url;
  final String title;
  final String icon;
  WebInAppAndroid({Key key, this.url, this.title, this.icon}) : super(key: key);

  // Future<bool> setCookies() async {
  //   return await MethodChannel('plugins.flutter.io/cookie_manager').invokeMethod<bool>(
  //     'setCookies',
  //     <String, dynamic>{
  //       'url': rule.loginUrl,
  //       'cookies': rule.cookies.split(RegExp(r';\s*')),
  //     },
  //   );
  // }

  // Future<String> getCookies() async {
  //   return await MethodChannel('plugins.flutter.io/cookie_manager').invokeMethod<String>(
  //     'getCookies',
  //     <String, String>{
  //       'url': rule.loginUrl,
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final Completer<WebViewController> _controller = Completer<WebViewController>();

    return WillPopScope(
      onWillPop: () async {
        final controller = await _controller.future;
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        } else {
          Utils.toast("退出请按左上角");
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.close,
              size: 28,
            ),
            tooltip: "关闭",
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          leadingWidth: 30,
          title: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(icon),
            ),
            title: Text(title),
            subtitle: Text(url),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
              tooltip: "后退",
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
              tooltip: "前进",
              onPressed: () async {
                final controller = await _controller.future;
                if (await controller.canGoForward()) {
                  controller.goForward();
                }
              },
            ),
            IconButton(
                onPressed: () {
                  launchUrl(Uri.parse(url));
                },
                tooltip: "在浏览器打开",
                icon: Icon(Icons.open_in_browser))
          ],
        ),
        body: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          initialUrl: url,
        ),
      ),
    );
  }
}

class WebInAppWindows extends StatefulWidget {
  final String url;
  final String title;
  final String icon;
  WebInAppWindows({Key key, this.url, this.title, this.icon}) : super(key: key);

  @override
  State<WebInAppWindows> createState() => _WebInAppWindowsState();
}

class _WebInAppWindowsState extends State<WebInAppWindows> {
  final WebviewController webviewController = WebviewController();
  @override
  void initState() {
    if (Platform.isWindows) initWindows();
    super.initState();
  }

  initWindows() async {
    if (!webviewController.value.isInitialized) {
      await webviewController.initialize();
      await webviewController.loadUrl(widget.url);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30,
        title: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.icon),
          ),
          title: Text(widget.title),
          subtitle: Text(widget.url),
        ),
        //Column(children: [Text(title)]),
        actions: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
            tooltip: "后退",
            onPressed: () async {
              webviewController.goBack();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 20,
            ),
            tooltip: "前进",
            onPressed: () async {
              webviewController.goForward();
            },
          ),
          IconButton(
              onPressed: () {
                launchUrl(Uri.parse(widget.url));
              },
              tooltip: "在浏览器打开",
              icon: Icon(Icons.open_in_browser))
        ],
      ),
      body: Webview(
        webviewController,
        width: m.width,
        height: m.height,
      ),
    );
  }
}
