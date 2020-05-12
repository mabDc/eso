import 'dart:io' show Platform;
import 'package:eso/database/rule.dart';
import 'package:eso/global.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class EditSourceProvider with ChangeNotifier {
  static const int ADD_RULE = 0;
  static const int FROM_FILE = 2;
  static const int FROM_CLOUD = 3;
  static const int FROM_YICIYUAN = 4;
  static const int DELETE_ALL_RULES = 5;
  List<Rule> _rules;

  List<Rule> get rules => _rules;
  bool _isLoading;

  bool get isLoading => _isLoading;
  var menuList = [
    {'title': '新建规则', 'icon': Icons.code, 'type': ADD_RULE},
    {'title': '从异次元链接导入', 'icon': Icons.cloud_download, 'type': FROM_YICIYUAN},
    {'title': '文件导入', 'icon': Icons.file_download, 'type': FROM_FILE},
    {'title': '网络导入', 'icon': Icons.cloud_download, 'type': FROM_CLOUD},
    {'title': '清空源', 'icon': Icons.delete_forever, 'type': DELETE_ALL_RULES},
  ];

  EditSourceProvider() {
    refreshData();
  }

  void refreshData() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 100));
    _rules = await Global.ruleDao.findAllRules();
    _isLoading = false;
    notifyListeners();
  }

  void refreshView() {
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

  ///搜索
  void getRuleListByName(String name) async {
    _rules = await Global.ruleDao.getRuleByName('%$name%');
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

  ///菜单列表
  List getMenuList() {
    //ios删除文件导入
    if (Platform.isIOS) {
      menuList.forEach((element) {
        if (element['type'] == FROM_FILE) menuList.remove(element);
      });
    }
    return menuList;
  }

  @override
  void dispose() {
    _rules.clear();
    super.dispose();
  }
}
