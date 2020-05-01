// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? join(await sqflite.getDatabasesPath(), name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RuleDao _ruleDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    return sqflite.openDatabase(
      path,
      version: 1,
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
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Rule` (`id` TEXT, `createTime` INTEGER, `modifiedTime` INTEGER, `author` TEXT, `name` TEXT, `host` TEXT, `contentType` INTEGER, `useCryptoJS` INTEGER, `loadJs` TEXT, `userAgent` TEXT, `enableDiscover` INTEGER, `discoverUrl` TEXT, `discoverItems` TEXT, `discoverList` TEXT, `discoverTags` TEXT, `discoverName` TEXT, `discoverCover` TEXT, `discoverAuthor` TEXT, `discoverChapter` TEXT, `discoverDescription` TEXT, `discoverResult` TEXT, `enableSearch` INTEGER, `searchUrl` TEXT, `searchItems` TEXT, `searchList` TEXT, `searchTags` TEXT, `searchName` TEXT, `searchCover` TEXT, `searchAuthor` TEXT, `searchChapter` TEXT, `searchDescription` TEXT, `searchResult` TEXT, `enableMultiRoads` INTEGER, `chapterRoads` TEXT, `chapterRoadName` TEXT, `chapterUrl` TEXT, `chapterItems` TEXT, `chapterName` TEXT, `chapterCover` TEXT, `chapterLock` TEXT, `chapterTime` TEXT, `chapterResult` TEXT, `contentUrl` TEXT, `contentItems` TEXT, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
  }

  @override
  RuleDao get ruleDao {
    return _ruleDaoInstance ??= _$RuleDao(database, changeListener);
  }
}

class _$RuleDao extends RuleDao {
  _$RuleDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _ruleInsertionAdapter = InsertionAdapter(
            database,
            'Rule',
            (Rule item) => <String, dynamic>{
                  'id': item.id,
                  'createTime': item.createTime,
                  'modifiedTime': item.modifiedTime,
                  'author': item.author,
                  'name': item.name,
                  'host': item.host,
                  'contentType': item.contentType,
                  'useCryptoJS': item.useCryptoJS ? 1 : 0,
                  'loadJs': item.loadJs,
                  'userAgent': item.userAgent,
                  'enableDiscover': item.enableDiscover ? 1 : 0,
                  'discoverUrl': item.discoverUrl,
                  'discoverItems': item.discoverItems,
                  'discoverList': item.discoverList,
                  'discoverTags': item.discoverTags,
                  'discoverName': item.discoverName,
                  'discoverCover': item.discoverCover,
                  'discoverAuthor': item.discoverAuthor,
                  'discoverChapter': item.discoverChapter,
                  'discoverDescription': item.discoverDescription,
                  'discoverResult': item.discoverResult,
                  'enableSearch': item.enableSearch ? 1 : 0,
                  'searchUrl': item.searchUrl,
                  'searchItems': item.searchItems,
                  'searchList': item.searchList,
                  'searchTags': item.searchTags,
                  'searchName': item.searchName,
                  'searchCover': item.searchCover,
                  'searchAuthor': item.searchAuthor,
                  'searchChapter': item.searchChapter,
                  'searchDescription': item.searchDescription,
                  'searchResult': item.searchResult,
                  'enableMultiRoads': item.enableMultiRoads ? 1 : 0,
                  'chapterRoads': item.chapterRoads,
                  'chapterRoadName': item.chapterRoadName,
                  'chapterUrl': item.chapterUrl,
                  'chapterItems': item.chapterItems,
                  'chapterName': item.chapterName,
                  'chapterCover': item.chapterCover,
                  'chapterLock': item.chapterLock,
                  'chapterTime': item.chapterTime,
                  'chapterResult': item.chapterResult,
                  'contentUrl': item.contentUrl,
                  'contentItems': item.contentItems
                }),
        _ruleDeletionAdapter = DeletionAdapter(
            database,
            'Rule',
            ['id'],
            (Rule item) => <String, dynamic>{
                  'id': item.id,
                  'createTime': item.createTime,
                  'modifiedTime': item.modifiedTime,
                  'author': item.author,
                  'name': item.name,
                  'host': item.host,
                  'contentType': item.contentType,
                  'useCryptoJS': item.useCryptoJS ? 1 : 0,
                  'loadJs': item.loadJs,
                  'userAgent': item.userAgent,
                  'enableDiscover': item.enableDiscover ? 1 : 0,
                  'discoverUrl': item.discoverUrl,
                  'discoverItems': item.discoverItems,
                  'discoverList': item.discoverList,
                  'discoverTags': item.discoverTags,
                  'discoverName': item.discoverName,
                  'discoverCover': item.discoverCover,
                  'discoverAuthor': item.discoverAuthor,
                  'discoverChapter': item.discoverChapter,
                  'discoverDescription': item.discoverDescription,
                  'discoverResult': item.discoverResult,
                  'enableSearch': item.enableSearch ? 1 : 0,
                  'searchUrl': item.searchUrl,
                  'searchItems': item.searchItems,
                  'searchList': item.searchList,
                  'searchTags': item.searchTags,
                  'searchName': item.searchName,
                  'searchCover': item.searchCover,
                  'searchAuthor': item.searchAuthor,
                  'searchChapter': item.searchChapter,
                  'searchDescription': item.searchDescription,
                  'searchResult': item.searchResult,
                  'enableMultiRoads': item.enableMultiRoads ? 1 : 0,
                  'chapterRoads': item.chapterRoads,
                  'chapterRoadName': item.chapterRoadName,
                  'chapterUrl': item.chapterUrl,
                  'chapterItems': item.chapterItems,
                  'chapterName': item.chapterName,
                  'chapterCover': item.chapterCover,
                  'chapterLock': item.chapterLock,
                  'chapterTime': item.chapterTime,
                  'chapterResult': item.chapterResult,
                  'contentUrl': item.contentUrl,
                  'contentItems': item.contentItems
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _ruleMapper = (Map<String, dynamic> row) => Rule(
        row['id'] as String,
        row['createTime'] as int,
        row['modifiedTime'] as int,
        row['author'] as String,
        row['name'] as String,
        row['host'] as String,
        row['contentType'] as int,
        row['useCryptoJS'] as int != 0,
        row['loadJs'] as String,
        row['userAgent'] as String,
        row['enableDiscover'] as int != 0,
        row['discoverUrl'] as String,
        row['discoverItems'] as String,
        row['discoverList'] as String,
        row['discoverTags'] as String,
        row['discoverName'] as String,
        row['discoverCover'] as String,
        row['discoverAuthor'] as String,
        row['discoverChapter'] as String,
        row['discoverDescription'] as String,
        row['discoverResult'] as String,
        row['enableSearch'] as int != 0,
        row['searchUrl'] as String,
        row['searchItems'] as String,
        row['searchList'] as String,
        row['searchTags'] as String,
        row['searchName'] as String,
        row['searchCover'] as String,
        row['searchAuthor'] as String,
        row['searchChapter'] as String,
        row['searchDescription'] as String,
        row['searchResult'] as String,
        row['enableMultiRoads'] as int != 0,
        row['chapterRoads'] as String,
        row['chapterRoadName'] as String,
        row['chapterUrl'] as String,
        row['chapterItems'] as String,
        row['chapterName'] as String,
        row['chapterCover'] as String,
        row['chapterLock'] as String,
        row['chapterTime'] as String,
        row['chapterResult'] as String,
        row['contentUrl'] as String,
        row['contentItems'] as String,
      );

  final InsertionAdapter<Rule> _ruleInsertionAdapter;

  final DeletionAdapter<Rule> _ruleDeletionAdapter;

  @override
  Future<Rule> findRuleById(String id) async {
    return _queryAdapter.query('SELECT * FROM rule WHERE id = ?',
        arguments: <dynamic>[id], mapper: _ruleMapper);
  }

  @override
  Future<List<Rule>> findAllRules() async {
    return _queryAdapter.queryList('SELECT * FROM rule', mapper: _ruleMapper);
  }

  @override
  Future<int> insertOrUpdateRule(Rule rule) {
    return _ruleInsertionAdapter.insertAndReturnId(
        rule, sqflite.ConflictAlgorithm.replace);
  }

  @override
  Future<List<int>> insertOrUpdateRules(List<Rule> rules) {
    return _ruleInsertionAdapter.insertListAndReturnIds(
        rules, sqflite.ConflictAlgorithm.replace);
  }

  @override
  Future<int> deleteRule(Rule rule) {
    return _ruleDeletionAdapter.deleteAndReturnChangedRows(rule);
  }

  @override
  Future<int> deleteRules(List<Rule> rules) {
    return _ruleDeletionAdapter.deleteListAndReturnChangedRows(rules);
  }
}
