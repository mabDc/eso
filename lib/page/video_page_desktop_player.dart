// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';

// import 'package:webview_windows/webview_windows.dart';

// class ExampleBrowser extends StatefulWidget {
//   final WebviewController webcontroller;
//   ExampleBrowser({this.webcontroller, Key key}) : super(key: key);
//   @override
//   State<ExampleBrowser> createState() => _ExampleBrowser();
// }

// class _ExampleBrowser extends State<ExampleBrowser> {
//   @override
//   void dispose() {
//     widget.webcontroller.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   Future<void> initPlatformState() async {
//     try {
//       await widget.webcontroller.initialize();
//       if (!mounted) return;
//       setState(() {});
//     } on PlatformException catch (e) {
//       WidgetsBinding.instance?.addPostFrameCallback((_) {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   title: Text('Error'),
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Code: ${e.code}'),
//                       Text('Message: ${e.message}'),
//                     ],
//                   ),
//                   actions: [
//                     TextButton(
//                       child: Text('Continue'),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     )
//                   ],
//                 ));
//       });
//     }
//   }

//   Widget compositeView() {
//     if (!widget.webcontroller.value.isInitialized) {
//       return const Text(
//         'Not Initialized',
//         style: TextStyle(
//           fontSize: 24.0,
//           fontWeight: FontWeight.w900,
//         ),
//       );
//     } else {
//       return Center(
//         child: Webview(
//           widget.webcontroller,
//           height: 500,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return compositeView();
//   }
// }
