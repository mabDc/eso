import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/history_manager.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/eso_theme.dart';
import 'package:eso/model/edit_source_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/src/factory_mixin.dart' as impl;
import 'package:text_composition/text_composition.dart';
import 'database/database.dart';
import 'database/history_item_manager.dart';
import 'hive/chapter_item_adapter.dart';
import 'hive/search_item_adapter.dart';
import 'database/rule_dao.dart';
import 'database/search_item.dart';
import 'page/novel_page_refactor.dart';
import 'utils/cache_util.dart';

class Global with ChangeNotifier {
  static String appName = '亦搜';
  static String appVersion = '1.20.4';
  static String appBuildNumber = '12004';
  static String appPackageName = "com.mabdc.eso";
  static bool needShowAbout = true;

  static const waitingPath = "lib/assets/waiting.png";
  static const logoPath = "lib/assets/eso_logo.png";
  // static const nowayPath = "lib/assets/noway.png";
  // static const errorPath = "lib/assets/error.png";
  static const cheerioFile = "lib/assets/cheerio.min.js";
  static const md5File = "lib/assets/md5.min.js";
  static const cryptoJSFile = "lib/assets/CryptoJS.min.js";
  static const profileKey = "profile";
  static const searchHistoryKey = "searchHistory";
  static const searchItemKey = "searchItem";
  static const historyItemKey = "historyItem";
  static const textConfigKey = "textConfig";
  static const favoriteListTagKey = "favoriteListTag";
  // static SharedPreferences _prefs;
  // static SharedPreferences get prefs => _prefs;
  static bool _isDesktop;
  static bool get isDesktop => _isDesktop;
  static const fullSpace = "　";
  static int currentHomePage;
  static Color primaryColor;

  static RuleDao _ruleDao;
  static RuleDao get ruleDao => _ruleDao;

  static Future<void> initFont() async {
    final profile = ESOTheme();
    final fontFamily = profile.fontFamily;
    if (fontFamily == null) return;
    final _cacheUtil = CacheUtil(backup: true, basePath: "font");
    final dir = await _cacheUtil.cacheDir();
    try {
      if (fontFamily != null && fontFamily.contains('.')) {
        await loadFontFromList(
          await File(dir + fontFamily).readAsBytes(),
          fontFamily: fontFamily,
        );
      }
    } catch (e) {}
    // try {
    //   final fontFamily =
    //       TextCompositionConfig.fromJSON(jsonDecode(_prefs.getString(TextConfigKey)))
    //           .fontFamily;
    //   if (fontFamily != null && fontFamily.contains('.')) {
    //     await loadFontFromList(
    //       await File(dir + fontFamily).readAsBytes(),
    //       fontFamily: fontFamily,
    //     );
    //   }
    // } catch (e) {}
  }

  static Future<void> initSearchItem() async {
    const key = Global.searchItemKey;
    final isExistSearchItems = await Hive.boxExists(key);
    final sbox = await Hive.openBox<SearchItem>(key);
    if (!isExistSearchItems) {
      // 不存在box， 尝试从旧数据迁移
      final _prefs = await SharedPreferences.getInstance();
      final ori = _prefs.getStringList(key);
      if (ori != null) {
        if (ori.isNotEmpty) {
          ori.forEach((item) {
            final it = SearchItem.fromJson(jsonDecode(item));
            sbox.put(it.id.toString(), it);
          });
        }
        ori.clear();
        _prefs.setStringList(key, const []);
      }
    }
    SearchItemManager.initSearchItem();
  }

  static Future<void> initHistoryItem() async {
    const key = Global.historyItemKey;
    final isExistHistoryItem = await Hive.boxExists(key);
    final hbox = await Hive.openBox<SearchItem>(key);
    if (isExistHistoryItem) {
      final _prefs = await SharedPreferences.getInstance();
      final ori = _prefs.getStringList(key);
      if (ori != null) {
        if (ori.isNotEmpty) {
          ori.forEach((item) {
            final it = SearchItem.fromJson(jsonDecode(item));
            hbox.put(it.id.toString(), it);
          });
        }
        ori.clear();
        _prefs.setStringList(key, const []);
      }
    }
  }

  static Future<void> initSearchHistory() async {
    const key = Global.searchHistoryKey;
    final isExistSearchHistory = await Hive.boxExists(key);
    final shbox = await Hive.openBox<String>(key);
    if (isExistSearchHistory) {
      final _prefs = await SharedPreferences.getInstance();
      final ori = _prefs.getStringList(key);
      if (ori != null) {
        if (ori.isNotEmpty) {
          shbox.addAll(ori);
        }
        ori.clear();
        _prefs.setStringList(key, const []);
      }
      _prefs.clear();
    }
  }

  static Future<bool> init() async {
    Hive.registerAdapter(ChapterItemAdapter());
    Hive.registerAdapter(SearchItemAdapter());
    //迁移 一个一个来
    await initSearchItem();
    await initHistoryItem();
    await initSearchHistory();

    await Hive.openBox(Global.profileKey);
    await Hive.openBox(Global.textConfigKey);
    await Hive.openBox<int>(EditSourceProvider.unlock_hidden_functions);
    await Hive.openBox<List<String>>(Global.favoriteListTagKey);

    _isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    if (isDesktop) {
      sqflite.databaseFactory = databaseFactoryFfi;
      final factory = sqflite.databaseFactory as impl.SqfliteDatabaseFactoryMixin;
      factory.setDatabasesPathOrNull(
          await CacheUtil(backup: true, basePath: "database").cacheDir());
    }
    final _migrations = [
      migration4to5,
      migration5to6,
      migration6to7,
      migration7to8,
      migration8to9,
    ];

    final _database = await $FloorAppDatabase
        .databaseBuilder('eso_database.db')
        .addMigrations(_migrations)
        .build();
    _ruleDao = _database.ruleDao;
    await initFont();
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
    appBuildNumber = packageInfo.buildNumber;
    appName = packageInfo.appName;
    appPackageName = packageInfo.packageName;
    print("delay global init");
    return true;
  }

  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  /// 默认材质高度
  static double elevation = 0.5;

  /// 默认分隔线高度
  static double lineSize = 0.35;

  /// 默认按钮边框大小
  static double borderSize = 0.5;

  /// 颜色亮度调节, offset 取值为 -1 ~ 1 之间
  // static Color colorLight(Color value, double offset) {
  //   int v = (offset * 255).round();
  //   if (v > 0) {
  //     return Color.fromARGB(value.alpha, min(255, value.red + v),
  //         min(255, value.green + v), min(255, value.blue + v));
  //   } else {
  //     return Color.fromARGB(value.alpha, max(0, value.red + v), max(0, value.green + v),
  //         max(0, value.blue + v));
  //   }
  // }

  /// 返回该颜色的亮度, 亮度值介于 0 - 255之间
  // static double lightness(Color color) {
  //   return 0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue;
  // }
}
