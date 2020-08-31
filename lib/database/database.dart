// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'rule.dart';
import 'rule_dao.dart';

part 'database.g.dart'; // the generated code will be there


/// 注意： 每次RlueDao字段更新后，由flutter自动生成database.g.dart文件中会有建表的SQL语句
/// 请将这个语句拷贝出来放到这里，供 windows 平台使用
const createTableSQL =
    'CREATE TABLE IF NOT EXISTS `Rule` (`id` TEXT, `createTime` INTEGER, `modifiedTime` INTEGER, `author` TEXT, `postScript` TEXT, `name` TEXT, `host` TEXT, `contentType` INTEGER, `group` TEXT, `sort` INTEGER, `viewStyle` INTEGER, `useCryptoJS` INTEGER, `loadJs` TEXT, `userAgent` TEXT, `loginUrl` TEXT, `cookies` TEXT, `enableDiscover` INTEGER, `discoverUrl` TEXT, `discoverItems` TEXT, `discoverList` TEXT, `discoverTags` TEXT, `discoverName` TEXT, `discoverCover` TEXT, `discoverAuthor` TEXT, `discoverChapter` TEXT, `discoverDescription` TEXT, `discoverResult` TEXT, `enableSearch` INTEGER, `searchUrl` TEXT, `searchItems` TEXT, `searchList` TEXT, `searchTags` TEXT, `searchName` TEXT, `searchCover` TEXT, `searchAuthor` TEXT, `searchChapter` TEXT, `searchDescription` TEXT, `searchResult` TEXT, `enableMultiRoads` INTEGER, `chapterRoads` TEXT, `chapterRoadName` TEXT, `chapterUrl` TEXT, `chapterItems` TEXT, `chapterList` TEXT, `chapterName` TEXT, `chapterCover` TEXT, `chapterLock` TEXT, `chapterTime` TEXT, `chapterResult` TEXT, `contentUrl` TEXT, `contentItems` TEXT, PRIMARY KEY (`id`))';
/// 数据库版本号
const dbVersion = 6;

@Database(version: dbVersion, entities: [Rule])
abstract class AppDatabase extends FloorDatabase {
  RuleDao get ruleDao;
}

final migration4to5 = Migration(4, 5, (database) async {
  await database.execute('ALTER TABLE Rule ADD COLUMN loginUrl TEXT');
  await database.execute('ALTER TABLE Rule ADD COLUMN cookies TEXT');
});

final migration5to6 = Migration(5, 6, (database) async {
  await database.execute('ALTER TABLE Rule ADD COLUMN viewStyle INT');
});
