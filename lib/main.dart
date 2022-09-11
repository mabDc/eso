import 'dart:io';
import 'package:eso/database/hive/chapter_item_adapter.dart';
import 'package:eso/database/hive/search_item_adapter.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/utils/local_cupertion_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:eso/page/first_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'global.dart';
import 'profile.dart';
import 'model/history_manager.dart';
import 'page/home_page.dart';
import 'utils/cache_util.dart';

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
  var appDir = await getApplicationDocumentsDirectory();
  print("appDir" + appDir.path);
  await Hive.initFlutter("eso");
  Hive.registerAdapter(ChapterItemAdapter());
  Hive.registerAdapter(SearchItemAdapter());
  await Hive.openBox<SearchItem>(Global.searchItemKey);
  runApp(MyApp());
  // Hive.registerAdapter(ChapterItemAdapter());
  // Hive.registerAdapter(SearchItemAdapter());
  // await Hive.openBox<SearchItem>(Global.searchItemKey);
  // 必须加上这一行。
  if (Platform.isWindows) {
    WidgetsFlutterBinding.ensureInitialized();
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
  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;
    return FutureBuilder<bool>(
      future: Global.init(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return ErrorApp(error: snapshot.error, stackTrace: snapshot.stackTrace);
        }
        if (!snapshot.hasData) {
          return MaterialApp(
            scrollBehavior: MyCustomScrollBehavior(),
            title: Global.appName,
            home: FirstPage(),
          );
        }
        (() async {
          final a = await CacheUtil.requestPermission();
          print(a);
        })();
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<Profile>.value(
              value: Profile(),
            ),
            Provider<HistoryManager>.value(
              value: HistoryManager(),
            ),
          ],
          child: Consumer<Profile>(
            builder: (BuildContext context, Profile profile, Widget widget) {
              return OKToast(
                  textStyle: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontFamily: profile.fontFamily,
                  ),
                  backgroundColor: Colors.black.withOpacity(0.8),
                  radius: 20.0,
                  textPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: MaterialApp(
                    scrollBehavior: MyCustomScrollBehavior(),
                    theme: profile.getTheme(profile.fontFamily, isDarkMode: false),
                    darkTheme: profile.getTheme(profile.fontFamily, isDarkMode: true),
                    title: Global.appName,
                    localizationsDelegates: [
                      LocalizationsCupertinoDelegate.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    locale: Locale('zh', 'CH'),
                    supportedLocales: [Locale('zh', 'CH')],
                    home: HomePage(),
                  ));
            },
          ),
        );
      },
    );
  }
}
