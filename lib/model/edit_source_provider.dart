import 'dart:async';

import 'package:eso/database/rule.dart';
import 'package:eso/database/rule_dao.dart';
import 'package:eso/global.dart';
import 'package:eso/menu/menu_edit_source.dart';
import 'package:eso/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    _isLoading = false;
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
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 100));
    await RuleDao.gaixieguizheng();
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

  void handleSelect(List<Rule> rules, MenuEditSource type,
      {int index, String group}) async {
    if (_isLoading) return;
    if (type != MenuEditSource.all && (rules == null || rules.isEmpty)) return;
    bool updateFlag = false;
    switch (type) {
      case MenuEditSource.enable_upload:
        rules.forEach((rule) => rule.enableUpload = true);
        updateFlag = true;
        break;
      case MenuEditSource.disable_upload:
        rules.forEach((rule) => rule.enableUpload = false);
        updateFlag = true;
        break;
      case MenuEditSource.all:
        _rules.forEach((rule) => checkSelectMap[rule.id] = true);
        updateFlag = true;
        break;
      case MenuEditSource.revert:
        final ids = _rules
            .where((rule) => checkSelectMap[rule.id] != true)
            .map((rule) => rule.id)
            .toList();
        checkSelectMap.clear();
        ids.forEach((id) => checkSelectMap[id] = true);
        break;
      case MenuEditSource.top:
        int maxSort = (await Global.ruleDao.findMaxSort()).sort + 1;
        rules.reversed.forEach((rule) => rule.sort = maxSort++);
        rules.addAll(_rules.where((rule) => checkSelectMap[rule.id] != true));
        _rules.clear();
        _rules = rules;
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
      case MenuEditSource.add_group:
        if (group.trim().isEmpty) return;
        rules.forEach((rule) => rule.group += " " + group);
        updateFlag = true;
        break;
      case MenuEditSource.delete_group:
        if (group.trim().isEmpty) return;
        rules.forEach((rule) => rule.group = rule.group.replaceFirst(group, ""));
        updateFlag = true;
        break;
      case MenuEditSource.delete:
        _rules.removeWhere((rule) => checkSelectMap[rule.id] == true);
        _isLoading = true;
        await Global.ruleDao.deleteRules(rules);
        _isLoading = false;
        notifyListeners();
        return;
      case MenuEditSource.delete_this:
        final rule = rules.first;
        _rules.remove(rule);
        _isLoading = true;
        await Global.ruleDao.deleteRule(rule);
        _isLoading = false;
        notifyListeners();
        return;
      case MenuEditSource.replica:
        final rule = rules.first.replica();
        _rules.insert(index + 1, rule);
        _isLoading = true;
        await Global.ruleDao.insertOrUpdateRule(rule);
        _isLoading = false;
        notifyListeners();
        return;
      default:
        return;
    }
    try {
      if (updateFlag) {
        _isLoading = true;
        print('edit source update database');
        await Global.ruleDao.insertOrUpdateRules(rules);
        _isLoading = false;
      }
      if (type != MenuEditSource.add_group && type != MenuEditSource.delete_group)
        notifyListeners();
    } catch (e) {
      _isLoading = false;
      Utils.toast(e);
    }
  }

  DateTime _loadKey = DateTime.now();
  String _searchName;
  void getRuleListByNameDebounce(String name) {
    _loadKey = DateTime.now();
    _searchName = name;
    if (_isLoading) return;
    (DateTime loadKey) {
      Future.delayed(const Duration(milliseconds: 200), () async {
        if (loadKey == _loadKey) {
          await getRuleListByName(_searchName);
        }
      });
    }(_loadKey);
  }

  static final linyuan = "临渊";
  static final leshi = "乐事";
  static final schulte_grid = "舒尔特方格";
  static final unlock_hidden_functions = "unlock_hidden_functions";

  ///搜索
  Future<void> getRuleListByName(String name) async {
    if (_isLoading) return;
    _isLoading = true;
    print("读取数据库 %$name%");
    // final list = [linyuan, leshi, schulte_grid];
    final list = [linyuan, schulte_grid];
    if (name.startsWith("开启功能") ||
        name.startsWith("启用功能") ||
        name.startsWith("打开功能") ||
        name.startsWith("使用功能")) {
      final keyword = name.substring(4);
      final box = Hive.box<int>(unlock_hidden_functions);
      if (list.contains(keyword)) {
        if (box.get(keyword, defaultValue: 0) == 1) {
          Utils.toast("$keyword 功能已启用，无需重复输入");
        } else {
          box.put(keyword, 1);
          Utils.toast("$keyword 功能启用成功");
        }
      }
    } else if (name.startsWith("关闭功能")) {
      final keyword = name.substring(4);
      final box = Hive.box<int>(unlock_hidden_functions);
      if (list.contains(keyword)) {
        if (box.get(keyword, defaultValue: 1) == 0) {
          Utils.toast("$keyword 功能无需关闭");
        } else {
          box.put(keyword, 0);
          Utils.toast("$keyword 功能关闭成功");
        }
      }
    }
    switch (this.type) {
      case 1:
        _rules = await Global.ruleDao.getRuleByName('%$name%');
        break;
      case 2:
        _rules = await Global.ruleDao.getDiscoverRuleByName('%$name%');
        break;
    }
    _setRuleContentType(_ruleContentType);
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _rules?.clear();
    checkSelectMap?.clear();
    super.dispose();
  }
}
