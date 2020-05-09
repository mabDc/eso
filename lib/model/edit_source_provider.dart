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
    _isLoading = false;
    compute(_initContent, null);
  }

  void _initContent(_) async {
    _rules = await Global.ruleDao.findAllRules();
    notifyListeners();
  }

  void toggleEnableSearch(Rule rule, [bool enable]) async {
    if (_isLoading) return;
    _isLoading = true;
    rule.enableSearch = enable ?? !rule.enableSearch;
    await Global.ruleDao.insertOrUpdateRule(rule);
    notifyListeners();
    _isLoading = false;
  }

  void deleteRule(Rule rule) async {
    if (_isLoading) return;
    _isLoading = true;
    await Global.ruleDao.deleteRule(rule);
    notifyListeners();
    _isLoading = false;
  }

  void setSortMax(Rule rule) async {
    if (_isLoading) return;
    _isLoading = true;
    Rule maxSort = await Global.ruleDao.findMaxSort();
    rule.sort = maxSort.sort + 1;
    await Global.ruleDao.insertOrUpdateRule(rule);
    notifyListeners();
    _isLoading = false;
  }

  @override
  void dispose() {
    _rules.clear();
    super.dispose();
  }
}
