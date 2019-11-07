import 'dart:io';

import 'package:eso/page/first_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'global.dart';
import 'model/profile.dart';
import 'model/history_manager.dart';
import 'page/home_page.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Global.init(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            title: Global.appName,
            home: FirstPage(),
          );
        }
        return MultiProvider(
          providers: <SingleChildCloneableWidget>[
            ChangeNotifierProvider<Profile>.value(
              value: Profile(),
            ),
            Provider<HistoryManager>.value(
              value: HistoryManager(),
            ),
          ],
          child: Consumer<Profile>(
            builder: (BuildContext context, Profile profile, Widget widget) {
              return MaterialApp(
                theme: ThemeData(
                  primaryColor: Color(
                      Global.colors[profile.colorName] ?? profile.customColor),
                  brightness:
                      profile.darkMode ? Brightness.dark : Brightness.light,
                ),
                title: Global.appName,
                home: HomePage(),
              );
            },
          ),
        );
      },
    );
  }
}
