import 'dart:io';
import 'package:eso/hive/theme_box.dart';
import 'package:eso/page/add_local_item_page.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/local_cupertion_delegate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:eso/page/first_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:uni_links/uni_links.dart';
// import 'package:video_player_win/video_player_win.dart';
import 'package:window_manager/window_manager.dart';
import 'eso_theme.dart';
import 'global.dart';
import 'hive/theme_mode_box.dart';
import 'model/audio_service_handler.dart';
import 'page/audio_page_refactor.dart';
import 'page/discover_page.dart';
import 'page/home_page.dart';
import 'package:hetu_script/hetu_script.dart';
import 'package:flutter/gestures.dart';

import 'ui/ui_add_rule_dialog.dart';
import 'utils/auto_decode_cli.dart';
import 'utils/rule_comparess.dart';

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
  var name = "本地文件";
  try {
    final _uri = Uri.parse(linkPath);
    final _path = Uri.decodeFull(_uri.path);
    final _file = File(_path);
    final _name = _path.substring(_path.lastIndexOf('/') + 1);
    name = _name;
    platformFile = PlatformFile(path: _path, name: _name, size: _file.lengthSync());
  } catch (e) {}
  if (platformFile == null) {
    return;
  }

  String fileContent = autoReadFile(platformFile.path).trim();
  if (platformFile.name.contains(".json") ||
      fileContent.startsWith(RuleCompress.tag) ||
      (fileContent.startsWith('[') && fileContent.endsWith(']')) ||
      (fileContent.startsWith('{') && fileContent.endsWith('}')) ||
      (fileContent.startsWith('"' + RuleCompress.tag) && fileContent.endsWith('"'))) {
    if (fileContent.startsWith(RuleCompress.tag)) {
      fileContent = RuleCompress.decompassString(fileContent);
    } else if (fileContent.startsWith('"' + RuleCompress.tag) &&
        fileContent.endsWith('"')) {
      fileContent =
          RuleCompress.decompassString(fileContent.substring(1, fileContent.length - 1));
    }
    showDialog(
      context: navigatorKey.currentState.context,
      builder: (context) => UIAddRuleDialog(
          refresh: () {
            editSourceProviderTemp?.refreshData();
          },
          fileContent: fileContent,
          fileName: name),
    );
  } else if (platformFile.name.contains(".txt") || platformFile.name.contains(".epub")) {
    Navigator.push(
        navigatorKey.currentState.context,
        MaterialPageRoute(
          builder: (context) => AddLocalItemPage(platformFile: platformFile),
        ));
  } else {
    Utils.toast("未知的文件类型");
  }
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void main() async {
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }
  WidgetsFlutterBinding.ensureInitialized();
  // if (!Platform.isWindows)
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.eso.channel.audio',
  //   androidNotificationChannelName: '亦搜音频',
  //   androidNotificationOngoing: true,
  //   androidNotificationIcon: 'mipmap/eso_logo',
  // );
  if (Platform.isAndroid || Platform.isIOS) {
    final linkPath = await getInitialLink();

    print("getInitialLink:${linkPath}");
    if (linkPath != null) {
      onLink(linkPath);
    }
    linkStream.listen(onLink);
  }

  await Hive.initFlutter("eso");
  await openThemeModeBox();
  runApp(const MyApp());

  // 必须加上这一行。
  if (Platform.isWindows) {
    // WindowsVideoPlayer.registerWith();
    // await windowManager.ensureInitialized();
    // initVideoPlayerMediaKitIfNeeded();
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
final hetu = Hetu();

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
        // 设置刷新率
        if (displayHighRate) {
          await FlutterDisplayMode.setHighRefreshRate();
        } else if (displayMode.refreshRate > 1) {
          await FlutterDisplayMode.setPreferredMode(displayMode);
        }
        await Global.init();
        await hetu.init(externalFunctions: {
          'hello': (entity, {positionalArgs, namedArgs, typeArgs}) {},
          'toast': (entity, {positionalArgs, namedArgs, typeArgs}) {
            Utils.toast("msg");
          },
        });
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
                      navigatorKey: navigatorKey,
                      themeMode: _themeMode,
                      theme: getGlobalThemeData(),
                      darkTheme: getGlobalDarkThemeData(),
                      scrollBehavior: MyCustomScrollBehavior(),
                      title: Global.appName,
                      home: ValueListenableBuilder<Box<dynamic>>(
                          valueListenable: globalConfigBox.listenable(),
                          builder: (BuildContext context, Box<dynamic> _, Widget child) {
                            return HomePage();
                          }),
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
