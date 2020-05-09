import 'package:eso/database/rule.dart';
import 'package:eso/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditSourceProvider with ChangeNotifier {
  List<Rule> _rules;
  List<Rule> get rules => _rules;
  bool _isLoading;
  bool get isLoading => _isLoading;

  EditSourceProvider() {
    _isLoading = true;
    refreshData();
  }

  void refreshData() async {
    _rules = await Global.ruleDao.findAllRules();
    _isLoading = false;
    notifyListeners();
  }

  ///启用、禁用
  void toggleEnableSearch(Rule rule, [bool enable]) async {
    if (_isLoading) return;
    _isLoading = true;
    rule.enableSearch = enable ?? !rule.enableSearch;
    await Global.ruleDao.insertOrUpdateRule(rule);
    notifyListeners();
    _isLoading = false;
  }

  ///删除规则
  void deleteRule(Rule rule) async {
    if (_isLoading) return;
    _isLoading = true;
    await Global.ruleDao.deleteRule(rule);
    notifyListeners();
    _isLoading = false;
  }

  void deleteAllRules() async {
    if (_isLoading) return;
    _isLoading = true;
    await Global.ruleDao.clearAllRules();
    notifyListeners();
    _isLoading = false;
  }

  ///置顶
  void setSortMax(Rule rule) async {
    if (_isLoading) return;
    _isLoading = true;

    Rule maxSort = await Global.ruleDao.findMaxSort();
    rule.sort = maxSort.sort + 1;
    //更换顺序
    _rules.remove(rule);
    _rules.insert(0, rule);
    //保存到数据库
    await Global.ruleDao.insertOrUpdateRule(rule);
    notifyListeners();
    _isLoading = false;
  }

  ///搜索
  void getRuleListByName(String name) async {

    _rules = await Global.ruleDao.getRuleByName('%$name%');
    notifyListeners();
  }

  ///全选
  Future<void> toggleCheckAllRule() async {
    //循环处理（如果有未勾选则全选 没有则全不选）
    int _enCheck = _rules.indexWhere((e)=>(!e.enableSearch),0);
    _rules.forEach((rule){
      if (_enCheck>=0) rule.enableSearch = true;
      else rule.enableSearch = false;
    });
    notifyListeners();
    //保存到数据库
    await Global.ruleDao.insertOrUpdateRules(_rules);
  }

  @override
  void dispose() {
    _rules.clear();
    super.dispose();
  }
}
