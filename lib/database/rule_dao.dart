import 'rule.dart';
import 'package:floor/floor.dart';

@dao
abstract class RuleDao {
  @Query('SELECT * FROM rule WHERE id = :id')
  Future<Rule> findRuleById(String id);

  @Query('SELECT * FROM rule ORDER BY sort desc')
  Future<List<Rule>> findAllRules();

  @Insert(onConflict: OnConflictStrategy.REPLACE)
  Future<int> insertOrUpdateRule(Rule rule);

  @Insert(onConflict: OnConflictStrategy.REPLACE)
  Future<List<int>> insertOrUpdateRules(List<Rule> rules);

  @delete
  Future<int> deleteRule(Rule rule);

  @delete
  Future<int> deleteRules(List<Rule> rules);

  @Query('SELECT * FROM rule order by sort desc limit 1')
  Future<Rule> findMaxSort();

  @Query("DELETE FROM rule")
  Future<void> clearAllRules();

  @Query('SELECT * FROM rule WHERE name like :name or `group` like :group ORDER BY sort desc')
  Future<List<Rule>> getRuleByName(String name,String group);
}
