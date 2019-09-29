import 'dart:convert';
import 'package:flutter/material.dart';
import '../global.dart';

class Profile with ChangeNotifier {
  Profile() {
    final source = Global.prefs.getString(Global.profileKey);
    final json = source == null
        ? {
            'autoRefresh': false,
            'darkMode': false,
            'colorName': Global.colors.keys.first,
          }
        : jsonDecode(source);
    fromJson(json);
  }

  bool _autoRefresh;
  bool _darkMode;
  String _colorName;

  bool get autoRefresh => _autoRefresh;
  bool get darkMode => _darkMode;
  String get colorName => _colorName;

  set autoRefresh(bool value) {
    if (value != autoRefresh) {
      _autoRefresh = value;
      _saveProfile();
    }
  }

  set darkMode(bool value) {
    if (value != darkMode) {
      _darkMode = value;
      _saveProfile();
    }
  }

  set colorName(String value) {
    if (value != colorName) {
      _colorName = value;
      _saveProfile();
    }
  }

  void _saveProfile([bool sholdNotifyListeners = true]) async {
    await Global.prefs.setString(Global.profileKey, jsonEncode(toJson()));
    if (sholdNotifyListeners) {
      notifyListeners();
    }
  }

  Profile.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  fromJson(Map<String, dynamic> json) {
    _autoRefresh = json['autoRefresh'];
    _darkMode = json['darkMode'];
    _colorName = json['colorName'];
  }

  Map<String, dynamic> toJson() => {
        'autoRefresh': _autoRefresh,
        'darkMode': _darkMode,
        'colorName': _colorName,
      };
}
