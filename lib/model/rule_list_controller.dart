import 'package:flutter/material.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/global.dart';

class ruleListController with ChangeNotifier {
  List<Rule> _ruleList;

  List<Rule> get ruleList => _ruleList;

  ///获取所有规则
  Future<List<Rule>> getRuleList() async {
    _ruleList = await Global.ruleDao.findAllRules();
    return _ruleList;
  }

  ///置顶
  Future<void> topRule(Rule rule) async {
    Rule maxSort = await Global.ruleDao.findMaxSort();
    rule.sort = maxSort.sort + 1;
    //更换顺序
    _ruleList.remove(rule);
    _ruleList.insert(0, rule);
    //保存到数据库
    await Global.ruleDao.insertOrUpdateRule(rule);
    notifyListeners();
  }

  ///启用、禁用
  Future<void> enableRule(Rule rule, bool enable) async {
    rule.enableSearch = enable;
    await Global.ruleDao.insertOrUpdateRule(rule);
    notifyListeners();
  }

  ///删除规则
  Future<void> deleteRule(Rule rule) async {
    await Global.ruleDao.deleteRule(rule);
    notifyListeners();
  }
}
