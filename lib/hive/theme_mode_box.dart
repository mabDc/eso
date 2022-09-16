import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum InitFlag { wait, ok, error }

const _name = "themeModeBox";
Future<Box<int>> openThemeModeBox() => Hive.openBox<int>(_name);
final themeModeBox = Hive.box<int>(_name);

const _themeMode = "themeMode";
int get themeMode => themeModeBox.get(_themeMode, defaultValue: ThemeMode.system.index);
set themeMode(int val){
  if(null != val && val != themeMode) themeModeBox.put(_themeMode, val);
}

// const _initFlag = "initFlag";
// int get initFlag => themeModeBox.get(_initFlag, defaultValue: InitFlag.wait.index);
// set initFlag(int val){
//   if(null != val && val != initFlag) themeModeBox.put(_initFlag, val);
// }