import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/profile.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/src/factory_mixin.dart' as impl;
import 'package:text_composition/text_composition.dart';
import 'package:win32/win32.dart';
import 'database/database.dart';
import 'database/history_item_manager.dart';
import 'database/rule_dao.dart';
import 'page/novel_page_refactor.dart';
import 'utils/cache_util.dart';

class Global with ChangeNotifier {
  static String appName = '亦搜';
  static String appVersion = '1.22.15';
  static String appBuildNumber = '12215';
  static String appPackageName = "com.zyd.eso";
  static bool needShowAbout = true;
  static String userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36 Edg/100.0.1185.29';

  static const waitingPath = "lib/assets/waiting.png";
  static const logoPath = "lib/assets/eso_logo.png";
  // static const nowayPath = "lib/assets/noway.png";
  // static const errorPath = "lib/assets/error.png";
  static const cheerioFile = "lib/assets/cheerio.min.js";
  static const md5File = "lib/assets/md5.min.js";
  static const cryptoJSFile = "lib/assets/CryptoJS.min.js";
  static const JSEncryptFile = "lib/assets/JSencrypt.min.js";

  static const profileKey = "profile";
  static const searchHistoryKey = "searchHistory";
  static const searchItemKey = "searchItem";
  static const historyItemKey = "historyItem";
  static SharedPreferences _prefs;
  static SharedPreferences get prefs => _prefs;
  static bool _isDesktop;
  static bool get isDesktop => _isDesktop;
  static const fullSpace = "　";
  static int currentHomePage;
  static Color primaryColor;

  static RuleDao _ruleDao;
  static RuleDao get ruleDao => _ruleDao;
  static String httpCache;

  static Future<void> initFont() async {
    final profile = Profile();
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
    try {
      final fontFamily = TextCompositionConfig.fromJSON(
              jsonDecode(_prefs.getString(TextConfigKey)))
          .fontFamily;
      if (fontFamily != null && fontFamily.contains('.')) {
        await loadFontFromList(
          await File(dir + fontFamily).readAsBytes(),
          fontFamily: fontFamily,
        );
      }
    } catch (e) {}
  }

  static Future<bool> init() async {
    _isDesktop = Platform.isLinux || Platform.isMacOS || Platform.isWindows;
    if (isDesktop) {
      sqflite.databaseFactory = databaseFactoryFfi;
      final factory =
          sqflite.databaseFactory as impl.SqfliteDatabaseFactoryMixin;

      factory.setDatabasesPathOrNull(
          await CacheUtil(backup: true, basePath: "database").cacheDir());
    }
    httpCache = await CacheUtil(backup: true, basePath: "httpCache").cacheDir();

    print("httpCache:${httpCache}");

    _prefs = await SharedPreferences.getInstance();
    SearchItemManager.initSearchItem();
    HistoryItemManager.initHistoryItem();
    final _migrations = [
      migration4to5,
      migration5to6,
      migration6to7,
      migration7to8,
      migration8to9,
      migration9to10,
      migration10to11,
    ];

    final _database = await $FloorAppDatabase
        .databaseBuilder('eso_yd_database.db')
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

  static Map<String, int> get colors => {
        // "自定义": 0xFF4BB0A0,
        "冰青色": 0xFF4BB0A0,
        "酷安绿": 0xFF4BAF4F,
        "知乎蓝": 0xFF1F96F2,
        "哔哩粉": 0xFFFA7298,
        "网易红": 0xFFD33B30,
        "藤萝紫": 0xFFB47DB4,
        "碧海蓝": 0xFF59b7c3,
        "樱草绿": 0xFF89c348,
        "咖啡棕": 0xFF75655a,
        "柠檬橙": 0xFFD88100,
        "星空灰": 0xFF374f59,
        "象牙色": 0xFFFFFFE0,
        "亮黄色": 0xFFFFFF00,
        "黄色": 0xFFFFFAFA,
        "雪白色": 0xFFFFFAF0,
        "花白色": 0xFFFFFACD,
        "柠檬绸色": 0xFFFFF8DC,
        "米绸色": 0xFFFFF5EE,
        "海贝色": 0xFFFFF0F5,
        "淡紫红": 0xFFFFEFD5,
        "番木色": 0xFFFFEBCD,
        "白杏色": 0xFFFFE4E1,
        "浅玫瑰色": 0xFFFFE4C4,
        "桔黄色": 0xFFFFE4B5,
        "鹿皮色": 0xFFFFDEAD,
        "纳瓦白": 0xFFFFDAB9,
        "桃色": 0xFFFFD700,
        "金色": 0xFFFFC0CB,
        "粉红色": 0xFFFFB6C1,
        "亮粉红色": 0xFFFFA500,
        "橙色": 0xFFFFA07A,
        "亮肉色": 0xFFFF8C00,
        "暗桔黄色": 0xFFFF7F50,
        "珊瑚色": 0xFFFF69B4,
        "热粉红色": 0xFFFF6347,
        "西红柿色": 0xFFed6a12,
        "红橙色": 0xFF4ded6a12,
        "透明红橙色": 0xFFFF1493,
        "深粉红色": 0xFFFF00FF,
        "紫红色": 0xFFFF00FF,
        "红紫色": 0xFFFF0000,
        "红色": 0xFFFDF5E6,
        "老花色": 0xFFFAFAD2,
        "亮金黄色": 0xFFFAF0E6,
        "亚麻色": 0xFFFAEBD7,
        "古董白": 0xFFFA8072,
        "鲜肉色": 0xFFF8F8FF,
        "幽灵白": 0xFFF5FFFA,
        "薄荷色": 0xFFF5F5F5,
        "烟白色": 0xFFF5F5DC,
        "米色": 0xFFF5DEB3,
        "浅黄色": 0xFFF4A460,
        "沙褐色": 0xFFF0FFFF,
        "天蓝色": 0xFFF0FFF0,
        "蜜色": 0xFFF0F8FF,
        "艾利斯兰": 0xFFF0E68C,
        "黄褐色": 0xFFF08080,
        "亮珊瑚色": 0xFFEEE8AA,
        "苍麒麟色": 0xFFEE82EE,
        "紫罗兰色": 0xFFE9967A,
        "暗肉色": 0xFFE6E6FA,
        "淡紫色": 0xFFE0FFFF,
        "亮青色": 0xFFDEB887,
        "实木色": 0xFFDDA0DD,
        "洋李色": 0xFFDCDCDC,
        "淡灰色": 0xFFDC143C,
        "暗深红色": 0xFFDB7093,
        "苍紫罗兰色": 0xFFDAA520,
        "金麒麟色": 0xFFDA70D6,
        "蓟色": 0xFFD3D3D3,
        "亮灰色": 0xFFD3D3D3,
        "茶色": 0xFFD2691E,
        "巧可力色": 0xFFCD853F,
        "秘鲁色": 0xFFCD5C5C,
        "印第安红": 0xFFC71585,
        "中紫罗兰色": 0xFFC0C0C0,
        "银色": 0xFFBDB76B,
        "暗黄褐色": 0xFFBC8F8F,
        "褐玫瑰红": 0xFFBA55D3,
        "中粉紫色": 0xFFB8860B,
        "暗金黄色": 0xFFB22222,
        "火砖色": 0xFFB0E0E6,
        "粉蓝色": 0xFFB0C4DE,
        "亮钢兰色": 0xFFAFEEEE,
        "苍宝石绿": 0xFFADFF2F,
        "黄绿色": 0xFFADD8E6,
        "亮蓝色": 0xFFA9A9A9,
        "暗灰色": 0xFFA9A9A9,
        "褐色": 0xFFA0522D,
        "赭色": 0xFF9932CC,
        "暗紫色": 0xFF98FB98,
        "苍绿色": 0xFF9400D3,
        "暗紫罗兰色": 0xFF9370DB,
        "中紫色": 0xFF90EE90,
        "亮绿色": 0xFF8FBC8F,
        "暗海兰色": 0xFF8B4513,
        "重褐色": 0xFF8B008B,
        "暗洋红": 0xFF8B0000,
        "暗红色": 0xFF8A2BE2,
        "紫罗兰蓝色": 0xFF87CEFA,
        "亮天蓝色": 0xFF87CEEB,
        "灰色": 0xFFcccccc,
        "深灰色": 0xFFb9b9b9,
        "c灰色": 0xFF808000,
        "橄榄色": 0xFF800080,
        "紫色": 0xFF800000,
        "粟色": 0xFF7FFFD4,
        "碧绿色": 0xFF7FFF00,
        "草绿色": 0xFF7B68EE,
        "中暗蓝色": 0xFF778899,
        "亮蓝灰": 0xFF778899,
        "灰石色": 0xFF708090,
        "深绿褐色": 0xFF6A5ACD,
        "石蓝色": 0xFF696969,
        "中绿色": 0xFF6495ED,
        "菊兰色": 0xFF5F9EA0,
        "军兰色": 0xFF556B2F,
        "暗橄榄绿": 0xFF4B0082,
        "靛青色": 0xFF48D1CC,
        "中绿宝石": 0xFF483D8B,
        "暗灰蓝色": 0xFF4682B4,
        "钢兰色": 0xFF4169E1,
        "皇家蓝": 0xFF40E0D0,
        "青绿色": 0xFF3CB371,
        "中海蓝": 0xFF32CD32,
        "橙绿色": 0xFF2F4F4F,
        "暗瓦灰色": 0xFF2F4F4F,
        "海绿色": 0xFF228B22,
        "森林绿": 0xFF20B2AA,
        "亮海蓝色": 0xFF1E90FF,
        "闪兰色": 0xFF191970,
        "中灰兰色": 0xFF00FFFF,
        "浅绿色": 0xFF00FFFF,
        "青色": 0xFF00FF7F,
        "春绿色": 0xFF00FF00,
        "酸橙色": 0xFF00FA9A,
        "中春绿色": 0xFF00CED1,
        "暗宝石绿": 0xFF00BFFF,
        "深天蓝色": 0xFF008B8B,
        "暗青色": 0xFF008080,
        "水鸭色": 0xFF008000,
        "绿色": 0xFF006400,
        "暗绿色": 0xFF0000FF,
        "蓝色": 0xFF0000CD,
        "中兰色": 0xFF00008B,
        "暗蓝色": 0xFF000080,
        "海军色": 0xFF000000,
      };

  /// 颜色亮度调节, offset 取值为 -1 ~ 1 之间
  static Color colorLight(Color value, double offset) {
    int v = (offset * 255).round();
    if (v > 0) {
      return Color.fromARGB(value.alpha, min(255, value.red + v),
          min(255, value.green + v), min(255, value.blue + v));
    } else {
      return Color.fromARGB(value.alpha, max(0, value.red + v),
          max(0, value.green + v), max(0, value.blue + v));
    }
  }

  /// 返回该颜色的亮度, 亮度值介于 0 - 255之间
  static double lightness(Color color) {
    return 0.2126 * color.red + 0.7152 * color.green + 0.0722 * color.blue;
  }

  // static SystemUiOverlayStyle novelLightOrDark() {
  //   return lightness(Color(Profile().novelFontColor)) > 127
  //       ? SystemUiOverlayStyle.light
  //       : SystemUiOverlayStyle.dark;
  // }
}
