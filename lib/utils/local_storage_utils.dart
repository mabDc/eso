// import 'dart:convert';
// import 'dart:io';
// import 'package:eso/utils/cache_util.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// /// SharedPreferences 本地存储
// class LocalStorage {

//   static SharedPreferences prefs;
//   static CacheUtil cache;

//   static bool get isCache => Platform.isWindows || Platform.isMacOS;

//   static init() async {
//     if (Platform.isWindows) {
//       if (cache == null) {
//         cache = CacheUtil(cacheName: 'prefs.json', backup: true);
//         await CacheUtil.requestPermission();
//         await cache.cacheDir();
//       }
//     } else {
//       if (prefs == null) {
//         prefs = await SharedPreferences.getInstance();
//       }
//     }
//   }

//   static Future<bool> set(String key, value) async {
//     try {
//       if (isCache) {
//         if (value is int)
//           await cache.setInt(key, value);
//         else if (value is double)
//           await cache.setDouble(key, value);
//         else if (value is bool)
//           await cache.setBool(key, value);
//         else if (value is List<String>)
//           await cache.setStringList(key, value);
//         else if (value is Map)
//           await cache.setString(key, JsonEncoder().convert(value));
//         else if (value is List)
//           await cache.setString(key, JsonEncoder().convert(value));
//         else
//           await cache.setString(key, value);
//       } else {
//         if (value is int)
//           await prefs.setInt(key, value);
//         else if (value is double)
//           await prefs.setDouble(key, value);
//         else if (value is bool)
//           await prefs.setBool(key, value);
//         else if (value is List<String>)
//           await prefs.setStringList(key, value);
//         else if (value is Map)
//           await prefs.setString(key, JsonEncoder().convert(value));
//         else if (value is List)
//           await prefs.setString(key, JsonEncoder().convert(value));
//         else
//           await prefs.setString(key, value);
//       }
//       return true;
//     } catch (e) {
//       print("SharedDataUtils set err: $key, $value");
//       return false;
//     }
//   }

//   static save(String key, value) {
//     set(key, value);
//   }

//   static String get(String key, [String defaultValue]) {
//     try {
//       final value = isCache ? cache.getSync(key, null, false) : prefs.get(key);
//       if (value == null) return defaultValue;
//       return value.toString();
//     } catch (e) {
//       return defaultValue;
//     }
//   }

//   static String getString(String key, [String defaultValue]) {
//     return get(key, defaultValue);
//   }

//   static int getInt(String key, [int defaultValue = 0]) {
//     try {
//       var value = isCache ? cache.getInt(key) : prefs.get(key);
//       if (value == null) return defaultValue;
//       if (value is int) return value;
//       if (value is double) return value.round();
//       return int.parse(value.toString());
//     } catch (e) {
//       return defaultValue;
//     }
//   }

//   static bool getBool(String key, [bool defaultValue = false]) {
//     try {
//       var value = isCache ? cache.getBool(key) : prefs.get(key);
//       if (value == null) return defaultValue;
//       if (value is bool) return value;
//       if (value is String) {
//         return value == "true" || value == "yes" || value == "1";
//       }
//       if (value is int)
//         return value != 0;
//       return defaultValue;
//     } catch (e) {
//       return defaultValue;
//     }
//   }

//   static double getFloat(String key, [double defaultValue = 0.0]) {
//     try {
//       var value = isCache ? cache.getDataSync(key) : prefs.get(key);
//       if (value == null) return defaultValue;
//       if (value is double) return value;
//       if (value is int) return value.toDouble();
//       return double.parse(value.toString());
//     } catch (e) {
//       return defaultValue;
//     }
//   }

//   static Map<dynamic, dynamic> getMap(String key, [Map<dynamic, dynamic> defaultValue]) {
//     try {
//       var value = isCache ? cache.getDataSync(key) : prefs.get(key);
//       if (value == null) return defaultValue;
//       if (value is String) return JsonDecoder().convert(value);
//     } catch (e) {}
//     return defaultValue;
//   }

//   static List<dynamic> getList(String key, [List<dynamic> defaultValue]) {
//     try {
//       var value = isCache ? cache.getDataSync(key) : prefs.get(key);
//       if (value == null) return defaultValue;
//       if (value is List<String>) return value;
//       if (value is String) return JsonDecoder().convert(value);
//     } catch (e) {}
//     return defaultValue;
//   }

//   static List<String> getStringList(String key, [List<String> defaultValue]) {
//     try {
//       var value = isCache ? cache.getStringList(key) : prefs.getStringList(key);
//       if (value == null) return defaultValue;
//       return value;
//     } catch (e) {
//       print(e);
//     }
//     return defaultValue;
//   }
//   static remove(String key) async {
//     try {
//       if (prefs.containsKey(key))
//         await prefs.remove(key);
//     } catch (e) {}
//   }

// }
