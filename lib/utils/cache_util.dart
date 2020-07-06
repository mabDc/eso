import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

/// 缓存
class CacheUtil {
  static const String _basePath = 'esoCache';
  static String _cacheBasePath;

  /// 缓存名称
  final String cacheName;

  CacheUtil({this.cacheName});

  String _cacheDir;

  /// 请求权限
  Future<bool> requestPermission() async {
    // 检查并请求权限
    if (await Permission.storage.status != PermissionStatus.granted) {
      var _status = await Permission.storage.request();
      if (_status != PermissionStatus.granted)
        return false;
    }
    return true;
  }

  Future<String> cacheDir([bool allCache]) async {
    if (_cacheDir != null && allCache != true) return _cacheDir;
    var dir = _cacheBasePath == null || _cacheBasePath.isEmpty
        ?  await getCacheBasePath()
        : _cacheBasePath;
    if (dir == null || dir.isEmpty) return null;
    dir = dir + _separator + _basePath;
    if (allCache == true) {
      return dir + _separator;
    }
    if (cacheName != null && cacheName.isNotEmpty)
      dir = dir + _separator + cacheName.hashCode.toString();
    _cacheDir = dir + _separator;
    print('cache dir: $_cacheDir');
    return _cacheDir;
  }

  Future<String> getFileName(String key) async {
    var dir = _cacheDir ?? await cacheDir();
    if (dir == null || dir.isEmpty) return null;
    return dir + key.hashCode.toString() + '.data';
  }

  /// 写入 key
  Future<bool> put(String key, String value) async {
    if (key == null || key.isEmpty)
      return false;
    var _file = await getFileName(key);
    if (_file == null || _file.isEmpty)
      return false;
    File _cacheFile = await createFile(_file, path: _cacheDir);
    if (_cacheFile == null) return false;
    await _cacheFile.writeAsString(value);
    return true;
  }

  /// 获取 key 对应的数据
  Future<String> get(String key, [String defaultValue]) async {
    if (key == null || key.isEmpty)
      return defaultValue;
    var _file = await getFileName(key);
    if (_file == null || _file.isEmpty)
      return defaultValue;
    File _cacheFile = File(_file);
    if (_cacheFile.existsSync())
      return _cacheFile.readAsStringSync();
    return null;
  }

  Future<bool> putData(String key, Object value) async {
    return await put(key, jsonEncode(value));
  }

  Future getData(String key, [Object defaultValue]) async {
    final value = await get(key, null);
    if (value == null || value.isEmpty) return defaultValue;
    return jsonDecode(value);
  }

  /// 清理缓存
  /// [allCache] 清除所有缓存
  Future<void> clear({bool allCache}) async {
    try {
      await requestPermission();
      var dir = await cacheDir(allCache);
      if (dir == null || dir.isEmpty) return;
      Directory _dir = Directory(dir);
      if (!_dir.existsSync()) return;
      await _dir.delete(recursive: true).then((value) {
        print(value);
      }).catchError((err) => print(err));
    } catch (e) {
      print(e);
    }
  }

  /// 路径分隔符
  static String get _separator => Platform.pathSeparator;

  /// 获取缓存放置目录
  static Future<String> getCacheBasePath() async {
    if (_cacheBasePath == null) {
      _cacheBasePath = (await getApplicationSupportDirectory()).path;
      if (_cacheBasePath == null || _cacheBasePath.isEmpty) {
        _cacheBasePath = (await getApplicationDocumentsDirectory()).path;
        if (_cacheBasePath == null || _cacheBasePath.isEmpty) {
          _cacheBasePath = (await getExternalStorageDirectory()).path;
          if (_cacheBasePath == null || _cacheBasePath.isEmpty) {
            _cacheBasePath = (await getTemporaryDirectory()).path;
          }
        }
      }
    }
    return _cacheBasePath;
  }

  static String getFilePath(final String file) {
    return path.dirname(file) + _separator;
  }

  static bool existPath(final String _path) {
    return new Directory(_path).existsSync();
  }

  static Future<bool> createPath(final String path) async {
    return (await new Directory(path).create(recursive: true)).exists();
  }

  static Future<File> createFile(final String file, {String path}) async {
    try {
      String _path = path ?? getFilePath(file);
      if (!existPath(_path)) {
        if (!await createPath(_path)) {
          return null;
        }
      }
      return await new File(file).create(recursive: true);
    } catch (e) {
      print(e);
      return null;
    }
  }

}