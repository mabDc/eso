import 'rule.dart';
import 'package:floor/floor.dart';

@dao
abstract class RuleDao {
  @Query('SELECT * FROM rule WHERE id = :id')
  Future<Rule> findRuleById(int id);

  @Query('SELECT * FROM rule')
  Future<List<Rule>> findAllRules();

  @Insert(onConflict: OnConflictStrategy.REPLACE)
  Future<void> insertOrUpdateRule(Rule rule);

  @Insert(onConflict: OnConflictStrategy.REPLACE)
  Future<void> insertOrUpdateRules(List<Rule> rules);

  @delete
  Future<void> deleteRule(Rule rule);

  @delete
  Future<void> deleteRules(List<Rule> rules);
  
}