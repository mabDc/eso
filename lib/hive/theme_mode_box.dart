import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum InitFlag { wait, ok, error }

class ThemeModeBox {
  static const _name = "themeModeBox";

  static Future<Box<int>> open() => Hive.openBox<int>(_name);
  static final box = Hive.box<int>(_name);

  static const themeModeKey = "themeMode";
  static const initFlagKey = "initFlag";
  static final defaultValue = <String, int>{
    themeModeKey: ThemeMode.system.index,
    initFlagKey: InitFlag.wait.index,
  };
}