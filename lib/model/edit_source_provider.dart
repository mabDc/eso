import 'dart:async';

import 'package:eso/database/rule.dart';
import 'package:eso/evnts/restore_event.dart';
import 'package:eso/global.dart';
import 'package:eso/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditSourceProvider with ChangeNotifier {
  List<Rule> _rulesFilter;
  List<Rule> _rules;
  final int type;
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
  void toggleEnableSearch(Rule rule, int type) async {
    if (_isLoading) return;
    _isLoading = true;
    switch (type) {
      case ENABLE_SEARCH:
        rule.enableSearch = true;
        break;
      case DISABLE_SEARCH:
        rule.enableSearch = false;
        break;
      case ENABLE_DISCOVER:
        rule.enableDiscover = true;
        break;
      case ENABLE_DISCOVER:
        rule.enableDiscover = false;
        break;
      default:
    }
    await Global.ruleDao.insertOrUpdateRule(rule);
    _isLoading = false;
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
  void deleteAllRules() async {
    if (_isLoading) return;
    _isLoading = true;
    _rules.clear();
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

  DateTime _loadTime;
  void getRuleListByNameDebounce(String name) {
    _loadTime = DateTime.now();
    Future.delayed(const Duration(milliseconds: 301), () {
      if (DateTime.now().difference(_loadTime).inMilliseconds > 300) {
        getRuleListByName(name);
      }
    });
  }

  ///搜索
  void getRuleListByName(String name) async {
    switch (this.type) {
      case 1:
        _rules = await Global.ruleDao.getRuleByName('%$name%', '%$name%');
        break;
      case 2:
        _rules = await Global.ruleDao.getDiscoverRuleByName('%$name%', '%$name%');
        break;
    }
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
    super.dispose();
  }
}

const ENABLE_SEARCH = 0;
const DISABLE_SEARCH = 1;
const ENABLE_DISCOVER = 2;
const DISABLE_DISCOVER = 3;
const SET_TOP = 4;
const ADD_GROUP = 5;
const DELETE_GROUP = 6;
const DELETE = 7;
