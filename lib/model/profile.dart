import 'dart:convert';

import 'package:eso/database/search_item_manager.dart';
import 'package:flutter/material.dart';

import '../global.dart';

enum SearchOption { Normal, None, Accurate }

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
            'novelFontSize': 18.0,
            'novelHeight': 1.5,
            'novelTopPadding': 5.0,
            'novelLeftPadding': 15.0,
            'novelParagraphPadding': 20.0,
            'novelPageSwitch': novelScroll,
            'novelIndentation': 2,
            'novelBackgroundColor': 0xFFF5DEB3,
            'novelFontColor': Colors.black.value,
            'novelKeepOn': false,
            'novelSortIndex': SortType.CREATE.index,
            'mangaSortIndex': SortType.CREATE.index,
            'audioSortIndex': SortType.CREATE.index,
            'videoSortIndex': SortType.CREATE.index,
            'novelEnableSearch': true,
            'mangaEnableSearch': true,
            'audioEnableSearch': true,
            'videoEnableSearch': true,
            'mangaKeepOn': false,
            'mangaLandscape': false,
            'mangaDirection': mangaDirectionTopToBottom,
            'searchCount': 10,
            'searchOption': SearchOption.Normal.index,
          }
        : jsonDecode(source);
    fromJson(json);
  }

  static const mangaDirectionTopToBottom = 0; //'topToBottom';
  static const mangaDirectionLeftToRight = 1; //'leftToRight';
  static const mangaDirectionRightToLeft = 2; //'rightToLeft';

  static const novelScroll = 0;
  static const novelSlide = 1;
  static const novelCover = 2;
  static const novelSimulation = 3;
  static const novelNone = 4;
  static const novelVerticalSlide = 5;
  static const novelHorizontalSlide = 6;

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
  double _novelTopPadding;
  double _novelLeftPadding;
  double _novelParagraphPadding;
  int _novelPageSwitch;
  int _novelIndentation;
  int _novelBackgroundColor;
  int _novelFontColor;
  bool _novelKeepOn;
  bool _mangaKeepOn;
  bool _mangaLandscape;
  int _mangaDirection;
  int _novelSortIndex;
  int _mangaSortIndex;
  int _audioSortIndex;
  int _videoSortIndex;
  bool _novelEnableSearch;
  bool _mangaEnableSearch;
  bool _audioEnableSearch;
  bool _videoEnableSearch;
  int _searchCount;
  int _searchOption;

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
  double get novelTopPadding => _novelTopPadding;
  double get novelLeftPadding => _novelLeftPadding;
  double get novelParagraphPadding => _novelParagraphPadding;
  int get novelPageSwitch => _novelPageSwitch;
  int get novelIndentation => _novelIndentation;
  int get novelBackgroundColor => _novelBackgroundColor;
  int get novelFontColor => _novelFontColor;
  bool get novelKeepOn => _novelKeepOn;
  bool get mangaKeepOn => _mangaKeepOn;
  bool get mangaLandscape => _mangaLandscape;
  int get mangaDirection => _mangaDirection;
  int get novelSortIndex => _novelSortIndex;
  int get mangaSortIndex => _mangaSortIndex;
  int get audioSortIndex => _audioSortIndex;
  int get videoSortIndex => _videoSortIndex;
  bool get novelEnableSearch => _novelEnableSearch;
  bool get mangaEnableSearch => _mangaEnableSearch;
  bool get audioEnableSearch => _audioEnableSearch;
  bool get videoEnableSearch => _videoEnableSearch;
  int get searchCount => _searchCount;
  int get searchOption => _searchOption;

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
      if (value > 40) {
        _novelFontSize = 40;
      } else if (value < 10) {
        _novelFontSize = 10;
      } else {
        _novelFontSize = value;
      }
      _saveProfile();
    }
  }

  set novelHeight(double value) {
    if ((value - _novelHeight).abs() > 0.05) {
      if (value > 3) {
        _novelHeight = 3;
      } else if (value < 1) {
        _novelHeight = 1;
      } else {
        _novelHeight = value;
      }
      _saveProfile();
    }
  }

  set novelTopPadding(double value) {
    if ((value - _novelTopPadding).abs() > 0.1) {
      if (value > 50) {
        _novelTopPadding = 50;
      } else if (value < 5) {
        _novelTopPadding = 5;
      } else {
        _novelTopPadding = value;
      }
      _saveProfile();
    }
  }

  set novelLeftPadding(double value) {
    if ((value - _novelLeftPadding).abs() > 0.1) {
      if (value > 50) {
        _novelLeftPadding = 50;
      } else if (value < 5) {
        _novelLeftPadding = 5;
      } else {
        _novelLeftPadding = value;
      }
      _saveProfile();
    }
  }

  set novelParagraphPadding(double value) {
    if ((value - _novelParagraphPadding).abs() > 0.1) {
      if (_novelParagraphPadding > 50) {
        _novelParagraphPadding = 50;
      } else if (value < 0) {
        _novelParagraphPadding = 0;
      } else {
        _novelParagraphPadding = value;
      }
      _saveProfile();
    }
  }

  set novelPageSwitch(int value) {
    if (value != _novelPageSwitch) {
      _novelPageSwitch = value;
      _saveProfile();
    }
  }

  set novelIndentation(int value) {
    if (value != _novelIndentation) {
      if (value > 4) {
        _novelIndentation = 4;
      } else if (value < 0) {
        _novelIndentation = 0;
      } else {
        _novelIndentation = value;
      }
      _saveProfile();
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

  void setNovelColor(int bgColor, int fontColor) {
    var change = false;
    if (bgColor != _novelBackgroundColor) {
      _novelBackgroundColor = bgColor;
      change = true;
    }
    if (fontColor != novelFontColor) {
      _novelFontColor = fontColor;
      change = true;
    }
    if (change) {
      _saveProfile();
    }
  }

  set novelKeepOn(bool value) {
    if (value != _novelKeepOn) {
      _novelKeepOn = value;
      _saveProfile();
    }
  }

  set mangaKeepOn(bool value) {
    if (value != _mangaKeepOn) {
      _mangaKeepOn = value;
      _saveProfile();
    }
  }

  set mangaLandscape(bool value) {
    if (value != _mangaLandscape) {
      _mangaLandscape = value;
      _saveProfile(false);
    }
  }

  set mangaDirection(int value) {
    if (value != _mangaDirection) {
      _mangaDirection = value;
      _saveProfile();
    }
  }

  void _saveProfile([bool shouldNotifyListeners = true]) async {
    await Global.prefs.setString(Global.profileKey, jsonEncode(toJson()));
    if (shouldNotifyListeners) {
      notifyListeners();
    }
  }

  set novelSortIndex(int value) {
    if (value != _novelSortIndex) {
      _novelSortIndex = value;
      _saveProfile(false);
    }
  }

  set mangaSortIndex(int value) {
    if (value != _mangaSortIndex) {
      _mangaSortIndex = value;
      _saveProfile(false);
    }
  }

  set audioSortIndex(int value) {
    if (value != _audioSortIndex) {
      _audioSortIndex = value;
      _saveProfile(false);
    }
  }

  set videoSortIndex(int value) {
    if (value != _videoSortIndex) {
      _videoSortIndex = value;
      _saveProfile(false);
    }
  }

  set novelEnableSearch(bool value) {
    if (value != _novelEnableSearch) {
      _novelEnableSearch = value;
      _saveProfile(false);
    }
  }

  set mangaEnableSearch(bool value) {
    if (value != _mangaEnableSearch) {
      _mangaEnableSearch = value;
      _saveProfile(false);
    }
  }

  set audioEnableSearch(bool value) {
    if (value != _audioEnableSearch) {
      _audioEnableSearch = value;
      _saveProfile(false);
    }
  }

  set videoEnableSearch(bool value) {
    if (value != _videoEnableSearch) {
      _videoEnableSearch = value;
      _saveProfile(false);
    }
  }

  set searchCount(int value) {
    if (value != _searchCount) {
      _searchCount = value;
      _saveProfile(false);
    }
  }

  set searchOption(int value) {
    if (value != _searchOption) {
      _searchOption = value;
      _saveProfile(false);
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
    final theme = ThemeData(
      primaryColor: Color(Global.colors[colorName] ?? customColor),
      bottomAppBarColor: isDarkMode
          ? Color.fromARGB(255, 66, 66, 66)
          : Color.fromARGB(255, 180, 188, 196),
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    );
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        color: theme.canvasColor,
        elevation: 2,
        brightness: theme.brightness,
        iconTheme: IconThemeData(
          color: theme.textTheme.bodyText1.color.withOpacity(0.7),
        ),
        actionsIconTheme: IconThemeData(
          color: theme.textTheme.bodyText1.color.withOpacity(0.7),
        ),
      ),
      primaryTextTheme: TextTheme(
        headline6: TextStyle(color: theme.textTheme.bodyText1.color.withOpacity(0.8)),
      ),
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
    _novelFontSize = json['novelFontSize'] ?? 18.0;
    _novelHeight = json["novelHeight"] ?? 1.5;
    _novelBackgroundColor = json["novelBackgroundColor"] ?? 0xFFF5DEB3;
    _novelFontColor = json["novelFontColor"] ?? Colors.black.value;
    _novelTopPadding = json["novelTopPadding"] ?? 5.0;
    _novelLeftPadding = json["novelLeftPadding"] ?? 15.0;
    _novelParagraphPadding = json["novelParagraphPadding"] ?? 20.0;
    _novelPageSwitch = json["novelPageSwitch"] ?? novelScroll;
    _novelIndentation = json["novelIndentation"] ?? 2;
    _novelKeepOn = json["novelKeepOn"] ?? false;
    _mangaKeepOn = json["mangaKeepOn"] ?? false;
    _mangaLandscape = json["mangaLandscape"] ?? false;
    _mangaDirection = json['mangaDirection'] ?? mangaDirectionTopToBottom;
    _novelSortIndex = json["novelSortIndex"] ?? SortType.CREATE.index;
    _mangaSortIndex = json["mangaSortIndex"] ?? SortType.CREATE.index;
    _audioSortIndex = json["audioSortIndex"] ?? SortType.CREATE.index;
    _videoSortIndex = json["videoSortIndex"] ?? SortType.CREATE.index;
    _searchCount = json["searchCount"] ?? 10;
    _searchOption = json["searchOption"] ?? SearchOption.Normal.index;
    _novelEnableSearch = json['novelEnableSearch'] ?? true;
    _mangaEnableSearch = json['mangaEnableSearch'] ?? true;
    _audioEnableSearch = json['audioEnableSearch'] ?? true;
    _videoEnableSearch = json['videoEnableSearch'] ?? true;
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
        'novelKeepOn': _novelKeepOn,
        'mangaKeepOn': _mangaKeepOn,
        'mangaLandscape': _mangaLandscape,
        'mangaDirection': _mangaDirection,
        'novelSortIndex': _novelSortIndex,
        'mangaSortIndex': _mangaSortIndex,
        'audioSortIndex': _audioSortIndex,
        'videoSortIndex': _videoSortIndex,
        'searchCount': _searchCount,
        'searchOption': _searchOption,
        'novelEnableSearch': _novelEnableSearch,
        'mangaEnableSearch': _mangaEnableSearch,
        'audioEnableSearch': _audioEnableSearch,
        'videoEnableSearch': _videoEnableSearch,
        'novelTopPadding': _novelTopPadding,
        'novelLeftPadding': _novelLeftPadding,
        'novelParagraphPadding': _novelParagraphPadding,
        'novelPageSwitch': _novelPageSwitch,
        'novelIndentation': _novelIndentation,
      };
}
