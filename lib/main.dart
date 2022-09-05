import 'dart:convert';
import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/model/audio_service_handler.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:eso/page/add_local_item_page.dart';
import 'package:eso/page/home_page_ios.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/auto_decode_cli.dart';
import 'package:eso/utils/local_cupertion_delegate.dart';
import 'package:eso/utils/rule_comparess.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:eso/page/first_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uni_links2/uni_links.dart';
import 'package:window_manager/window_manager.dart';
import 'global.dart';
import 'profile.dart';
import 'model/history_manager.dart';
// import 'page/home_page.dart';
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

Future<void> onLink(String linkPath) async {
  PlatformFile platformFile;
  if (Platform.isAndroid) {
    platformFile = await FilePicker.platform.getContentPath(linkPath);
  } else if (Platform.isIOS) {
    try {
      final _uri = Uri.parse(linkPath);
      final _path = Uri.decodeFull(_uri.path);
      final _file = File(_path);
      final _name = _path.substring(_path.lastIndexOf('/') + 1);
      platformFile =
          PlatformFile(path: _path, name: _name, size: _file.lengthSync());
    } catch (e) {}
  }
  if (platformFile == null) {
    return;
  }
  String fileContent = autoReadFile(platformFile.path).trim();
  if (platformFile.name.contains(".json") ||
      fileContent.startsWith(RuleCompress.tag)) {
    if (fileContent.startsWith(RuleCompress.tag)) {
      fileContent = RuleCompress.decompassString(fileContent);
    }
    final json = jsonDecode(fileContent);
    List<dynamic> _fileContent;
    if (json is Map) {
      _fileContent = [json];
    } else if (json is List) {
      _fileContent = json;
    }
    print("_fileContent:${_fileContent.length}");

    final okrules = _fileContent
        .map((rule) => Rule.fromJson(rule))
        .where((rule) => rule.name.isNotEmpty)
        .toList();

    final ids = await Global.ruleDao.insertOrUpdateRules(okrules);
    if (ids.length > 0) {
      Utils.toast("成功 ${okrules.length} 条规则");
    } else {
      Utils.toast("失败，未导入规则！");
    }
  } else if (platformFile.name.contains(".txt") ||
      platformFile.name.contains(".epub")) {
    Future.delayed(Duration(seconds: 0)).then((_) {
      Navigator.push(
          MyAudioService.audioHandler.navigatorKey.currentState.overlay.context,
          MaterialPageRoute(
            builder: (context) => AddLocalItemPage(platformFile: platformFile),
          ));
    });
  } else {
    Utils.toast("未知的文件类型");
  }
}

void main() async {
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  if (Platform.isWindows || Platform.isLinux) {
    //init dart vlc
    await DartVLC.initialize();
  }

  //if (Platform.isAndroid || Platform.isIOS) {
  MyAudioService.Init();
  //}

  runApp(MyApp());

  WidgetsFlutterBinding.ensureInitialized();
  //await getInitialUri();
  if (Platform.isAndroid || Platform.isIOS) {
    final linkPath = await getInitialLink();

    print("getInitialLink:${linkPath}");
    if (linkPath != null) {
      onLink(linkPath);
    }
    linkStream.listen(onLink);
  }

  var appDir = await getApplicationDocumentsDirectory();
  print("appDir" + appDir.path);
  await Hive.initFlutter("eso");
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
          return ErrorApp(
              error: snapshot.error, stackTrace: snapshot.stackTrace);
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
            ChangeNotifierProvider<EditSourceProvider>.value(
                value: EditSourceProvider())
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
                    debugShowCheckedModeBanner: false,
                    navigatorKey: Platform.isWindows
                        ? null
                        : MyAudioService.audioHandler?.navigatorKey,
                    scrollBehavior: MyCustomScrollBehavior(),
                    theme:
                        profile.getTheme(profile.fontFamily, isDarkMode: false),
                    darkTheme:
                        profile.getTheme(profile.fontFamily, isDarkMode: true),
                    title: Global.appName,
                    localizationsDelegates: [
                      LocalizationsCupertinoDelegate.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    locale: Locale('zh', 'CH'),
                    supportedLocales: [Locale('zh', 'CH')],
                    onGenerateRoute: (RouteSettings settings) {
                      if (settings.name == '/') {
                        return MaterialWithModalsPageRoute(
                            builder: (_) => HomePage());
                      }
                      return null;
                    },
                    initialRoute: '/',
                    // home: HomePage(),
                  ));
            },
          ),
        );
      },
    );
  }
}
