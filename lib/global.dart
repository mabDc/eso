import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global with ChangeNotifier {
  static const appName = '亦搜';
  static const appVersion = '1.0.0';

  static const waitingPath = "lib/assets/waiting.png";
  static const cheerioFile = "lib/assets/cheerio.min.js";
  static const md5File = "lib/assets/md5.min.js";
  static const profileKey = "profile";
  static const searchHistoryKey = "searchHistory";

  static SharedPreferences prefs;
  static int currentHomePage;

  static bool get isRelease => bool.fromEnvironment("dart.vm.product");
  static Map<String, int> get colors => {
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
    // "自定义": 0xFFEF3A6E,
  };

  static Future<bool> init() async {
    prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
}
