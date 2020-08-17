import 'dart:ffi';
import 'dart:io';
import 'package:eso/utils/cache_util.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:floor/floor.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:moor_ffi/database.dart' as db;
import 'package:sqflite/src/factory_mixin.dart' as impl;
import 'package:moor_ffi/open_helper.dart';
import 'package:path/path.dart';

/// sqlite for windows by yangyxd
class SQFLiteWinUtil {
  static Future<sqflite.Database> setup(
      {List<Migration> migrations,
      int version,
      String name,
      String createSQL,
      Callback callback}) async {
    if (Platform.isWindows || Platform.isLinux) {
      // sqfliteFfiInit();
      if (Platform.isWindows) {
        windowsInit();
      } else {
        linuxInit();
      }
      DatabaseFactory databaseFactory = databaseFactoryFfi;
      final databaseOptions = sqflite.OpenDatabaseOptions(
        version: version,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onOpen: (database) async {
          await callback?.onOpen?.call(database);
        },
        onUpgrade: (database, startVersion, endVersion) async {
          await MigrationAdapter.runMigrations(
              database, startVersion, endVersion, migrations);
          await callback?.onUpgrade?.call(database, startVersion, endVersion);
        },
        onCreate: (database, version) async {
          await database.execute(createSQL);
          await callback?.onCreate?.call(database, version);
        },
      );
      var path = await CacheUtil(backup: true, basePath: "database").cacheDir();
      var dbName = normalize(join(path, name));
      print("db path: $dbName");

      var cacheDbPath = normalize(join(path, 'cache'));
      sqflite.databaseFactory = databaseFactoryFfi;
      final factory = sqflite.databaseFactory as impl.SqfliteDatabaseFactoryMixin;
      factory.setDatabasesPath(cacheDbPath);

      return await databaseFactory.openDatabase(dbName, options: databaseOptions);
    } else
      return null;
  }
}

void windowsInit() {
  open.overrideFor(OperatingSystem.windows, () {
    try {
      return DynamicLibrary.open("sqlite3.dll");
    } catch (e) {
      stderr.writeln('Failed to load sqlite3.dll');
      rethrow;
    }
  });

  // Force an open in the main isolate
  // Loading from an isolate seems to break on windows
  db.Database.memory()..close();
}

void linuxInit() {
  open.overrideFor(OperatingSystem.linux, () {
    try {
      return DynamicLibrary.open("libsqlite3.so");
    } catch (e) {
      stderr.writeln('Failed to load libsqlite3.so');
      rethrow;
    }
  });

  // Force an open in the main isolate
  // Loading from an isolate seems to break on windows
  db.Database.memory()..close();
}
