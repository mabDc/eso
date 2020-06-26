import 'rule.dart';
import 'package:floor/floor.dart';

@dao
abstract class RuleDao {
  @Query('SELECT * FROM rule WHERE id = :id')
  Future<Rule> findRuleById(String id);

  @Query('SELECT * FROM rule ORDER BY sort desc')
  Future<List<Rule>> findAllRules();

  @Query('SELECT * FROM rule where enableDiscover = 1 ORDER BY sort desc')
  Future<List<Rule>> findAllDiscoverRules();

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
      'SELECT * FROM rule WHERE name like :name or `group` like :name ORDER BY sort desc')
  Future<List<Rule>> getRuleByName(String name);

  @Query(
    'SELECT * FROM rule WHERE enableDiscover = 1 and (name like :name or `group` like :name) ORDER BY sort desc')
  Future<List<Rule>> getDiscoverRuleByName(String name);
}
