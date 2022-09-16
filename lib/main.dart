import 'dart:io';
import 'package:eso/hive/theme_box.dart';
import 'package:eso/utils/local_cupertion_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:eso/page/first_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';
import 'global.dart';
import 'hive/theme_mode_box.dart';
import 'page/home_page.dart';

import 'package:flutter/gestures.dart';

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

void main() async {
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter("eso");
  await openThemeModeBox();
  runApp(const MyApp());

  // 必须加上这一行。
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
  }
  // if (Platform.isWindows) {
  //   final server = await HttpMultiServer.loopback(51532);
  //   final html = await rootBundle.loadString("player.html", cache: false);
  //   shelf_io.serveRequests(server, (request) {
  //     return shelf.Response.ok(
  //       html,
  //       headers: {"content-type": "text/html;charset=utf-8"},
  //     );
  //   });
  // }
}

class ErrorApp extends StatelessWidget {
  final error;
  final stackTrace;
  const ErrorApp({Key key, this.error, this.stackTrace}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      home: Scaffold(
        body: ListView(
          children: [
            Text(
              "$error\n$stackTrace",
              style: TextStyle(color: Color(0xFFF56C6C)),
            )
          ],
        ),
      ),
    );
  }
}

BoxDecoration globalDecoration;

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StackTrace _stackTrace;
  dynamic _error;
  InitFlag initFlag = InitFlag.wait;

  @override
  void initState() {
    super.initState();
    () async {
      try {
        await openThemeBox();
        await Global.init();
        globalDecoration = BoxDecoration(
          image:
              DecorationImage(image: AssetImage(decorationImage), fit: BoxFit.fitWidth),
        );
        themeBox.listenable(keys: [decorationImageKey]).addListener(() {
          globalDecoration = BoxDecoration(
            image:
                DecorationImage(image: AssetImage(decorationImage), fit: BoxFit.fitWidth),
          );
        });
        initFlag = InitFlag.ok;
        setState(() {});
      } catch (e, st) {
        _error = e;
        _stackTrace = st;
        initFlag = InitFlag.error;
        setState(() {});
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<int>>(
      valueListenable: themeModeBox.listenable(),
      builder: (BuildContext context, Box<int> _, Widget child) {
        final _themeMode = ThemeMode.values[themeMode];
        switch (initFlag) {
          case InitFlag.ok:
            return OKToast(
              textStyle: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
              backgroundColor: Colors.black.withOpacity(0.8),
              radius: 20.0,
              textPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: ValueListenableBuilder<Box>(
                  valueListenable: themeBox.listenable(),
                  builder: (BuildContext context, Box _, Widget child) {
                    return MaterialApp(
                      themeMode: _themeMode,
                      theme: getGlobalThemeData(),
                      darkTheme: getGlobalDarkThemeData(),
                      scrollBehavior: MyCustomScrollBehavior(),
                      title: Global.appName,
                      home: HomePage(),
                      localizationsDelegates: [
                        LocalizationsCupertinoDelegate.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                      ],
                      locale: Locale('zh', 'CH'),
                      supportedLocales: [Locale('zh', 'CH')],
                    );
                  }),
            );
          case InitFlag.error:
            return MaterialApp(
              themeMode: _themeMode,
              darkTheme: ThemeData.dark(),
              scrollBehavior: MyCustomScrollBehavior(),
              title: Global.appName,
              home: ErrorApp(error: _error, stackTrace: _stackTrace),
            );
          default:
            return MaterialApp(
              themeMode: _themeMode,
              darkTheme: ThemeData.dark(),
              scrollBehavior: MyCustomScrollBehavior(),
              title: Global.appName,
              home: FirstPage(),
            );
        }
      },
    );
  }
}
