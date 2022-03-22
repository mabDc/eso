import '../global.dart';
import 'rule.dart';
import 'package:floor/floor.dart';

@dao
abstract class RuleDao {
  static String get order => "$sortName $sortOrder";
  static String sortName = sortMap["置顶"];
  static String sortOrder = desc;
  // 逆序
  static const String desc = "desc";
  // 正序
  static const String asc = "asc";

  static const sortMap = {
    "修改": "modifiedTime",
    "创建": "createTime",
    "置顶": "sort",
    "类型": "contentType",
    "名称": "name",
    "作者": "author",
    "分组": "`group`",
  };

  @Query('SELECT * FROM rule WHERE id = :id')
  Future<Rule> findRuleById(String id);

  @Query('SELECT * FROM rule ORDER BY \${RuleDao.order}')
  Future<List<Rule>> findAllRules();

  /// 改邪归正
  static Future<void> gaixieguizheng() async {
    final rules = await Global.ruleDao.findAllRules();
    final xie = rules
        .where((rule) =>
            rule.discoverUrl == "''" ||
            rule.searchUrl == "''" ||
            rule.chapterUrl == "''" ||
            rule.contentUrl == "''")
        .toList();
    if (xie.isNotEmpty) {
      await Global.ruleDao.insertOrUpdateRules(xie.map((rule) {
        if (rule.discoverUrl == "''") {
          rule.discoverUrl = "null";
        }
        if (rule.searchUrl == "''") {
          rule.searchUrl = "null";
        }
        if (rule.chapterUrl == "''") {
          rule.chapterUrl = "null";
        }
        if (rule.contentUrl == "''") {
          rule.contentUrl = "null";
        }
        return rule;
      }).toList());
    }
  }

  @Query('SELECT * FROM rule where enableDiscover = 1 ORDER BY \${RuleDao.order}')
  Future<List<Rule>> findAllDiscoverRules();

  @Query('SELECT * FROM rule where enableUpload = 1')
  Future<List<Rule>> findUploadRules();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertOrUpdateRule(Rule rule);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertOrUpdateRules(List<Rule> rules);

  @delete
  Future<int> deleteRule(Rule rule);

  @delete
  Future<int> deleteRules(List<Rule> rules);

  @Query('SELECT * FROM rule order by sort desc limit 1')
  Future<Rule> findMaxSort();

  @Query("DELETE FROM rule")
  Future<void> clearAllRules();

  @Query(
      'SELECT * FROM rule WHERE name like :name or `group` like :name or author like :name or host like :name ORDER BY \${RuleDao.order}')
  Future<List<Rule>> getRuleByName(String name);

  @Query(
      'SELECT * FROM rule WHERE enableDiscover = 1 and (name like :name or `group` like :name or author like :name or host like :name) ORDER BY \${RuleDao.order}')
  Future<List<Rule>> getDiscoverRuleByName(String name);
}
