import 'dart:convert';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global.dart';

enum SearchOption { Normal, None, Accurate }

class Profile with ChangeNotifier {
  static final Profile _profile = Profile._internal();
  factory Profile() => _profile;

  Profile._internal() {
    print('***************  initProfile   **************');
    final source = Global.prefs.getString(Global.profileKey);
    fromJson(source == null ? {} : jsonDecode(source) ?? {});
  }

  static restore(Map<String, dynamic> profile) {
    _profile.fromJson(profile, false);
    _profile.notifyListeners();
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
  static const novelFade = 7;

  static const dartModeAuto = '跟随系统';
  static const dartModeDark = '开启';
  static const dartModeLight = '关闭';

  Profile.newProfile() {
    _version = '';
    _fontFamily = null;
    _novelFontFamily = null;
    _switchLongPress = false;
    _switchFavoriteStyle = false;
    _showMangaInfo = true;
    _mangaFullScreen = true;
    _autoRefresh = false;
    _darkMode = dartModeAuto;
    _primaryColor = 0xFF4BB0A0;
    _novelFontSize = 18.0;
    _novelHeight = 1.5;
    _novelBackgroundColor = 0xFFF5DEB3;
    _novelFontColor = Colors.black.value;
    _novelTopPadding = 5.0;
    _novelLeftPadding = 15.0;
    _novelParagraphPadding = 15.0;
    _novelPageSwitch = novelScroll;
    _novelIndentation = 2;
    _novelKeepOn = false;
    _mangaKeepOn = false;
    _mangaLandscape = false;
    _mangaDirection = mangaDirectionTopToBottom;
    _novelSortIndex = SortType.CREATE.index;
    _mangaSortIndex = SortType.CREATE.index;
    _audioSortIndex = SortType.CREATE.index;
    _videoSortIndex = SortType.CREATE.index;
    _searchCount = 10;
    _searchOption = SearchOption.Normal.index;
    _novelEnableSearch = true;
    _mangaEnableSearch = true;
    _audioEnableSearch = true;
    _videoEnableSearch = true;
  }

  String _version;
  String _fontFamily;
  String _novelFontFamily;
  bool _switchLongPress;
  bool _switchFavoriteStyle;
  bool _autoRefresh;
  String _darkMode;
  int _primaryColor;
  bool _showMangaInfo;
  bool _mangaFullScreen;
  double _novelFontSize;
  double _novelHeight;
  double _novelTopPadding;
  double _novelLeftPadding;
  double _novelParagraphPadding;
  int _novelPageSwitch;
  int _novelIndentation;
  int _novelBackgroundColor;
  String _novelBackgroundImage;
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

  String get version => _version;
  String get fontFamily => _fontFamily;
  String get novelFontFamily => _novelFontFamily;
  bool get switchLongPress => _switchLongPress;
  bool get switchFavoriteStyle => _switchFavoriteStyle;
  bool get autoRefresh => _autoRefresh;
  String get darkMode => _darkMode;
  int get primaryColor => _primaryColor;
  bool get showMangaInfo => _showMangaInfo;
  bool get mangaFullScreen => _mangaFullScreen;
  double get novelFontSize => _novelFontSize;
  double get novelHeight => _novelHeight;
  double get novelTopPadding => _novelTopPadding;
  double get novelLeftPadding => _novelLeftPadding;
  double get novelParagraphPadding => _novelParagraphPadding;
  int get novelPageSwitch => _novelPageSwitch;
  int get novelIndentation => _novelIndentation;
  int get novelBackgroundColor => _novelBackgroundColor;
  String get novelBackgroundImage => _novelBackgroundImage;
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

  String get lastestVersion => '${Global.appVersion}+${Global.appBuildNumber}';

  void updateVersion() {
    version = lastestVersion;
  }

  set version(String value) {
    final version = value;
    if (_version != version) {
      _version = version;
      _saveProfile(false);
    }
  }

  set fontFamily(String value) {
    if (value != _fontFamily) {
      _fontFamily = value;
      staticFontFamily = value;
      _saveProfile();
    }
  }

  set novelFontFamily(String value) {
    if (value != _novelFontFamily) {
      _novelFontFamily = value;
      staticNovelFontFamily = value;
      _saveProfile();
    }
  }

  set switchFavoriteStyle(bool value) {
    if (value != _switchFavoriteStyle) {
      _switchFavoriteStyle = value;
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

  set primaryColor(int value) {
    if (value != _primaryColor) {
      _primaryColor = value;
      _saveProfile();
    }
  }

  set mangaFullScreen(bool value) {
    if (_mangaFullScreen != value) {
      _mangaFullScreen = value;
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
      _novelBackgroundImage = null;
      _saveProfile();
    }
  }

  set novelBackgroundImage(String value) {
    if (value != _novelBackgroundImage) {
      _novelBackgroundImage = value;
      _saveProfile();
    }
  }

  set novelFontColor(int value) {
    if (value != _novelFontColor) {
      _novelFontColor = value;
      _saveProfile();
    }
  }

  void setNovelColor(Color bgColor, Color fontColor) {
    var change = false;
    if (_novelBackgroundImage != null) {
      _novelBackgroundImage = null;
      change = true;
    }
    if (bgColor.value != _novelBackgroundColor) {
      _novelBackgroundColor = bgColor.value;
      change = true;
    }
    if (fontColor.value != novelFontColor) {
      _novelFontColor = fontColor.value;
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

  static String staticFontFamily;
  static String staticNovelFontFamily;

  ThemeData getTheme(String fontFamily, {bool isDarkMode: false}) {
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
    final _color = Color(_primaryColor);
    staticFontFamily = fontFamily;
    final theme = ThemeData(
      fontFamily: staticFontFamily,
      primaryColor: _color,
      primaryColorDark: Global.colorLight(_color, -0.25),
      primaryColorLight: Global.colorLight(_color, 0.25),
      toggleableActiveColor: _color,
      dividerColor: isDarkMode ? Colors.white10 : Colors.black12,
      bottomAppBarColor: isDarkMode ? Color(0xff424242) : Color(0xffb4bcc4),
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
    );
    final _txtStyle = TextStyle(fontFamily: _fontFamily);
    return theme.copyWith(
      tabBarTheme: TabBarTheme(
        labelStyle: _txtStyle,
        unselectedLabelStyle: _txtStyle,
      ),
      appBarTheme: AppBarTheme(
        color: theme.canvasColor,
        elevation: Global.elevation,
        brightness: theme.brightness,
        iconTheme: IconThemeData(
          color: theme.textTheme.bodyText1.color.withOpacity(0.7),
          size: 19,
        ),
        actionsIconTheme: IconThemeData(
          color: theme.textTheme.bodyText1.color.withOpacity(0.7),
          size: 19,
        ),
      ),
      cardTheme: CardTheme(
        elevation: Global.elevation,
      ),
      primaryTextTheme: TextTheme(
        headline6: TextStyle(
            color: theme.textTheme.bodyText1.color.withOpacity(0.8),
            fontFamily: _fontFamily),
      ),
      
    );
  }

  void fromJson(Map<String, dynamic> json, [bool notIgnoreVersion = true]) {
    final defaultProfile = Profile.newProfile();
    if (notIgnoreVersion) {
      _version = json['version'] ?? defaultProfile.version;
    }
    _fontFamily = json['fontFamily'] ?? defaultProfile.fontFamily;
    _novelFontFamily = json['novelFontFamily'] ?? defaultProfile.novelFontFamily;
    _switchLongPress = json['switchLongPress'] ?? defaultProfile.switchLongPress;
    _switchFavoriteStyle =
        json['switchFavoriteStyle'] ?? defaultProfile.switchFavoriteStyle;
    _showMangaInfo = json['showMangaInfo'] ?? defaultProfile.showMangaInfo;
    _mangaFullScreen = json['mangaFullScreen'] ?? defaultProfile.mangaFullScreen;
    _autoRefresh = json['autoRefresh'] ?? defaultProfile.autoRefresh;
    _darkMode = json['darkMode'] ?? defaultProfile.darkMode;
    _primaryColor = json['primaryColor'] ?? defaultProfile.primaryColor;
    _novelFontSize = json['novelFontSize'] ?? defaultProfile.novelFontSize;
    _novelHeight = json["novelHeight"] ?? defaultProfile.novelHeight;
    _novelBackgroundColor =
        json["novelBackgroundColor"] ?? defaultProfile.novelBackgroundColor;
    _novelBackgroundImage =
        json["novelBackgroundImage"] ?? defaultProfile.novelBackgroundImage;
    _novelFontColor = json["novelFontColor"] ?? defaultProfile.novelFontColor;
    _novelTopPadding = json["novelTopPadding"] ?? defaultProfile.novelTopPadding;
    _novelLeftPadding = json["novelLeftPadding"] ?? defaultProfile.novelLeftPadding;
    _novelParagraphPadding =
        json["novelParagraphPadding"] ?? defaultProfile.novelParagraphPadding;
    _novelPageSwitch = json["novelPageSwitch"] ?? defaultProfile.novelPageSwitch;
    _novelIndentation = json["novelIndentation"] ?? defaultProfile.novelIndentation;
    _novelKeepOn = json["novelKeepOn"] ?? defaultProfile.novelKeepOn;
    _mangaKeepOn = json["mangaKeepOn"] ?? defaultProfile.mangaKeepOn;
    _mangaLandscape = json["mangaLandscape"] ?? defaultProfile.mangaLandscape;
    _mangaDirection = json['mangaDirection'] ?? defaultProfile.mangaDirection;
    _novelSortIndex = json["novelSortIndex"] ?? defaultProfile.novelSortIndex;
    _mangaSortIndex = json["mangaSortIndex"] ?? defaultProfile.mangaSortIndex;
    _audioSortIndex = json["audioSortIndex"] ?? defaultProfile.audioSortIndex;
    _videoSortIndex = json["videoSortIndex"] ?? defaultProfile.videoSortIndex;
    _searchCount = json["searchCount"] ?? defaultProfile.searchCount;
    _searchOption = json["searchOption"] ?? defaultProfile.searchOption;
    _novelEnableSearch = json['novelEnableSearch'] ?? defaultProfile.novelEnableSearch;
    _mangaEnableSearch = json['mangaEnableSearch'] ?? defaultProfile.mangaEnableSearch;
    _audioEnableSearch = json['audioEnableSearch'] ?? defaultProfile.audioEnableSearch;
    _videoEnableSearch = json['videoEnableSearch'] ?? defaultProfile.videoEnableSearch;
  }

  Map<String, dynamic> toJson() => {
        'fontFamily': _fontFamily,
        'novelFontFamily': _novelFontFamily,
        'version': _version,
        'switchLongPress': _switchLongPress,
        'switchFavoriteStyle': _switchFavoriteStyle,
        // 'switchDiscoverStyle': _switchDiscoverStyle,
        'showMangaInfo': _showMangaInfo,
        'mangaFullScreen': _mangaFullScreen,
        'autoRefresh': _autoRefresh,
        'darkMode': _darkMode,
        'primaryColor': _primaryColor,
        'novelFontSize': _novelFontSize,
        'novelHeight': _novelHeight,
        'novelBackgroundColor': _novelBackgroundColor,
        'novelBackgroundImage': _novelBackgroundImage,
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
