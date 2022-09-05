import 'dart:async';

import 'package:eso/api/analyzer_filter.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/global.dart';
import 'package:eso/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as InApp;

import '../../fonticons_icons.dart';

class LoginRulePage extends StatefulWidget {
  final Rule rule;
  const LoginRulePage({this.rule, Key key}) : super(key: key);

  @override
  _LoginRulePageState createState() => _LoginRulePageState();
}

class _LoginRulePageState extends State<LoginRulePage> {
  InApp.InAppWebViewController _webViewController;
  InApp.CookieManager _cookieManager;

  InApp.InAppWebViewGroupOptions options = InApp.InAppWebViewGroupOptions(
    crossPlatform: InApp.InAppWebViewOptions(
      userAgent: Global.userAgent,
      // useOnLoadResource: true,
      clearCache: true,
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
    ),
    android: InApp.AndroidInAppWebViewOptions(),
    ios: InApp.IOSInAppWebViewOptions(
      sharedCookiesEnabled: false,
      allowsInlineMediaPlayback: true,
    ),
  );
  @override
  void initState() {
    super.initState();
    _cookieManager = InApp.CookieManager.instance();
    if (widget.rule.userAgent.isNotEmpty) {
      options.crossPlatform.userAgent = widget.rule.userAgent;
    }
  }

  bool isStop = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("登陆"),
          leading: CupertinoButton(
            child: Text("完成"),
            padding: EdgeInsets.zero,
            onPressed: () async {
              await _webViewController.stopLoading();

              final cookies = await _cookieManager.getCookies(
                  url: Uri.parse(widget.rule.loginUrl));

              final cookie =
                  cookies.map((e) => "${e.name}=${e.value}").join(';');
              widget.rule.cookies = cookie;

              print("cookies:${cookie}");

              Navigator.of(context).pop(cookie);
            },
          ),
          trailing: isStop
              ? GestureDetector(
                  onTap: () => this.setState(() {
                    isStop = false;
                    _webViewController.reload();
                  }),
                  child: Icon(CupertinoIcons.refresh_thin, size: 22),
                )
              : CupertinoActivityIndicator(),
        ),
        child: SafeArea(
          child: InApp.InAppWebView(
            initialOptions: options,
            initialUrlRequest: InApp.URLRequest(
              url: Uri.parse(widget.rule.loginUrl),
            ),
            onLoadStop: (controller, url) => this.setState(() => isStop = true),
            onWebViewCreated: (controller) {
              _webViewController = controller;

              setState(() => null);
            },
          ),
        ),
      ),
    );
  }
}

// class LoginRulePage extends StatelessWidget {
//   final Rule rule;
//   const LoginRulePage({this.rule, Key key}) : super(key: key);
//   Future<bool> setCookies() async {
//     return await MethodChannel('plugins.flutter.io/cookie_manager')
//         .invokeMethod<bool>(
//       'setCookies',
//       <String, dynamic>{
//         'url': rule.loginUrl,
//         'cookies': rule.cookies.split(RegExp(r';\s*')),
//       },
//     );
//   }
//   Future<String> getCookies() async {
//     print('rule.loginUrl:${rule.loginUrl}');
//     return await MethodChannel('plugins.flutter.io/cookie_manager')
//         .invokeMethod<String>(
//       'getCookies',
//       <String, String>{
//         'url': rule.loginUrl,
//       },
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     final Completer<WebViewController> _controller =
//         Completer<WebViewController>();
//     if (rule.cookies != null && rule.cookies.isNotEmpty) {
//       print("设置cookie");
//       // WebViewController().
//       // setCookies();
//     }

//     return WillPopScope(
//       onWillPop: () async {
//         final controller = await _controller.future;

//         if (await controller.canGoBack()) {
//           controller.goBack();
//           return false;
//         } else {
//           Utils.toast("保存请按右上角\n取消请按左上角");
//           return false;
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: Icon(
//               Icons.close,
//               size: 28,
//             ),
//             onPressed: () async {
//               Navigator.of(context).pop();
//             },
//           ),
//           title: Text(
//             "登录 ${rule.name}",
//             overflow: TextOverflow.ellipsis,
//           ),
//           actions: [
//             IconButton(
//               icon: Icon(
//                 Icons.arrow_back_ios,
//                 size: 20,
//               ),
//               onPressed: () async {
//                 final controller = await _controller.future;
//                 if (await controller.canGoBack()) {
//                   controller.goBack();
//                 }
//               },
//             ),
//             IconButton(
//               icon: Icon(
//                 Icons.arrow_forward_ios,
//                 size: 20,
//               ),
//               onPressed: () async {
//                 final controller = await _controller.future;
//                 if (await controller.canGoForward()) {
//                   controller.goForward();
//                 }
//               },
//             ),
//             IconButton(
//               icon: Icon(
//                 FIcons.check,
//                 size: 28,
//               ),
//               onPressed: () async {
//                 final cookies = await getCookies();
//                 rule.cookies = cookies;
//                 print("rule.cookies:${rule.cookies}");
//                 Navigator.of(context).pop(cookies);
//               },
//             ),
//           ],
//         ),
//         body: InAppWebView(onWebViewCreated: (controller) {

//         },),
//         // body: WebView(
//         //   javascriptMode: JavascriptMode.unrestricted,
//         //   onWebViewCreated: (WebViewController webViewController) {
//         //     print("创建完毕");
//         //     _controller.complete(webViewController);
//         //   },
//         //   initialUrl: rule.loginUrl,
//         //   userAgent:
//         //       rule.userAgent.isNotEmpty ? rule.userAgent : Global.userAgent,
//         // ),

//       ),
//     );
//   }
// }

class LoginRulePageWithWindows extends StatefulWidget {
  final Rule rule;
  const LoginRulePageWithWindows({this.rule, Key key}) : super(key: key);

  @override
  State<LoginRulePageWithWindows> createState() =>
      _LoginRulePageWithWindowsState();
}

class _LoginRulePageWithWindowsState extends State<LoginRulePageWithWindows> {
  final _controller = WebviewController();
  String _loginUrl = "";
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _loginUrl = widget.rule.loginUrl;
    await _controller.initialize();
    await _controller.clearCache();
    await _controller.clearCookies();
    await _controller.setBackgroundColor(Colors.transparent);
    await _controller.setUserAgent(widget.rule.userAgent.isNotEmpty
        ? widget.rule.userAgent
        : Global.userAgent);
    print("loginUrl:${widget.rule.loginUrl}");
    await _controller.loadUrl(widget.rule.loginUrl);
    isInit = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("登陆"),
          leading: CupertinoButton(
            child: Text("完成"),
            padding: EdgeInsets.zero,
            onPressed: () async {
              String cookies = await _controller.getCookies(_loginUrl);
              print("cookies:${cookies}");

              // final cookies = await  controller.getCookies();
              widget.rule.cookies = cookies;
              print("rule.cookies:${widget.rule.cookies}");

              Navigator.of(context).pop(cookies);
            },
          ),
          trailing: StreamBuilder<LoadingState>(
            initialData: null,
            builder: (context, snapshot) {
              final loadingState = snapshot.data;
              final index = loadingState?.index ?? 0;

              print("name:${loadingState?.name},index:${loadingState?.index}");

              return index != 2
                  ? CupertinoActivityIndicator()
                  : GestureDetector(
                      onTap: () {
                        _controller.reload();
                        setState(() {});
                      },
                      child: Icon(CupertinoIcons.refresh_thin, size: 22),
                    );
            },
            stream: _controller.loadingState,
          ),
        ),
        child: Webview(_controller),
      ),
    );
  }
}
