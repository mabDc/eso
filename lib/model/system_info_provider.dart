import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class SystemInfoProvider with ChangeNotifier {
  final _format = intl.DateFormat('HH:mm');
  Timer _timer;

  String _now;
  String get now => _now;

  int _level;
  int get level => _level;

  SystemInfoProvider() {
    _now = _format.format(DateTime.now());
    _level = 100;
    _init();
  }

  Future<bool> _init() async {
    _timer = Timer.periodic(Duration(milliseconds: 300), (_) async {
      _now = _format.format(DateTime.now());
      _level = await Battery().batteryLevel;
      notifyListeners();
    });
    return true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
