import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import 'global.dart';

enum SearchOption { Normal, None, Accurate }

final _box = Hive.box(Global.profileKey);
final globalConfigBox = _box;

const desktopPlayerBox = "desktopPlayerBox";
const versionBox = "versionBox";
const fontFamilyBox = "fontFamilyBox";
const switchLongPressBox = "switchLongPressBox";
const showHistoryOnAboutBox = "showHistoryOnAboutBox";
const showHistoryOnFavoriteBox = "showHistoryOnFavoriteBox";
const switchFavoriteStyleBox = "switchFavoriteStyleBox";
const showMangaStatusBox = "showMangaStatusBox";
const showMangaInfoBox = "showMangaInfoBox";
const searchPostionBox = "searchPostionBox";
const bottomCountBox = "bottomCountBox";
const autoRefreshBox = "autoRefreshBox";
const primaryColorBox = "primaryColorBox";
const mangaKeepOnBox = "mangaKeepOnBox";
const mangaLandscapeBox = "mangaLandscapeBox";
const mangaDirectionBox = "mangaDirectionBox";
const novelSortIndexBox = "novelSortIndexBox";
const mangaSortIndexBox = "mangaSortIndexBox";
const audioSortIndexBox = "audioSortIndexBox";
const videoSortIndexBox = "videoSortIndexBox";
const searchCountBox = "searchCountBox";
const searchOptionBox = "searchOptionBox";
const novelEnableSearchBox = "novelEnableSearchBox";
const mangaEnableSearchBox = "mangaEnableSearchBox";
const audioEnableSearchBox = "audioEnableSearchBox";
const videoEnableSearchBox = "videoEnableSearchBox";
const autoBackRateBox = "autoBackRateBox";
const autoBackupLastDayBox = "autoBackupLastDayBox";
const enableWebdavBox = "enableWebdavBox";
const webdavServerBox = "webdavServerBox";
const webdavAccountBox = "webdavAccountBox";
const webdavPasswordBox = "webdavPasswordBox";
const enableWebdavRuleBox = "enableWebdavRuleBox";
const webdavRuleAccountBox = "webdavRuleAccountBox";
const webdavRuleCheckcodeBox = "webdavRuleCheckcodeBox";
const autoRuleUploadLastDayBox = "autoRuleUploadLastDayBox";

const thDef = {
  desktopPlayerBox: '',
  versionBox: '',
  fontFamilyBox: '',
  switchLongPressBox: false,
  showHistoryOnAboutBox: true,
  showHistoryOnFavoriteBox: true,
  switchFavoriteStyleBox: false,
  showMangaStatusBox: false,
  showMangaInfoBox: true,
  searchPostionBox: ESOTheme.searchDocker,
  bottomCountBox: 2,
  autoRefreshBox: false,
  primaryColorBox: 0xFF4BB0A0,
  mangaKeepOnBox: false,
  mangaLandscapeBox: false,
  mangaDirectionBox: ESOTheme.mangaDirectionTopToBottom,
  novelSortIndexBox: 0,
  mangaSortIndexBox: 0,
  audioSortIndexBox: 0,
  videoSortIndexBox: 0,
  searchCountBox: 10,
  searchOptionBox: 0,
  novelEnableSearchBox: true,
  mangaEnableSearchBox: true,
  audioEnableSearchBox: true,
  videoEnableSearchBox: true,
  autoBackRateBox: ESOTheme.autoBackupDay,
  autoBackupLastDayBox: "",
  enableWebdavBox: false,
  webdavServerBox: "https://dav.jianguoyun.com/dav/",
  webdavAccountBox: "",
  webdavPasswordBox: "",
  enableWebdavRuleBox: false,
  webdavRuleAccountBox: "",
  webdavRuleCheckcodeBox: "",
  autoRuleUploadLastDayBox: "",
};

class ESOTheme {
  restore(String profile) {
    if (profile == null || profile.isEmpty) return;
    fromJson(jsonDecode(profile));
  }

  static String backUpESOTheme() {
    return jsonEncode(_box.toMap());
  }

  static final ESOTheme _profile = ESOTheme._internal();
  factory ESOTheme() => _profile;

  ESOTheme._internal();

  static const mangaDirectionTopToBottom = 0; //'topToBottom';
  static const mangaDirectionLeftToRight = 1; //'leftToRight';
  static const mangaDirectionRightToLeft = 2; //'rightToLeft';

  static const autoBackupNone = 0;
  static const autoBackupDay = 1;

  static const searchDocker = 0;
  static const searchFloat = 1;
  static const searchAction = 2;

  String get desktopPlayer =>
      _box.get(desktopPlayerBox, defaultValue: thDef[desktopPlayerBox]);
  set desktopPlayer(String value) {
    if (value != desktopPlayer) {
      _box.put(desktopPlayerBox, cast(value, thDef[desktopPlayerBox]));
    }
  }

  String get version => _box.get(versionBox, defaultValue: thDef[versionBox]);
  set version(String value) {
    if (value != version) {
      _box.put(versionBox, cast(value, thDef[versionBox]));
    }
  }

  String get fontFamily => _box.get(fontFamilyBox, defaultValue: thDef[fontFamilyBox]);
  set fontFamily(String value) {
    if (value != fontFamily) {
      _box.put(fontFamilyBox, cast(value, thDef[fontFamilyBox]));
    }
  }

  bool get switchLongPress =>
      _box.get(switchLongPressBox, defaultValue: thDef[switchLongPressBox]);
  set switchLongPress(bool value) {
    if (value != switchLongPress) {
      _box.put(switchLongPressBox, cast(value, thDef[switchLongPressBox]));
    }
  }

  bool get showHistoryOnAbout =>
      _box.get(showHistoryOnAboutBox, defaultValue: thDef[showHistoryOnAboutBox]);
  set showHistoryOnAbout(bool value) {
    if (value != showHistoryOnAbout) {
      _box.put(showHistoryOnAboutBox, cast(value, thDef[showHistoryOnAboutBox]));
    }
  }

  bool get showHistoryOnFavorite =>
      _box.get(showHistoryOnFavoriteBox, defaultValue: thDef[showHistoryOnFavoriteBox]);
  set showHistoryOnFavorite(bool value) {
    if (value != showHistoryOnFavorite) {
      _box.put(showHistoryOnFavoriteBox, cast(value, thDef[showHistoryOnFavoriteBox]));
    }
  }

  bool get switchFavoriteStyle =>
      _box.get(switchFavoriteStyleBox, defaultValue: thDef[switchFavoriteStyleBox]);
  set switchFavoriteStyle(bool value) {
    if (value != switchFavoriteStyle) {
      _box.put(switchFavoriteStyleBox, cast(value, thDef[switchFavoriteStyleBox]));
    }
  }

  bool get showMangaStatus =>
      _box.get(showMangaStatusBox, defaultValue: thDef[showMangaStatusBox]);
  set showMangaStatus(bool value) {
    if (value != showMangaStatus) {
      _box.put(showMangaStatusBox, cast(value, thDef[showMangaStatusBox]));
    }
  }

  bool get showMangaInfo =>
      _box.get(showMangaInfoBox, defaultValue: thDef[showMangaInfoBox]);
  set showMangaInfo(bool value) {
    if (value != showMangaInfo) {
      _box.put(showMangaInfoBox, cast(value, thDef[showMangaInfoBox]));
    }
  }

  int get searchPostion =>
      _box.get(searchPostionBox, defaultValue: thDef[searchPostionBox]);
  set searchPostion(int value) {
    if (value != searchPostion) {
      _box.put(searchPostionBox, cast(value, thDef[searchPostionBox]));
    }
  }

  int get bottomCount => _box.get(bottomCountBox, defaultValue: thDef[bottomCountBox]);
  set bottomCount(int value) {
    if (value != bottomCount) {
      _box.put(bottomCountBox, cast(value, thDef[bottomCountBox]));
    }
  }

  bool get autoRefresh => _box.get(autoRefreshBox, defaultValue: thDef[autoRefreshBox]);
  set autoRefresh(bool value) {
    if (value != autoRefresh) {
      _box.put(autoRefreshBox, cast(value, thDef[autoRefreshBox]));
    }
  }

  bool get mangaKeepOn => _box.get(mangaKeepOnBox, defaultValue: thDef[mangaKeepOnBox]);
  set mangaKeepOn(bool value) {
    if (value != mangaKeepOn) {
      _box.put(mangaKeepOnBox, cast(value, thDef[mangaKeepOnBox]));
    }
  }

  bool get mangaLandscape =>
      _box.get(mangaLandscapeBox, defaultValue: thDef[mangaLandscapeBox]);
  set mangaLandscape(bool value) {
    if (value != mangaLandscape) {
      _box.put(mangaLandscapeBox, cast(value, thDef[mangaLandscapeBox]));
    }
  }

  int get mangaDirection =>
      _box.get(mangaDirectionBox, defaultValue: thDef[mangaDirectionBox]);
  set mangaDirection(int value) {
    if (value != mangaDirection) {
      _box.put(mangaDirectionBox, cast(value, thDef[mangaDirectionBox]));
    }
  }

  int get novelSortIndex =>
      _box.get(novelSortIndexBox, defaultValue: thDef[novelSortIndexBox]);
  set novelSortIndex(int value) {
    if (value != novelSortIndex) {
      _box.put(novelSortIndexBox, cast(value, thDef[novelSortIndexBox]));
    }
  }

  int get mangaSortIndex =>
      _box.get(mangaSortIndexBox, defaultValue: thDef[mangaSortIndexBox]);
  set mangaSortIndex(int value) {
    if (value != mangaSortIndex) {
      _box.put(mangaSortIndexBox, cast(value, thDef[mangaSortIndexBox]));
    }
  }

  int get audioSortIndex =>
      _box.get(audioSortIndexBox, defaultValue: thDef[audioSortIndexBox]);
  set audioSortIndex(int value) {
    if (value != audioSortIndex) {
      _box.put(audioSortIndexBox, cast(value, thDef[audioSortIndexBox]));
    }
  }

  int get videoSortIndex =>
      _box.get(videoSortIndexBox, defaultValue: thDef[videoSortIndexBox]);
  set videoSortIndex(int value) {
    if (value != videoSortIndex) {
      _box.put(videoSortIndexBox, cast(value, thDef[videoSortIndexBox]));
    }
  }

  int get searchCount => _box.get(searchCountBox, defaultValue: thDef[searchCountBox]);
  set searchCount(int value) {
    if (value != searchCount) {
      _box.put(searchCountBox, cast(value, thDef[searchCountBox]));
    }
  }

  int get searchOption => _box.get(searchOptionBox, defaultValue: thDef[searchOptionBox]);
  set searchOption(int value) {
    if (value != searchOption) {
      _box.put(searchOptionBox, cast(value, thDef[searchOptionBox]));
    }
  }

  bool get novelEnableSearch =>
      _box.get(novelEnableSearchBox, defaultValue: thDef[novelEnableSearchBox]);
  set novelEnableSearch(bool value) {
    if (value != novelEnableSearch) {
      _box.put(novelEnableSearchBox, cast(value, thDef[novelEnableSearchBox]));
    }
  }

  bool get mangaEnableSearch =>
      _box.get(mangaEnableSearchBox, defaultValue: thDef[mangaEnableSearchBox]);
  set mangaEnableSearch(bool value) {
    if (value != mangaEnableSearch) {
      _box.put(mangaEnableSearchBox, cast(value, thDef[mangaEnableSearchBox]));
    }
  }

  bool get audioEnableSearch =>
      _box.get(audioEnableSearchBox, defaultValue: thDef[audioEnableSearchBox]);
  set audioEnableSearch(bool value) {
    if (value != audioEnableSearch) {
      _box.put(audioEnableSearchBox, cast(value, thDef[audioEnableSearchBox]));
    }
  }

  bool get videoEnableSearch =>
      _box.get(videoEnableSearchBox, defaultValue: thDef[videoEnableSearchBox]);
  set videoEnableSearch(bool value) {
    if (value != videoEnableSearch) {
      _box.put(videoEnableSearchBox, cast(value, thDef[videoEnableSearchBox]));
    }
  }

  int get autoBackRate => _box.get(autoBackRateBox, defaultValue: thDef[autoBackRateBox]);
  set autoBackRate(int value) {
    if (value != autoBackRate) {
      _box.put(autoBackRateBox, cast(value, thDef[autoBackRateBox]));
    }
  }

  String get autoBackupLastDay =>
      _box.get(autoBackupLastDayBox, defaultValue: thDef[autoBackupLastDayBox]);
  set autoBackupLastDay(String value) {
    if (value != autoBackupLastDay) {
      _box.put(autoBackupLastDayBox, cast(value, thDef[autoBackupLastDayBox]));
    }
  }

  bool get enableWebdav =>
      _box.get(enableWebdavBox, defaultValue: thDef[enableWebdavBox]);
  set enableWebdav(bool value) {
    if (value != enableWebdav) {
      _box.put(enableWebdavBox, cast(value, thDef[enableWebdavBox]));
    }
  }

  String get webdavServer =>
      _box.get(webdavServerBox, defaultValue: thDef[webdavServerBox]);
  set webdavServer(String value) {
    if (value != webdavServer) {
      _box.put(webdavServerBox, cast(value, thDef[webdavServerBox]));
    }
  }

  String get webdavAccount =>
      _box.get(webdavAccountBox, defaultValue: thDef[webdavAccountBox]);
  set webdavAccount(String value) {
    if (value != webdavAccount) {
      _box.put(webdavAccountBox, cast(value, thDef[webdavAccountBox]));
    }
  }

  String get webdavPassword =>
      _box.get(webdavPasswordBox, defaultValue: thDef[webdavPasswordBox]);
  set webdavPassword(String value) {
    if (value != webdavPassword) {
      _box.put(webdavPasswordBox, cast(value, thDef[webdavPasswordBox]));
    }
  }

  bool get enableWebdavRule =>
      _box.get(enableWebdavRuleBox, defaultValue: thDef[enableWebdavRuleBox]);
  set enableWebdavRule(bool value) {
    if (value != enableWebdavRule) {
      _box.put(enableWebdavRuleBox, cast(value, thDef[enableWebdavRuleBox]));
    }
  }

  String get webdavRuleAccount =>
      _box.get(webdavRuleAccountBox, defaultValue: thDef[webdavRuleAccountBox]);
  set webdavRuleAccount(String value) {
    if (value != webdavRuleAccount) {
      _box.put(webdavRuleAccountBox, cast(value, thDef[webdavRuleAccountBox]));
    }
  }

  String get webdavRuleCheckcode =>
      _box.get(webdavRuleCheckcodeBox, defaultValue: thDef[webdavRuleCheckcodeBox]);
  set webdavRuleCheckcode(String value) {
    if (value != webdavRuleCheckcode) {
      _box.put(webdavRuleCheckcodeBox, cast(value, thDef[webdavRuleCheckcodeBox]));
    }
  }

  String get autoRuleUploadLastDay =>
      _box.get(autoRuleUploadLastDayBox, defaultValue: thDef[autoRuleUploadLastDayBox]);
  set autoRuleUploadLastDay(String value) {
    if (value != autoRuleUploadLastDay) {
      _box.put(autoRuleUploadLastDayBox, cast(value, thDef[autoRuleUploadLastDayBox]));
    }
  }

  String get lastestVersion => '${Global.appVersion}+${Global.appBuildNumber}';

  void updateVersion() {
    version = lastestVersion;
  }

  static String staticFontFamily;

  void fromJson(Map<String, dynamic> json, [bool notIgnoreVersion = true]) {
    _box.putAll(json);
  }

  Map<String, dynamic> toJson() => _box.toMap();
}

T cast<T>(x, T defaultValue) => x is T ? x : defaultValue; // 安全转换
