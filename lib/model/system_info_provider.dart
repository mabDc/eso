import 'dart:async';
import 'dart:io';

import 'package:battery/battery.dart';
import 'package:device_info/device_info.dart';
import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class SystemInfoProvider with ChangeNotifier {
  final _format = intl.DateFormat('HH:mm');
  Timer _timer;
  bool _isVirtualMachine;

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
    _isVirtualMachine = false;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      if (!androidInfo.isPhysicalDevice) {
        _isVirtualMachine = true;
      }
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      if (!iosInfo.isPhysicalDevice) {
        _isVirtualMachine = true;
      }
    } else if (Platform.isMacOS) {
      _isVirtualMachine = true;
    }
    _timer = Timer.periodic(Duration(milliseconds: 300), (_) async {
      _now = _format.format(DateTime.now());
      if (!_isVirtualMachine) {
        _level = Utils.isDesktop ? 100 : await Battery().batteryLevel;
      }
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
