import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

/// 缓存
class CacheUtil {
  static const String _basePath = 'cache';
  static const String _backupPath = 'backup';
  static String _cacheBasePath, _cacheStoragePath;

  /// 缓存名称
  final String cacheName;
  /// 是否是备份
  final bool backup;

  CacheUtil({this.cacheName, this.backup = false});

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
    var dir = await getCacheBasePath(backup);
    if (dir == null || dir.isEmpty) return null;
    dir = dir + _separator + 'eso' + _separator + (backup ? _backupPath : _basePath);
    if (allCache == true) {
      return dir + _separator;
    }
    if (cacheName != null && cacheName.isNotEmpty)
      dir = dir + _separator + cacheName.hashCode.toString();
    _cacheDir = dir + _separator;
    print('cache dir: $_cacheDir');
    return _cacheDir;
  }

  Future<String> getFileName(String key, bool hashCodeKey) async {
    var dir = _cacheDir ?? await cacheDir();
    if (dir == null || dir.isEmpty) return null;
    return dir + (hashCodeKey ? key.hashCode.toString() + '.data' : key);
  }

  /// 写入 key
  Future<bool> put(String key, String value, [bool hashCodeKey = true]) async {
    if (key == null || key.isEmpty)
      return false;
    var _file = await getFileName(key, hashCodeKey);
    if (_file == null || _file.isEmpty)
      return false;
    File _cacheFile = await createFile(_file, path: _cacheDir);
    if (_cacheFile == null) return false;
    await _cacheFile.writeAsString(value);
    return true;
  }

  /// 获取 key 对应的数据
  Future<String> get(String key, [String defaultValue, bool hashCodeKey = true]) async {
    if (key == null || key.isEmpty)
      return defaultValue;
    var _file = await getFileName(key, hashCodeKey);
    if (_file == null || _file.isEmpty)
      return defaultValue;
    File _cacheFile = File(_file);
    if (_cacheFile.existsSync())
      return _cacheFile.readAsStringSync();
    return null;
  }

  Future<bool> putData(String key, Object value, [bool hashCodeKey = true]) async {
    return await put(key, jsonEncode(value), hashCodeKey);
  }

  Future getData(String key, [Object defaultValue, bool hashCodeKey = true]) async {
    final value = await get(key, null, hashCodeKey);
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

  /// 获取缓存放置目录 (写了一堆，提升兼容性）
  static Future<String> getCacheBasePath([bool storage]) async {
    if (_cacheStoragePath == null) {
      try {
        if (Platform.isAndroid) {
          _cacheStoragePath =  (await getExternalStorageDirectory()).path;
          if (_cacheStoragePath != null && _cacheStoragePath.isNotEmpty) {
            final _subStr = 'storage/emulated/0/';
            var index = _cacheStoragePath.indexOf(_subStr);
            if (index >= 0) {
              _cacheStoragePath =
                  _cacheStoragePath.substring(0, index + _subStr.length - 1);
            }
          }
        } else
          _cacheStoragePath = (await getApplicationDocumentsDirectory()).path;
      } catch (e) {}
    }
    if (_cacheBasePath == null) {
      _cacheBasePath = (await getApplicationDocumentsDirectory()).path;
      if (_cacheBasePath == null || _cacheBasePath.isEmpty) {
        _cacheBasePath = (await getApplicationSupportDirectory()).path;
        if (_cacheBasePath == null || _cacheBasePath.isEmpty) {
          _cacheBasePath = (await getTemporaryDirectory()).path;
        }
      }
      if (_cacheStoragePath == null || _cacheStoragePath.isEmpty)
        _cacheStoragePath = _cacheBasePath;
    }
    return storage == true ? _cacheStoragePath : _cacheBasePath;
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