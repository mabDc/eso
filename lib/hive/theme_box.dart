import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _name = "themeBox";

Future<Box> openThemeBox() => Hive.openBox(_name);
final themeBox = Hive.box(_name);

const displayHighRateKey = "displayHighRate";
const displayModeIdKey = "displayModeId";
const displayModeWidthKey = "displayModeWidth";
const displayModeHeightKey = "displayModeHeight";
const displayModeRefreshRateKey = "displayModeRefreshRate";
bool get displayHighRate => themeBox.get(displayHighRateKey, defaultValue: false);
DisplayMode get displayMode {
  final int id = themeBox.get(displayModeIdKey, defaultValue: 0);
  final int width = themeBox.get(displayModeWidthKey, defaultValue: 0);
  final int height = themeBox.get(displayModeHeightKey, defaultValue: 0);
  final double refreshRate = themeBox.get(displayModeRefreshRateKey, defaultValue: 0.0);
  return DisplayMode(id: id, height: height, width: width, refreshRate: refreshRate);
}

set displayMode(DisplayMode mode) {
  themeBox.put(displayModeIdKey, mode.id);
  themeBox.put(displayModeWidthKey, mode.width);
  themeBox.put(displayModeHeightKey, mode.height);
  themeBox.put(displayModeRefreshRateKey, mode.refreshRate);
}

const primaryColorKey = "primaryColor";
int get primaryColor =>
    themeBox.get(primaryColorKey, defaultValue: tomatoCat[primaryColorKey]);

const iconColorKey = "iconColor";
int get iconColor => themeBox.get(iconColorKey, defaultValue: tomatoCat[iconColorKey]);

const appBarForegroundColorKey = "appBarForegroundColor";
int get appBarForegroundColor => themeBox.get(appBarForegroundColorKey,
    defaultValue: tomatoCat[appBarForegroundColorKey]);

const appBarBackgroundColorKey = "appBarBackgroundColor";
int get appBarBackgroundColor => themeBox.get(appBarBackgroundColorKey,
    defaultValue: tomatoCat[appBarBackgroundColorKey]);

const scaffoldBackgroundColorKey = "scaffoldBackgroundColor";
int get scaffoldBackgroundColor => themeBox.get(scaffoldBackgroundColorKey,
    defaultValue: tomatoCat[scaffoldBackgroundColorKey]);

const cardBackgroundColorKey = "cardBackgroundColor";
int get cardBackgroundColor =>
    themeBox.get(cardBackgroundColorKey, defaultValue: tomatoCat[cardBackgroundColorKey]);

const tomatoCat = {
  "themeMode": ThemeMode.light,
  decorationImageKey: "懒儿3.jpg",
  primaryColorKey: 0xe9604122,
  iconColorKey: 0xffedbe83,
  appBarForegroundColorKey: 0xff0e2832,
  appBarBackgroundColorKey: 0xe8e1944e,
  scaffoldBackgroundColorKey: 0xccf0e8d8,
  cardBackgroundColorKey: 0xfff0e8d8,
};

ThemeData getGlobalThemeData() => ThemeData(
      primaryColor: Color(primaryColor),
      iconTheme: IconThemeData(color: Color(iconColor)),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Color(iconColor);
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Color(iconColor).withOpacity(0.9);
          }
          return Colors.grey;
        }),
      ),
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        foregroundColor: Color(appBarForegroundColor),
        backgroundColor: Color(appBarBackgroundColor),
        iconTheme: IconThemeData(color: Color(iconColor)),
        actionsIconTheme: IconThemeData(color: Color(iconColor)),
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: Color(scaffoldBackgroundColor),
        elevation: 100,
      ),
      scaffoldBackgroundColor: Color(scaffoldBackgroundColor),
      cardTheme: CardTheme(color: Color(cardBackgroundColor)),
    );

const appBarForegroundDarkColorKey = "appBarForegroundDarkColor";
int get appBarForegroundDarkColor =>
    themeBox.get(appBarForegroundDarkColorKey, defaultValue: colors["象牙色"]);

const appBarBackgroundDarkColorKey = "appBarBackgroundDarkColor";
int get appBarBackgroundDarkColor =>
    themeBox.get(appBarBackgroundDarkColorKey, defaultValue: colors["星空灰"]);

const scaffoldBackgroundDarkColorKey = "scaffoldBackgroundDarkColor";
int get scaffoldBackgroundDarkColor =>
    themeBox.get(scaffoldBackgroundDarkColorKey, defaultValue: colors["星空灰"]);

const cardBackgroundDarkColorKey = "cardBackgroundDarkColor";
int get cardBackgroundDarkColor =>
    themeBox.get(cardBackgroundDarkColorKey, defaultValue: colors["星空灰"]);

ThemeData getGlobalDarkThemeData() => ThemeData(
      primaryColor: Color(primaryColor),
      iconTheme: IconThemeData(color: Color(iconColor)),
            switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Color(iconColor);
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return Color(iconColor).withOpacity(0.9);
          }
          return Colors.grey;
        }),
      ),
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        foregroundColor: Color(appBarForegroundDarkColor),
        backgroundColor: Color(appBarBackgroundDarkColor),
        iconTheme: IconThemeData(color: Color(iconColor)),
        actionsIconTheme: IconThemeData(color: Color(iconColor)),
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: Color(scaffoldBackgroundDarkColor),
        elevation: 100,
      ),
      scaffoldBackgroundColor: Color(scaffoldBackgroundDarkColor),
      cardTheme: CardTheme(color: Color(cardBackgroundDarkColor)),
    );

const decorationImageKey = "decorationImage";
String get decorationImage => themeBox.get(decorationImageKey,
    defaultValue: "assets/ba/${tomatoCat[decorationImageKey]}");

Map<String, int> get colors => {
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
