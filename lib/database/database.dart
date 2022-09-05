import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'rule.dart';
import 'rule_dao.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 11, entities: [Rule])
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

final migration6to7 = Migration(6, 7, (database) async {
  await database.execute('ALTER TABLE Rule ADD COLUMN discoverNextUrl TEXT');
  await database.execute('ALTER TABLE Rule ADD COLUMN searchNextUrl TEXT');
  await database.execute('ALTER TABLE Rule ADD COLUMN chapterNextUrl TEXT');
  await database.execute('ALTER TABLE Rule ADD COLUMN contentNextUrl TEXT');
});

final migration7to8 = Migration(7, 8, (database) async {
  try {
    await database.execute('ALTER TABLE Rule ADD COLUMN enableUpload INT');
  } catch (e) {}
});
final migration8to9 = Migration(8, 9, (database) async {
  try {
    print("8to9");
    await database.execute('ALTER TABLE Rule ADD COLUMN contentDecrypt TEXT');
  } catch (e) {
    print("e:${e}");
  }
});
final migration9to10 = Migration(9, 10, (database) async {
  // try {
  //   print("8to9");
  //   await database.execute('ALTER TABLE Rule ADD COLUMN icon TEXT');
  //   await database.execute('ALTER TABLE Rule ADD COLUMN desc TEXT');
  // } catch (e) {
  //   print("e:${e}");
  // }
});

final migration10to11 = Migration(10, 11, (database) async {
  try {
    print("8to9");
    await database.execute('ALTER TABLE Rule ADD COLUMN icon TEXT');
    await database.execute('ALTER TABLE Rule ADD COLUMN desc TEXT');
  } catch (e) {
    print("e:${e}");
  }
});
