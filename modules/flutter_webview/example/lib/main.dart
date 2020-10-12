// /*
//  * @Description: example
//  * @Author: ekibun
//  * @Date: 2020-08-08 08:16:51
//  * @LastEditors: ekibun
//  * @LastEditTime: 2020-08-26 21:18:45
//  */
// import 'dart:async';

// import 'package:flutter/material.dart';

// import 'package:flutter_qjs/flutter_qjs.dart';
// import 'package:flutter_webview/flutter_webview.dart';

// import 'highlight.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'flutter_qjs',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         appBarTheme: AppBarTheme(brightness: Brightness.dark, elevation: 0),
//         backgroundColor: Colors.grey[300],
//         primaryColorBrightness: Brightness.dark,
//       ),
//       routes: {
//         'home': (BuildContext context) => TestPage(),
//       },
//       initialRoute: 'home',
//     );
//   }
// }

// class TestPage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _TestPageState();
// }

// Future<dynamic> webview(String url, Map options) async {
//   Completer c = new Completer();
//   var webview = FlutterWebview();
//   await webview.setMethodHandler((String method, dynamic args) async {
//     print("$method($args)");
//     if (method == "onNavigationCompleted") {
//       await Future.delayed(Duration(seconds: 10));
//       if (!c.isCompleted) c.completeError("Webview Call timeout 10 seconds after page completed.");
//     }
//     var callback = options[method];
//     if (callback != null) if ((await callback([args])) == true) {
//       print(args);
//       if (!c.isCompleted) c.complete(args);
//     }
//     return;
//   });
//   if (options["ua"] != null) await webview.setUserAgent(options["ua"]);
//   await webview.navigate(url);
//   Future.delayed(Duration(seconds: 100)).then((value) {
//     if (!c.isCompleted) c.completeError("Webview Call timeout 100 seconds.");
//   });
//   try {
//     return await c.future;
//   } finally {
//     await webview.destroy();
//   }
// }

// class _TestPageState extends State<TestPage> {
//   String resp;
//   FlutterJs engine;

//   CodeInputController _controller =
//       CodeInputController(text: """dart("webview", "https://www.acfun.cn/bangumi/aa6001745", {
//   ua: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36",
//   onRequest: ({url})=>{
//     if(url.includes("m3u8")) return true;
//     return false;
//   }
// })""");

//   _createEngine() async {
//     if (engine != null) return;
//     engine = FlutterJs();
//     await engine.setMethodHandler((String method, List arg) async {
//       switch (method) {
//         case "webview":
//           return await webview(arg[0], arg[1]);
//         case "print":
//           return print(arg);
//         default:
//           return JsMethodHandlerNotImplement();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("JS engine test"),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   FlatButton(child: Text("create engine"), onPressed: _createEngine),
//                   FlatButton(
//                       child: Text("evaluate"),
//                       onPressed: () async {
//                         if (engine == null) {
//                           print("please create engine first");
//                           return;
//                         }
//                         try {
//                           resp = (await engine.evaluate(_controller.text ?? '', "<eval>")).toString();
//                         } catch (e) {
//                           resp = e.toString();
//                         }
//                         setState(() {});
//                       }),
//                   FlatButton(
//                       child: Text("close engine"),
//                       onPressed: () async {
//                         if (engine == null) return;
//                         await engine.destroy();
//                         engine = null;
//                       }),
//                 ],
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.all(12),
//               color: Colors.grey.withOpacity(0.1),
//               constraints: BoxConstraints(minHeight: 200),
//               child: TextField(
//                 autofocus: true,
//                 controller: _controller,
//                 decoration: null,
//                 maxLines: null,
//               ),
//             ),
//             SizedBox(height: 16),
//             Text("result:"),
//             SizedBox(height: 16),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               color: Colors.green.withOpacity(0.05),
//               constraints: BoxConstraints(minHeight: 100),
//               child: SelectableText(resp ?? ''),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
