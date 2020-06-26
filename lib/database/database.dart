// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'rule.dart';
import 'rule_dao.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 5, entities: [Rule])
abstract class AppDatabase extends FloorDatabase {
  RuleDao get ruleDao;
}

final migration4to5 = Migration(4, 5, (database) async {
  await database.execute('ALTER TABLE Rule ADD COLUMN loginUrl TEXT');
  await database.execute('ALTER TABLE Rule ADD COLUMN cookies TEXT');
});
