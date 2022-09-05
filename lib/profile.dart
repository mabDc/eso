import 'dart:convert';
import 'package:eso/database/search_item_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:pull_down_button/pull_down_button.dart';

import 'global.dart';

enum SearchOption { Normal, None, Accurate }

class Profile with ChangeNotifier {
  restore(String profile) {
    if (profile == null || profile.isEmpty) return;
    fromJson(jsonDecode(profile));
    notifyListeners();
  }

  static final Profile _profile = Profile._internal();
  factory Profile() => _profile;

  Profile._internal() {
    print('***************  initProfile   **************');
    final source = Global.prefs.getString(Global.profileKey);
    fromJson(source == null ? {} : jsonDecode(source) ?? {});
  }

  static const mangaDirectionTopToBottom = 0; //'topToBottom';
  static const mangaDirectionLeftToRight = 1; //'leftToRight';
  static const mangaDirectionRightToLeft = 2; //'rightToLeft';

  static const dartModeAuto = '跟随系统';
  static const dartModeDark = '开启';
  static const dartModeLight = '关闭';

  static const autoBackupNone = 0;
  static const autoBackupDay = 1;

  static const searchDocker = 0;
  static const searchFloat = 1;
  static const searchAction = 2;

  Profile.newProfile() {
    _desktopPlayer = "";
    _desktopPlayerParseUrl = "https://jx.parwix.com:4433/player/?url=";
    _version = '';
    _fontFamily = null;
    _switchLongPress = false;
    _showHistoryOnAbout = true;
    _showHistoryOnFavorite = true;
    _switchFavoriteStyle = false;
    _showMangaStatus = false;
    _showMangaInfo = true;
    _searchPostion = searchDocker;
    _bottomCount = 2;
    _autoRefresh = false;
    _darkMode = dartModeAuto;
    _primaryColor = CupertinoColors.systemBlue.value;
    _scaffoldBackgroundColor = CupertinoColors.systemGroupedBackground.value;
    _barBackgroundColor = CupertinoDynamicColor.withBrightness(
      // color: Colors.white,
      color: Color(0xF0F9F9F9),
      darkColor: Color(0xF01D1D1D),
    ).value;
    _primaryTextColor = CupertinoColors.black.value;

    _mangaKeepOn = false;
    _mangaLandscape = false;
    _mangaDirection = mangaDirectionTopToBottom;
    _mangaQuality = 1;
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
    _autoBackRate = autoBackupDay;
    _autoBackupLastDay = "";
    _enableWebdav = false;
    _webdavServer = "https://dav.jianguoyun.com/dav/";
    _webdavAccount = "";
    _webdavPassword = "";
    _enableWebdavRule = false;
    _webdavRuleAccount = "";
    _webdavRuleCheckcode = "";
    _autoRuleUploadLastDay = "";
    _ruleGroupFilter = "";
    _favoriteGroup = '';
    _currentGroup = '';
    _listMode = 0;
    _listAspectRatio = 1.0;
  }

  double _listAspectRatio = 1.0;
  double get listAspectRatio => _listAspectRatio;
  set listAspectRatio(double value) {
    if (value != _listAspectRatio) {
      if (value == null || value <= 0.0) {
        return;
      }
      if (value > 2.0) {
        value = 1.0;
      }
      _listAspectRatio = value;
      _saveProfile();
    }
  }

  int _listMode = 0;
  int get listMode => _listMode;
  set listMode(int value) {
    if (value != _listMode) {
      _listMode = value;
      _saveProfile();
    }
  }

  String _currentGroup = '';
  String get currentGroup => _currentGroup;

  set currentGroup(String value) {
    if (value != _currentGroup) {
      _currentGroup = value;
      _saveProfile();
    }
  }

  String _favoriteGroup = '';
  String get favoriteGroup => _favoriteGroup;
  set favoriteGroup(String value) {
    if (value != _favoriteGroup) {
      _favoriteGroup = value;
      _saveProfile();
    }
  }

  String _ruleGroupFilter;
  String get ruleGroupFilter => _ruleGroupFilter;
  set ruleGroupFilter(String value) {
    if (value != _ruleGroupFilter) {
      _ruleGroupFilter = value;
      _saveProfile();
    }
  }

  String _desktopPlayer;
  String get desktopPlayer => _desktopPlayer;
  set desktopPlayer(String value) {
    if (value != _desktopPlayer) {
      _desktopPlayer = value;
      _saveProfile();
    }
  }

  String _desktopPlayerParseUrl;
  String get desktopPlayerParseUrl => _desktopPlayerParseUrl;

  set desktopPlayerParseUrl(String value) {
    if (value != _desktopPlayerParseUrl) {
      _desktopPlayerParseUrl = value;
      _saveProfile();
    }
  }

  bool _enableWebdavRule;
  bool get enableWebdavRule => _enableWebdavRule;
  set enableWebdavRule(bool value) {
    if (value != _enableWebdavRule) {
      _enableWebdavRule = value;
      _saveProfile();
    }
  }

  String _webdavRuleAccount;
  String get webdavRuleAccount => _webdavRuleAccount;
  set webdavRuleAccount(String value) {
    if (value != _webdavRuleAccount) {
      _webdavRuleAccount = value;
      _saveProfile();
    }
  }

  String _webdavRuleCheckcode;
  String get webdavRuleCheckcode => _webdavRuleCheckcode;
  set webdavRuleCheckcode(String value) {
    if (value != _webdavRuleCheckcode) {
      _webdavRuleCheckcode = value;
      _saveProfile();
    }
  }

  String _autoRuleUploadLastDay;
  String get autoRuleUploadLastDay => _autoRuleUploadLastDay;
  set autoRuleUploadLastDay(String value) {
    if (value != _autoRuleUploadLastDay) {
      _autoRuleUploadLastDay = value;
      _saveProfile();
    }
  }

  String _webdavAccount;
  String get webdavAccount => _webdavAccount;
  set webdavAccount(String value) {
    if (value != _webdavAccount) {
      _webdavAccount = value;
      _saveProfile();
    }
  }

  String _webdavPassword;
  String get webdavPassword => _webdavPassword;
  set webdavPassword(String value) {
    if (value != _webdavPassword) {
      _webdavPassword = value;
      _saveProfile();
    }
  }

  String _webdavServer;
  String get webdavServer => _webdavServer;
  set webdavServer(String value) {
    if (value != _webdavServer) {
      _webdavServer = value;
      _saveProfile();
    }
  }

  bool _enableWebdav;
  bool get enableWebdav => _enableWebdav;
  set enableWebdav(bool value) {
    if (value != _enableWebdav) {
      _enableWebdav = value;
      _saveProfile();
    }
  }

  String _autoBackupLastDay;
  String get autoBackupLastDay => _autoBackupLastDay;
  set autoBackupLastDay(String value) {
    if (value != _autoBackupLastDay) {
      _autoBackupLastDay = value;
      _saveProfile();
    }
  }

  int _autoBackRate;
  int get autoBackRate => _autoBackRate;
  set autoBackRate(int value) {
    if (value != _autoBackRate) {
      _autoBackRate = value;
      _saveProfile();
    }
  }

  String _version;
  String _fontFamily;
  bool _switchLongPress;
  bool _showHistoryOnAbout;
  bool _showHistoryOnFavorite;
  bool _switchFavoriteStyle;
  bool _autoRefresh;
  String _darkMode;
  int _primaryColor;
  bool _showMangaStatus;
  bool _showMangaInfo;
  int _searchPostion;
  int _bottomCount;
  bool _mangaKeepOn;
  bool _mangaLandscape;
  int _mangaQuality;
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
  bool get switchLongPress => _switchLongPress;
  bool get showHistoryOnAbout => _showHistoryOnAbout;
  bool get showHistoryOnFavorite => _showHistoryOnFavorite;
  bool get switchFavoriteStyle => _switchFavoriteStyle;
  bool get autoRefresh => _autoRefresh;
  String get darkMode => _darkMode;
  int get primaryColor => _primaryColor;
  bool get showMangaStatus => _showMangaStatus;
  bool get showMangaInfo => _showMangaInfo;
  int get searchPostion => _searchPostion;
  int get bottomCount => _bottomCount;
  bool get mangaKeepOn => _mangaKeepOn;
  bool get mangaLandscape => _mangaLandscape;
  int get mangaQuality => _mangaQuality;

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

  set showHistoryOnAbout(bool value) {
    if (value != _showHistoryOnAbout) {
      _showHistoryOnAbout = value;
      _saveProfile();
    }
  }

  set showHistoryOnFavorite(bool value) {
    if (value != _showHistoryOnFavorite) {
      _showHistoryOnFavorite = value;
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

  set showMangaStatus(bool value) {
    if (_showMangaStatus != value) {
      _showMangaStatus = value;
      _saveProfile();
    }
  }

  set showMangaInfo(bool value) {
    if (_showMangaInfo != value) {
      _showMangaInfo = value;
      _saveProfile(false);
    }
  }

  set searchPostion(int value) {
    if (_searchPostion != value) {
      _searchPostion = value;
      _saveProfile();
    }
  }

  set bottomCount(int value) {
    if (_bottomCount != value) {
      _bottomCount = value;
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

  set mangaQuality(int value) {
    if (value != _mangaQuality) {
      _mangaQuality = value;
      _saveProfile(false);
    }
  }

  set mangaDirection(int value) {
    if (value != _mangaDirection) {
      _mangaDirection = value;
      _saveProfile(false);
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

  int _scaffoldBackgroundColor;
  int get scaffoldBackgroundColor => _scaffoldBackgroundColor;
  set scaffoldBackgroundColor(int value) {
    if (_scaffoldBackgroundColor != value) {
      _scaffoldBackgroundColor = value;
      _saveProfile();
    }
  }

  int _barBackgroundColor;
  int get barBackgroundColor => _barBackgroundColor;
  set barBackgroundColor(int value) {
    if (_barBackgroundColor != value) {
      _barBackgroundColor = value;
      _saveProfile();
    }
  }

  int _primaryTextColor;
  int get primaryTextColor => _primaryTextColor;
  set primaryTextColor(int value) {
    if (_primaryTextColor != value) {
      _primaryTextColor = value;
      _saveProfile();
    }
  }

  Color kHeaderFooterColor = CupertinoDynamicColor(
    color: Color.fromRGBO(108, 108, 108, 1.0),
    darkColor: Color.fromRGBO(142, 142, 146, 1.0),
    highContrastColor: Color.fromRGBO(74, 74, 77, 1.0),
    darkHighContrastColor: Color.fromRGBO(176, 176, 183, 1.0),
    elevatedColor: Color.fromRGBO(108, 108, 108, 1.0),
    darkElevatedColor: Color.fromRGBO(142, 142, 146, 1.0),
    highContrastElevatedColor: Color.fromRGBO(108, 108, 108, 1.0),
    darkHighContrastElevatedColor: Color.fromRGBO(142, 142, 146, 1.0),
  );

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

    final _color = Color(_primaryColor | 0xFF000000);
    final fontColor = _primaryTextColor == null
        ? CupertinoColors.label
        : CupertinoDynamicColor.withBrightness(
            color: Color(_primaryTextColor),
            darkColor: CupertinoColors.label.darkColor);

    Global.primaryColor = _color;
    staticFontFamily = fontFamily;
    final _txtStyle =
        TextStyle(fontFamily: _fontFamily).copyWith(color: fontColor);

    var theme = ThemeData(
      // extensions: [
      //   PullDownButtonTheme(
      //     // iconSize: 24,
      //     checkmarkSize: 18,
      //   )
      // ],
      platform: TargetPlatform.iOS,
      fontFamily: staticFontFamily,
      primaryColor: _color,
      primaryColorDark: Global.colorLight(_color, -0.25),
      primaryColorLight: Global.colorLight(_color, 0.25),
      toggleableActiveColor: _color,
      dividerColor: isDarkMode ? Colors.white10 : Colors.black12,
      bottomAppBarColor: isDarkMode ? Color(0xF01D1D1D) : Color(0xF0F9F9F9),
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: _color,
        primaryContrastingColor: _color,
        scaffoldBackgroundColor: isDarkMode
            ? CupertinoColors.systemGroupedBackground
            : Color(_scaffoldBackgroundColor ??
                CupertinoColors.systemGroupedBackground.value),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            inherit: false,
            fontFamily: _fontFamily,
            fontSize: 17.0,
            letterSpacing: -0.41,
            color: fontColor,
            decoration: TextDecoration.none,
          ),
          navTitleTextStyle: TextStyle(
            inherit: false,
            fontFamily: _fontFamily,
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
            color: CupertinoColors.label,
          ),
          tabLabelTextStyle: TextStyle(
            inherit: false,
            fontFamily: _fontFamily,
            fontSize: 10.0,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.24,
            color: CupertinoColors.inactiveGray,
          ),
        ),
        barBackgroundColor: isDarkMode
            ? Color(0xF01D1D1D)
            : Color(
                _barBackgroundColor ??
                    CupertinoDynamicColor.withBrightness(
                      // color: Colors.white,
                      color: Color(0xF0F9F9F9),
                      darkColor: Color(0xF01D1D1D),
                    ).value,
              ),
      ),
    );

    if (fontColor != null) {
      theme = theme.copyWith(
        textTheme: theme.textTheme.apply(
            bodyColor: isDarkMode ? Colors.white : fontColor,
            displayColor: fontColor.withOpacity(fontColor.opacity * 0.75)),
      );
    }

    return theme.copyWith(
      tabBarTheme: TabBarTheme(
        labelStyle: _txtStyle,
        unselectedLabelStyle: _txtStyle,
      ),
      listTileTheme: ListTileThemeData(
        textColor: isDarkMode
            ? CupertinoColors.secondaryLabel.darkColor
            : CupertinoColors.secondaryLabel.color,

        // iconColor:
      ),
      appBarTheme: AppBarTheme(
        color: theme.canvasColor,
        elevation: Global.elevation,
        foregroundColor: isDarkMode ? Color(0xffb4bcc4) : Color(0xff424242),
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

    _desktopPlayer = cast(json['desktopPlayer'], defaultProfile.desktopPlayer);
    _desktopPlayerParseUrl = cast(
        json['desktopPlayerParseUrl'], defaultProfile.desktopPlayerParseUrl);
    if (notIgnoreVersion) {
      _version = cast(json['version'], defaultProfile.version);
    }
    _webdavRuleCheckcode =
        cast(json['webdavRuleCheckcode'], defaultProfile.webdavRuleCheckcode);
    _webdavRuleAccount =
        cast(json['webdavRuleAccount'], defaultProfile.webdavRuleAccount);
    _enableWebdavRule =
        cast(json['enableWebdavRule'], defaultProfile.enableWebdavRule);
    _autoRuleUploadLastDay = cast(
        json['autoRuleUploadLastDay'], defaultProfile.autoRuleUploadLastDay);
    _webdavPassword =
        cast(json['webdavPassword'], defaultProfile.webdavPassword);
    _webdavAccount = cast(json['webdavAccount'], defaultProfile.webdavAccount);
    _autoBackupLastDay =
        cast(json['autoBackupLastDay'], defaultProfile.autoBackupLastDay);
    _autoBackRate = cast(json['autoBackRate'], defaultProfile.autoBackRate);
    _enableWebdav = cast(json['enableWebdav'], defaultProfile.enableWebdav);
    _webdavServer = cast(json['webdavServer'], defaultProfile.webdavServer);
    _fontFamily = cast(json['fontFamily'], defaultProfile.fontFamily);
    _switchLongPress =
        cast(json['switchLongPress'], defaultProfile.switchLongPress);
    _showHistoryOnAbout =
        cast(json['showHistoryOnAbout'], defaultProfile.showHistoryOnAbout);
    _showHistoryOnFavorite = cast(
        json['showHistoryOnFavorite'], defaultProfile.showHistoryOnFavorite);
    _switchFavoriteStyle =
        cast(json['switchFavoriteStyle'], defaultProfile.switchFavoriteStyle);
    _showMangaStatus =
        cast(json['showMangaStatus'], defaultProfile.showMangaStatus);
    _showMangaInfo = cast(json['showMangaInfo'], defaultProfile.showMangaInfo);
    _searchPostion = cast(json['searchPostion'], defaultProfile.searchPostion);
    _bottomCount = cast(json['bottomCount'], defaultProfile.bottomCount);
    _darkMode = cast(json['darkMode'], defaultProfile.darkMode);
    _primaryColor = cast(json['primaryColor'], defaultProfile.primaryColor);
    _scaffoldBackgroundColor = cast(json['scaffoldBackgroundColor'],
        defaultProfile.scaffoldBackgroundColor);
    _barBackgroundColor =
        cast(json['barBackgroundColor'], defaultProfile.barBackgroundColor);
    _primaryTextColor =
        cast(json['primaryTextColor'], defaultProfile.primaryTextColor);

    _mangaKeepOn = cast(json["mangaKeepOn"], defaultProfile.mangaKeepOn);
    _mangaLandscape =
        cast(json["mangaLandscape"], defaultProfile.mangaLandscape);
    _mangaQuality = cast(json["mangaQuality"], defaultProfile.mangaQuality);

    _mangaDirection =
        cast(json['mangaDirection'], defaultProfile.mangaDirection);
    _novelSortIndex =
        cast(json["novelSortIndex"], defaultProfile.novelSortIndex);
    _mangaSortIndex =
        cast(json["mangaSortIndex"], defaultProfile.mangaSortIndex);
    _audioSortIndex =
        cast(json["audioSortIndex"], defaultProfile.audioSortIndex);
    _videoSortIndex =
        cast(json["videoSortIndex"], defaultProfile.videoSortIndex);
    _searchCount = cast(json["searchCount"], defaultProfile.searchCount);
    _searchOption = cast(json["searchOption"], defaultProfile.searchOption);
    _novelEnableSearch =
        cast(json['novelEnableSearch'], defaultProfile.novelEnableSearch);
    _mangaEnableSearch =
        cast(json['mangaEnableSearch'], defaultProfile.mangaEnableSearch);
    _audioEnableSearch =
        cast(json['audioEnableSearch'], defaultProfile.audioEnableSearch);
    _videoEnableSearch =
        cast(json['videoEnableSearch'], defaultProfile.videoEnableSearch);

    _ruleGroupFilter =
        cast(json['ruleGroupFilter'], defaultProfile.ruleGroupFilter);
    _favoriteGroup = cast(json['favoriteGroup'], defaultProfile.favoriteGroup);
    _currentGroup = cast(json['currentGroup'], defaultProfile.currentGroup);
  }

  Map<String, dynamic> toJson() => {
        'desktopPlayer': _desktopPlayer,
        'desktopPlayerParseUrl': _desktopPlayerParseUrl,
        'webdavRuleAccount': _webdavRuleAccount,
        'webdavRuleCheckcode': _webdavRuleCheckcode,
        'enableWebdavRule': _enableWebdavRule,
        'autoRuleUploadLastDay': _autoRuleUploadLastDay,
        'webdavAccount': _webdavAccount,
        'webdavPassword': _webdavPassword,
        'autoBackupLastDay': _autoBackupLastDay,
        'enableWebdav': _enableWebdav,
        'autoBackRate': _autoBackRate,
        'webdavServer': _webdavServer,
        'fontFamily': _fontFamily,
        'version': _version,
        'switchLongPress': _switchLongPress,
        'showHistoryOnAbout': _showHistoryOnAbout,
        'showHistoryOnFavorite': _showHistoryOnFavorite,
        'switchFavoriteStyle': _switchFavoriteStyle,
        // 'switchDiscoverStyle': _switchDiscoverStyle,
        'showMangaStatus': _showMangaStatus,
        'showMangaInfo': _showMangaInfo,
        'searchPostion': _searchPostion,
        'bottomCount': _bottomCount,
        'autoRefresh': _autoRefresh,
        'darkMode': _darkMode,
        'primaryColor': _primaryColor,
        'primaryTextColor': _primaryTextColor,
        'barBackgroundColor': _barBackgroundColor,
        'scaffoldBackgroundColor': _scaffoldBackgroundColor,
        'mangaKeepOn': _mangaKeepOn,
        'mangaLandscape': _mangaLandscape,
        'mangaQuality': _mangaQuality,
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
        'ruleGroupFilter': _ruleGroupFilter,
        'favoriteGroup': _favoriteGroup,
        'currentGroup': _currentGroup,
      };
}

T cast<T>(x, T defaultValue) => x is T ? x : defaultValue; // 安全转换
