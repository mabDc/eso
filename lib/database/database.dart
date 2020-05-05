// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'rule.dart';
import 'rule_dao.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 4, entities: [Rule])
abstract class AppDatabase extends FloorDatabase {
  RuleDao get ruleDao;
}

// create migration
final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE rule ADD COLUMN postScript TEXT');
});

final migration2to3 = Migration(2, 3, (database) async {
  await database.execute('ALTER TABLE rule ADD COLUMN chapterList TEXT');
});

final migration3to4 = Migration(3, 4, (database) async {
  await database.execute('ALTER TABLE rule ADD COLUMN sort INTEGER');
});
