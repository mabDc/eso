import 'dart:convert';

import 'package:flutter/material.dart';

import '../global.dart';

class Profile with ChangeNotifier {
  Profile() {
    final source = Global.prefs.getString(Global.profileKey);
    final json = source == null
        ? {
            'showMangaInfo': true,
            'switchLongPress': false,
            'switchFavoriteStyle': false,
            'switchDiscoverStyle': false,
            'autoRefresh': false,
            'darkMode': false,
            'colorName': Global.colors.keys.first,
            'customColor': Global.colors.values.first,
          }
        : jsonDecode(source);
    fromJson(json);
  }

  bool _switchLongPress;
  bool _switchFavoriteStyle;
  bool _switchDiscoverStyle;
  bool _autoRefresh;
  bool _darkMode;
  String _colorName;
  int _customColor;
  bool _showMangaInfo;

  bool get switchLongPress => _switchLongPress;
  bool get switchFavoriteStyle => _switchFavoriteStyle;
  bool get switchDiscoverStyle => _switchDiscoverStyle;
  bool get autoRefresh => _autoRefresh;
  bool get darkMode => _darkMode;
  String get colorName => _colorName;
  int get customColor => _customColor;
  bool get showMangaInfo => _showMangaInfo;

  set switchFavoriteStyle(bool value) {
    if (value != _switchFavoriteStyle) {
      _switchFavoriteStyle = value;
      _saveProfile();
    }
  }

  set switchDiscoverStyle(bool value) {
    if (value != _switchDiscoverStyle) {
      _switchDiscoverStyle = value;
      _saveProfile();
    }
  }

  set switchLongPress(bool value) {
    if (value != _switchLongPress) {
      _switchLongPress = value;
      _saveProfile();
    }
  }

  set autoRefresh(bool value) {
    if (value != _autoRefresh) {
      _autoRefresh = value;
      _saveProfile();
    }
  }

  set darkMode(bool value) {
    if (value != _darkMode) {
      _darkMode = value;
      _saveProfile();
    }
  }

  set colorName(String value) {
    if (value != _colorName) {
      _colorName = value;
      _saveProfile();
    }
  }

  set customColor(int value) {
    if (value != _customColor) {
      _customColor = value;
      _saveProfile();
    }
  }

  set customColorRed(int value) {
    final color = Color(_customColor);
    if (value != color.red) {
      _customColor = color.withRed(value).value;
      _saveProfile();
    }
  }

  set customColorGreen(int value) {
    final color = Color(_customColor);
    if (value != color.green) {
      _customColor = color.withGreen(value).value;
      _saveProfile();
    }
  }

  set customColorBlue(int value) {
    final color = Color(_customColor);
    if (value != color.blue) {
      _customColor = color.withBlue(value).value;
      _saveProfile();
    }
  }

  set showMangaInfo(bool value) {
    if (_showMangaInfo != value) {
      _showMangaInfo = value;
      _saveProfile();
    }
  }

  void _saveProfile([bool shouldNotifyListeners = true]) async {
    await Global.prefs.setString(Global.profileKey, jsonEncode(toJson()));
    if (shouldNotifyListeners) {
      notifyListeners();
    }
  }

  Profile.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  fromJson(Map<String, dynamic> json) {
    _switchLongPress = json['switchLongPress'];
    _switchFavoriteStyle = json['switchFavoriteStyle'] ?? false;
    _switchDiscoverStyle = json['switchDiscoverStyle'] ?? false;
    _showMangaInfo = json['showMangaInfo'] ?? true;
    _autoRefresh = json['autoRefresh'];
    _darkMode = json['darkMode'];
    _colorName = json['colorName'];
    _customColor = json['customColor'];
  }

  Map<String, dynamic> toJson() => {
        'switchLongPress': _switchLongPress,
        'switchFavoriteStyle': _switchFavoriteStyle,
        'switchDiscoverStyle': _switchDiscoverStyle,
        'showMangaInfo': _showMangaInfo,
        'autoRefresh': _autoRefresh,
        'darkMode': _darkMode,
        'colorName': _colorName,
        'customColor': _customColor,
      };
}
