import 'dart:io';
import 'package:eso/utils/local_cupertion_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:eso/page/first_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:window_manager/window_manager.dart';
import 'global.dart';
import 'eso_theme.dart';
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
  await ThemeModeBox.open();
  runApp(MyApp());

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

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeModeBox.box.put(ThemeModeBox.initFlagKey, InitFlag.wait.index);
    StackTrace _stackTrace;
    dynamic _error;
    () async {
      try {
        await Global.init();
        ThemeModeBox.box.put(ThemeModeBox.initFlagKey, InitFlag.ok.index);
      } catch (e, st) {
        _error = e;
        _stackTrace = st;
        ThemeModeBox.box.put(ThemeModeBox.initFlagKey, InitFlag.error.index);
      }
    }();
    return ValueListenableBuilder<Box<int>>(
      valueListenable: ThemeModeBox.box.listenable(),
      builder: (BuildContext context, Box<int> box, Widget child) {
        final themeMode = ThemeMode.values[box.get(
          ThemeModeBox.themeModeKey,
          defaultValue: ThemeModeBox.defaultValue[ThemeModeBox.themeModeKey],
        )];
        switch (InitFlag.values[box.get(
          ThemeModeBox.initFlagKey,
          defaultValue: ThemeModeBox.defaultValue[ThemeModeBox.initFlagKey],
        )]) {
          case InitFlag.ok:
            return OKToast(
              textStyle: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                fontFamily: ESOTheme().fontFamily,
              ),
              backgroundColor: Colors.black.withOpacity(0.8),
              radius: 20.0,
              textPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: MaterialApp(
                themeMode: themeMode,
                darkTheme: ThemeData.dark(),
                scrollBehavior: MyCustomScrollBehavior(),
                title: Global.appName,
                home: HomePage(),
              ),
            );
          // return MultiProvider(
          //   providers: [
          //     // ChangeNotifierProvider<Profile>.value(
          //     //   value: Profile(),
          //     // ),
          //     // Provider<HistoryManager>.value(
          //     //   value: HistoryManager(),
          //     // ),
          //   ],
          //   child: Consumer<Profile>(
          //     builder: (BuildContext context, Profile profile, Widget widget) {
          //       return OKToast(
          //           textStyle: TextStyle(
          //             fontSize: 16.0,
          //             color: Colors.white,
          //             fontFamily: profile.fontFamily,
          //           ),
          //           backgroundColor: Colors.black.withOpacity(0.8),
          //           radius: 20.0,
          //           textPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          //           child: MaterialApp(
          //             scrollBehavior: MyCustomScrollBehavior(),
          //             theme: profile.getTheme(profile.fontFamily, isDarkMode: false),
          //             themeMode: ThemeMode.values[themeMode],
          //             darkTheme: profile.getTheme(profile.fontFamily, isDarkMode: true),
          //             title: Global.appName,
          //             localizationsDelegates: [
          //               LocalizationsCupertinoDelegate.delegate,
          //               GlobalMaterialLocalizations.delegate,
          //               GlobalWidgetsLocalizations.delegate,
          //             ],
          //             locale: Locale('zh', 'CH'),
          //             supportedLocales: [Locale('zh', 'CH')],
          //             home: HomePage(),
          //           ));
          //     },
          //   ),
          // );
          case InitFlag.error:
            return MaterialApp(
              themeMode: themeMode,
              darkTheme: ThemeData.dark(),
              scrollBehavior: MyCustomScrollBehavior(),
              title: Global.appName,
              home: ErrorApp(error: _error, stackTrace: _stackTrace),
            );
          default:
            return MaterialApp(
              themeMode: themeMode,
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
