// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) => _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() => _$AppDatabaseBuilder(null);
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

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path =
        name != null ? await sqfliteDatabaseFactory.getDatabasePath(name) : ':memory:';
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
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 9,
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
            'CREATE TABLE IF NOT EXISTS `Rule` (`id` TEXT, `createTime` INTEGER, `modifiedTime` INTEGER, `enableUpload` INTEGER, `author` TEXT, `postScript` TEXT, `name` TEXT, `host` TEXT, `icon` TEXT, `contentType` INTEGER, `group` TEXT, `sort` INTEGER, `viewStyle` INTEGER, `useCryptoJS` INTEGER, `loadJs` TEXT, `userAgent` TEXT, `loginUrl` TEXT, `cookies` TEXT, `enableDiscover` INTEGER, `discoverUrl` TEXT, `discoverNextUrl` TEXT, `discoverItems` TEXT, `discoverList` TEXT, `discoverTags` TEXT, `discoverName` TEXT, `discoverCover` TEXT, `discoverAuthor` TEXT, `discoverChapter` TEXT, `discoverDescription` TEXT, `discoverResult` TEXT, `enableSearch` INTEGER, `searchUrl` TEXT, `searchNextUrl` TEXT, `searchItems` TEXT, `searchList` TEXT, `searchTags` TEXT, `searchName` TEXT, `searchCover` TEXT, `searchAuthor` TEXT, `searchChapter` TEXT, `searchDescription` TEXT, `searchResult` TEXT, `enableMultiRoads` INTEGER, `chapterUrl` TEXT, `chapterNextUrl` TEXT, `chapterRoads` TEXT, `chapterRoadName` TEXT, `chapterItems` TEXT, `chapterList` TEXT, `chapterName` TEXT, `chapterCover` TEXT, `chapterLock` TEXT, `chapterTime` TEXT, `chapterResult` TEXT, `contentUrl` TEXT, `contentNextUrl` TEXT, `contentItems` TEXT, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
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
                  'enableUpload':
                      item.enableUpload == null ? null : (item.enableUpload ? 1 : 0),
                  'author': item.author,
                  'postScript': item.postScript,
                  'name': item.name,
                  'host': item.host,
                  'icon': item.icon,
                  'contentType': item.contentType,
                  'group': item.group,
                  'sort': item.sort,
                  'viewStyle': item.viewStyle,
                  'useCryptoJS':
                      item.useCryptoJS == null ? null : (item.useCryptoJS ? 1 : 0),
                  'loadJs': item.loadJs,
                  'userAgent': item.userAgent,
                  'loginUrl': item.loginUrl,
                  'cookies': item.cookies,
                  'enableDiscover':
                      item.enableDiscover == null ? null : (item.enableDiscover ? 1 : 0),
                  'discoverUrl': item.discoverUrl,
                  'discoverNextUrl': item.discoverNextUrl,
                  'discoverItems': item.discoverItems,
                  'discoverList': item.discoverList,
                  'discoverTags': item.discoverTags,
                  'discoverName': item.discoverName,
                  'discoverCover': item.discoverCover,
                  'discoverAuthor': item.discoverAuthor,
                  'discoverChapter': item.discoverChapter,
                  'discoverDescription': item.discoverDescription,
                  'discoverResult': item.discoverResult,
                  'enableSearch':
                      item.enableSearch == null ? null : (item.enableSearch ? 1 : 0),
                  'searchUrl': item.searchUrl,
                  'searchNextUrl': item.searchNextUrl,
                  'searchItems': item.searchItems,
                  'searchList': item.searchList,
                  'searchTags': item.searchTags,
                  'searchName': item.searchName,
                  'searchCover': item.searchCover,
                  'searchAuthor': item.searchAuthor,
                  'searchChapter': item.searchChapter,
                  'searchDescription': item.searchDescription,
                  'searchResult': item.searchResult,
                  'enableMultiRoads': item.enableMultiRoads == null
                      ? null
                      : (item.enableMultiRoads ? 1 : 0),
                  'chapterUrl': item.chapterUrl,
                  'chapterNextUrl': item.chapterNextUrl,
                  'chapterRoads': item.chapterRoads,
                  'chapterRoadName': item.chapterRoadName,
                  'chapterItems': item.chapterItems,
                  'chapterList': item.chapterList,
                  'chapterName': item.chapterName,
                  'chapterCover': item.chapterCover,
                  'chapterLock': item.chapterLock,
                  'chapterTime': item.chapterTime,
                  'chapterResult': item.chapterResult,
                  'contentUrl': item.contentUrl,
                  'contentNextUrl': item.contentNextUrl,
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
                  'enableUpload':
                      item.enableUpload == null ? null : (item.enableUpload ? 1 : 0),
                  'author': item.author,
                  'postScript': item.postScript,
                  'name': item.name,
                  'host': item.host,
                  'icon': item.icon,
                  'contentType': item.contentType,
                  'group': item.group,
                  'sort': item.sort,
                  'viewStyle': item.viewStyle,
                  'useCryptoJS':
                      item.useCryptoJS == null ? null : (item.useCryptoJS ? 1 : 0),
                  'loadJs': item.loadJs,
                  'userAgent': item.userAgent,
                  'loginUrl': item.loginUrl,
                  'cookies': item.cookies,
                  'enableDiscover':
                      item.enableDiscover == null ? null : (item.enableDiscover ? 1 : 0),
                  'discoverUrl': item.discoverUrl,
                  'discoverNextUrl': item.discoverNextUrl,
                  'discoverItems': item.discoverItems,
                  'discoverList': item.discoverList,
                  'discoverTags': item.discoverTags,
                  'discoverName': item.discoverName,
                  'discoverCover': item.discoverCover,
                  'discoverAuthor': item.discoverAuthor,
                  'discoverChapter': item.discoverChapter,
                  'discoverDescription': item.discoverDescription,
                  'discoverResult': item.discoverResult,
                  'enableSearch':
                      item.enableSearch == null ? null : (item.enableSearch ? 1 : 0),
                  'searchUrl': item.searchUrl,
                  'searchNextUrl': item.searchNextUrl,
                  'searchItems': item.searchItems,
                  'searchList': item.searchList,
                  'searchTags': item.searchTags,
                  'searchName': item.searchName,
                  'searchCover': item.searchCover,
                  'searchAuthor': item.searchAuthor,
                  'searchChapter': item.searchChapter,
                  'searchDescription': item.searchDescription,
                  'searchResult': item.searchResult,
                  'enableMultiRoads': item.enableMultiRoads == null
                      ? null
                      : (item.enableMultiRoads ? 1 : 0),
                  'chapterUrl': item.chapterUrl,
                  'chapterNextUrl': item.chapterNextUrl,
                  'chapterRoads': item.chapterRoads,
                  'chapterRoadName': item.chapterRoadName,
                  'chapterItems': item.chapterItems,
                  'chapterList': item.chapterList,
                  'chapterName': item.chapterName,
                  'chapterCover': item.chapterCover,
                  'chapterLock': item.chapterLock,
                  'chapterTime': item.chapterTime,
                  'chapterResult': item.chapterResult,
                  'contentUrl': item.contentUrl,
                  'contentNextUrl': item.contentNextUrl,
                  'contentItems': item.contentItems
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _ruleMapper = (Map<String, dynamic> row) => Rule(
        row['id'],
        row['createTime'],
        row['modifiedTime'],
        row['enableUpload'] as int != 0,
        row['author'],
        row['name'],
        row['host'],
        row['icon'],
        row['group'],
        row['postScript'],
        row['contentType'],
        row['sort'],
        row['viewStyle'],
        row['useCryptoJS'] as int != 0,
        row['loadJs'],
        row['userAgent'],
        row['loginUrl'],
        row['cookies'],
        row['enableDiscover'] as int != 0,
        row['discoverUrl'],
        row['discoverNextUrl'],
        row['discoverItems'],
        row['discoverList'],
        row['discoverTags'],
        row['discoverName'],
        row['discoverCover'],
        row['discoverAuthor'],
        row['discoverChapter'],
        row['discoverDescription'],
        row['discoverResult'],
        row['enableSearch'] as int != 0,
        row['searchUrl'],
        row['searchNextUrl'],
        row['searchItems'],
        row['searchList'],
        row['searchTags'],
        row['searchName'],
        row['searchCover'],
        row['searchAuthor'],
        row['searchChapter'],
        row['searchDescription'],
        row['searchResult'],
        row['enableMultiRoads'] as int != 0,
        row['chapterUrl'],
        row['chapterNextUrl'],
        row['chapterRoads'],
        row['chapterRoadName'],
        row['chapterItems'],
        row['chapterList'],
        row['chapterName'],
        row['chapterCover'],
        row['chapterLock'],
        row['chapterTime'],
        row['chapterResult'],
        row['contentUrl'],
        row['contentNextUrl'],
        row['contentItems'],
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
    return _queryAdapter.queryList('SELECT * FROM rule ORDER BY ${RuleDao.order}',
        mapper: _ruleMapper);
  }

  @override
  Future<List<Rule>> findAllDiscoverRules() async {
    return _queryAdapter.queryList(
        'SELECT * FROM rule where enableDiscover = 1 ORDER BY ${RuleDao.order}',
        mapper: _ruleMapper);
  }

  @override
  Future<List<Rule>> findUploadRules() async {
    return _queryAdapter.queryList('SELECT * FROM rule where enableUpload = 1',
        mapper: _ruleMapper);
  }

  @override
  Future<Rule> findMaxSort() async {
    return _queryAdapter.query('SELECT * FROM rule order by sort desc limit 1',
        mapper: _ruleMapper);
  }

  @override
  Future<void> clearAllRules() async {
    await _queryAdapter.queryNoReturn('DELETE FROM rule');
  }

  @override
  Future<List<Rule>> getRuleByName(String name) async {
    return _queryAdapter.queryList(
        'SELECT * FROM rule WHERE name like ? or `group` like ? or author like ? or host like ? ORDER BY ${RuleDao.order}',
        arguments: <dynamic>[name, name, name, name],
        mapper: _ruleMapper);
  }

  @override
  Future<List<Rule>> getDiscoverRuleByName(String name) async {
    return _queryAdapter.queryList(
        'SELECT * FROM rule WHERE enableDiscover = 1 and (name like ? or `group` like ? or author like ? or host like ?) ORDER BY ${RuleDao.order}',
        arguments: <dynamic>[name, name, name, name],
        mapper: _ruleMapper);
  }

  @override
  Future<int> insertOrUpdateRule(Rule rule) {
    return _ruleInsertionAdapter.insertAndReturnId(rule, OnConflictStrategy.replace);
  }

  @override
  Future<List<int>> insertOrUpdateRules(List<Rule> rules) {
    return _ruleInsertionAdapter.insertListAndReturnIds(
        rules, OnConflictStrategy.replace);
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
