import 'dart:async';

import 'package:eso/database/rule.dart';
import 'package:eso/evnts/restore_event.dart';
import 'package:eso/global.dart';
import 'package:eso/menu/menu_edit_source.dart';
import 'package:eso/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditSourceProvider with ChangeNotifier {
  List<Rule> _rulesFilter;
  List<Rule> _rules;
  final int type;

  final Map<String, bool> checkSelectMap = {};
  void toggleSelect(String id, [bool value]) {
    if (value == null) {
      checkSelectMap[id] = !(checkSelectMap[id] == true);
      notifyListeners();
    } else if (checkSelectMap[id] != value) {
      checkSelectMap[id] = value;
      notifyListeners();
    }
  }

  List<Rule> get rules => _ruleContentType < 0 ? _rules : _rulesFilter;
  bool _isLoading;
  bool get isLoading => _isLoading;

  bool _isLoadingUrl;
  bool get isLoadingUrl => _isLoadingUrl;

  /// 内容类型
  int _ruleContentType = -1;
  int get ruleContentType => _ruleContentType;
  set ruleContentType(v) => _setRuleContentType(v);

  EditSourceProvider({this.type = 1}) {
    _isLoadingUrl = false;
    _eventStream = eventBus.on<RestoreEvent>().listen((event) {
      refreshData();
    });
    refreshData();
  }

  _setRuleContentType(int value) {
    _ruleContentType = value;
    if (_ruleContentType < 0) {
      _rulesFilter = null;
      return;
    }
    _rulesFilter = [];
    if (_rules == null) return;
    _rules.forEach((element) {
      if (element.contentType == value) _rulesFilter.add(element);
    });
  }

  //获取源列表 1所有 2发现
  void refreshData([bool reFindAllRules = true]) async {
    if (!reFindAllRules) {
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 100));
    switch (this.type) {
      case 1:
        _rules = await Global.ruleDao.findAllRules();
        break;
      case 2:
        _rules = await Global.ruleDao.findAllDiscoverRules();
        break;
    }
    _isLoading = false;
    _setRuleContentType(_ruleContentType);
    notifyListeners();
  }

  ///启用、禁用
  void toggleEnableSearch(Rule rule, MenuEditSource type) async {
    if (_isLoading) return;
    switch (type) {
      case MenuEditSource.enable_search:
        rule.enableSearch = true;
        break;
      case MenuEditSource.disable_search:
        rule.enableSearch = false;
        break;
      case MenuEditSource.enable_discover:
        rule.enableDiscover = true;
        break;
      case MenuEditSource.disable_discover:
        rule.enableDiscover = false;
        break;
      default:
        return;
    }
    _isLoading = true;
    await Global.ruleDao.insertOrUpdateRule(rule);
    _isLoading = false;
    notifyListeners();
  }

  void handleSelect(List<Rule> rules, MenuEditSource type) async {
    if (_isLoading) return;
    bool updateFlag = false;
    switch (type) {
      case MenuEditSource.all:
        _rules.forEach((rule) => checkSelectMap[rule.id] = true);
        break;
      case MenuEditSource.revert:
        final ids = _rules
            .where((rule) => checkSelectMap[rule.id] != true)
            .map((rule) => rule.id);
        checkSelectMap.clear();
        ids.forEach((id) => checkSelectMap[id] = true);
        break;
      case MenuEditSource.top:
        int maxSort = (await Global.ruleDao.findMaxSort()).sort + 1;
        rules.forEach((rule) => rule.sort = maxSort++);
        updateFlag = true;
        break;
      case MenuEditSource.enable_search:
        rules.forEach((rule) => rule.enableSearch = true);
        updateFlag = true;
        break;
      case MenuEditSource.disable_search:
        rules.forEach((rule) => rule.enableSearch = false);
        updateFlag = true;
        break;
      case MenuEditSource.enable_discover:
        rules.forEach((rule) => rule.enableDiscover = true);
        updateFlag = true;
        break;
      case MenuEditSource.disable_discover:
        rules.forEach((rule) => rule.enableDiscover = false);
        updateFlag = true;
        break;
    }
    if (updateFlag) {
      _isLoading = true;
      await Global.ruleDao.insertOrUpdateRules(rules);
      _isLoading = false;
    }
    if (type != MenuEditSource.add_group && type != MenuEditSource.delete_group)
      notifyListeners();
  }

  ///删除规则
  void deleteRule(Rule rule) async {
    if (_isLoading) return;
    _isLoading = true;
    _rules.remove(rule);
    await Global.ruleDao.deleteRule(rule);
    notifyListeners();
    _isLoading = false;
  }

  ///清空源
  void deleteRules(List<Rule> rules) async {
    if (_isLoading) return;
    _isLoading = true;
    _rules.clear();
    await Global.ruleDao.deleteRules(rules);
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

  DateTime _loadTime = DateTime.now();
  bool _lockDataBase = false;
  void getRuleListByNameDebounce(String name) {
    if (_lockDataBase) return;
    _loadTime = DateTime.now();
    Future.delayed(const Duration(milliseconds: 200), () async {
      if (DateTime.now().difference(_loadTime).inMilliseconds > 200) {
        await getRuleListByName(name);
      }
    });
  }

  ///搜索
  Future<void> getRuleListByName(String name) async {
    if (_lockDataBase) return;
    _lockDataBase = true;
    print("读取数据库");
    switch (this.type) {
      case 1:
        _rules = await Global.ruleDao.getRuleByName('%$name%', '%$name%');
        break;
      case 2:
        _rules = await Global.ruleDao.getDiscoverRuleByName('%$name%', '%$name%');
        break;
    }
    _lockDataBase = false;
    _setRuleContentType(_ruleContentType);
    notifyListeners();
  }

  ///全选
  Future<void> toggleCheckAllRule() async {
    //循环处理（如果有未勾选则全选 没有则全不选）
    int _enCheck = _rules.indexWhere((e) => (!e.enableSearch), 0);
    _rules.forEach((rule) {
      rule.enableSearch = !(_enCheck < 0);
    });
    notifyListeners();
    //保存到数据库
    await Global.ruleDao.insertOrUpdateRules(_rules);
  }

  ///全选
  Future<void> toggleCheckAllRuleDiscover() async {
    //循环处理（如果有未勾选则全选 没有则全不选）
    int _enCheck = _rules.indexWhere((e) => (!e.enableDiscover), 0);
    _rules.forEach((rule) {
      rule.enableDiscover = !(_enCheck < 0);
    });
    notifyListeners();
    //保存到数据库
    await Global.ruleDao.insertOrUpdateRules(_rules);
  }

  StreamSubscription _eventStream;

  @override
  void dispose() {
    _rules.clear();
    _eventStream.cancel();
    checkSelectMap.clear();
    super.dispose();
  }
}
