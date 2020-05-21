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
            'darkMode': "跟随系统",
            'colorName': Global.colors.keys.first,
            'customColor': Global.colors.values.first,
            'novelFontSize': 20.0,
            'novelHeight': 2.0,
            'novelBackgroundColor': 0xFFF5DEB3,
            'novelFontColor': Colors.black.value,
          }
        : jsonDecode(source);
    fromJson(json);
  }

  bool _switchLongPress;
  bool _switchFavoriteStyle;
  bool _switchDiscoverStyle;
  bool _autoRefresh;
  String _darkMode;
  String _colorName;
  int _customColor;
  bool _showMangaInfo;
  double _novelFontSize;
  double _novelHeight;
  int _novelBackgroundColor;
  int _novelFontColor;

  bool get switchLongPress => _switchLongPress;
  bool get switchFavoriteStyle => _switchFavoriteStyle;
  bool get switchDiscoverStyle => _switchDiscoverStyle;
  bool get autoRefresh => _autoRefresh;
  String get darkMode => _darkMode;
  String get colorName => _colorName;
  int get customColor => _customColor;
  bool get showMangaInfo => _showMangaInfo;
  double get novelFontSize => _novelFontSize;
  double get novelHeight => _novelHeight;
  int get novelBackgroundColor => _novelBackgroundColor;
  int get novelFontColor => _novelFontColor;

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

  set darkMode(String value) {
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

  set novelFontSize(double value) {
    if ((value - _novelFontSize).abs() > 0.1) {
      _novelFontSize = value;
      _saveProfile(false);
    }
  }

  set novelHeight(double value) {
    if ((value - _novelHeight).abs() > 0.1) {
      _novelHeight = value;
      _saveProfile(false);
    }
  }

  set novelBackgroundColor(int value) {
    if (value != _novelBackgroundColor) {
      _novelBackgroundColor = value;
      _saveProfile();
    }
  }

  set novelFontColor(int value) {
    if (value != _novelFontColor) {
      _novelFontColor = value;
      _saveProfile();
    }
  }

  void setnovelColor(int bgColor, int fontColor) {
    var change = false;
    if (bgColor != _novelBackgroundColor) {
      _novelBackgroundColor = bgColor;
    }
    if (fontColor != novelFontColor) {
      _novelFontColor = fontColor;
    }
    if (change) {
      _saveProfile(false);
    }
  }

  void _saveProfile([bool shouldNotifyListeners = true]) async {
    await Global.prefs.setString(Global.profileKey, jsonEncode(toJson()));
    if (shouldNotifyListeners) {
      notifyListeners();
    }
  }

  ThemeData getTheme({bool isDarkMode: false}) {
    switch (darkMode) {
      case "开启":
        isDarkMode = true;
        break;
      case "关闭":
        isDarkMode = false;
        break;
      default:
        break;
    }
    return ThemeData(
      primaryColor: Color(Global.colors[colorName] ?? customColor),
      bottomAppBarColor: isDarkMode
          ? Color.fromARGB(255, 66, 66, 66)
          : Color.fromARGB(255, 180, 188, 196),
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    );
  }

  Profile.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  void fromJson(Map<String, dynamic> json) {
    _switchLongPress = json['switchLongPress'];
    _switchFavoriteStyle = json['switchFavoriteStyle'] ?? false;
    _switchDiscoverStyle = json['switchDiscoverStyle'] ?? false;
    _showMangaInfo = json['showMangaInfo'] ?? true;
    _autoRefresh = json['autoRefresh'];
    _darkMode = json['darkMode'].toString();
    _colorName = json['colorName'];
    _customColor = json['customColor'];
    _novelFontSize = json['novelFontSize'] ?? 20.0;
    _novelHeight = json["novelHeight"] ?? 2.0;
    _novelBackgroundColor = json["novelBackgroundColor"] ?? 0xFFF5DEB3;
    _novelFontColor = json["novelFontColor"] ?? Colors.black.value;
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
        'novelFontSize': _novelFontSize,
        'novelHeight': _novelHeight,
        'novelBackgroundColor': _novelBackgroundColor,
        'novelFontColor': _novelFontColor,
      };
}
