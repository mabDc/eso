import 'dart:async';
import 'dart:convert';

// import 'package:cupertino_lists/cupertino_lists.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/rule_dao.dart';
import 'package:eso/global.dart';
import 'package:eso/menu/menu_edit_source.dart';
import 'package:eso/profile.dart';
import 'package:eso/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

Widget buildEndDrawer(BuildContext context, EditSourceProvider provider,
    {bool isAll = false}) {
  List<Rule> ruleGroup = provider.allRules
      ?.where((element) =>
          !Utils.empty(element.group?.trim() ?? '') &&
          (isAll ? true : element.enableDiscover))
      ?.toList();

  Set<String> groupName = ruleGroup?.map((e) => e.group)?.toSet();
  groupName.add('未分组');

  List<Widget> group = groupName == null
      ? []
      : List.generate(
          groupName?.length,
          (index) => Container(
            decoration: BoxDecoration(
              border: Border(
                top: index == 0 ? BorderSide(width: 0.1) : BorderSide.none,
                bottom: BorderSide(width: 0.1),
              ),
            ),
            child: CupertinoListTile(
              title: Text(groupName.elementAt(index)),
              trailing: provider.groupFilter
                      .contains(groupName.elementAt(index).trim())
                  ? Icon(CupertinoIcons.checkmark_alt)
                  : null,
              onTap: () {
                provider.setShowGroup(groupName.elementAt(index).trim());
              },
            ),
          ),
        );

  return Drawer(
    child: SafeArea(
      child: Container(
        // padding: EdgeInsets.only(
        //     top: MediaQuery.of(context).padding.top, bottom: 20),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: 5, bottom: 5),
              width: double.infinity,
              color: CupertinoTheme.of(context).scaffoldBackgroundColor,
              height: 35,
              child: Text(
                "分组筛选",
                style: CupertinoTheme.of(context)
                    .textTheme
                    .textStyle
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
                child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [...group],
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    ),
  );
}

class EditSourceProvider with ChangeNotifier {
  List<Rule> _rulesFilter;
  List<Rule> _rules;
  List<Rule> _allRules = [];
  List<Rule> get allRules => _allRules;

  final int type;

  final Map<String, bool> checkSelectMap = {};
  Set<String> _groupFilter = Set();
  Set<String> get groupFilter => _groupFilter;

  void toggleSelect(String id, [bool value]) {
    if (value == null) {
      checkSelectMap[id] = !(checkSelectMap[id] == true);
      notifyListeners();
    } else if (checkSelectMap[id] != value) {
      checkSelectMap[id] = value;
      notifyListeners();
    }
  }

  List<Rule> get rules => _groupFilter.length <= 0 ? _rules : _rulesFilter;
  bool _isLoading;
  bool get isLoading => _isLoading;

  bool _isLoadingUrl;
  bool get isLoadingUrl => _isLoadingUrl;

  int _updateList = 0;
  int get updateList => _updateList;

  /// 内容类型
  int _ruleContentType = -1;
  int get ruleContentType => _ruleContentType;
  set ruleContentType(int value) {
    if (value != _ruleContentType) {
      _ruleContentType = value;
      notifyListeners();
    }
  }
  // set ruleContentType(v) => _setRuleContentType(v);

  EditSourceProvider({this.type = 1}) {
    _isLoadingUrl = false;
    _isLoading = false;
    refreshData();
  }
  setShowGroup(String name) {
    print("name:${name}");
    // 判断是否存在分组名
    if (name != null) {
      if (_groupFilter.contains(name)) {
        // 存在分组.删除
        // print("存在分组,删除");
        _groupFilter.removeWhere((element) => element == name);
      } else {
        // 不存在分组.添加
        // print("不存在分组,添加");
        _groupFilter.add(name);
      }
    }

    _rulesFilter = _groupFilter?.length == 0 ?? 0 ? List.from(_allRules) : [];

    _allRules?.forEach((element) {
      if (_groupFilter.contains(element.group.trim()) ||
          _groupFilter.contains('未分组')) {
        _rulesFilter?.add(element);
      }
    });

    Profile().ruleGroupFilter = jsonEncode(_groupFilter?.toList());

    print("ruleGroupFilter:${Profile().ruleGroupFilter}");
    print("_rulesFilter:${_rulesFilter.length}");

    notifyListeners();
  }

  // _setRuleContentType(int value) {
  //   _ruleContentType = value;
  //   if (_ruleContentType < 0) {
  //     _rulesFilter = null;
  //     return;
  //   }
  //   _rulesFilter = [];
  //   if (_rules == null) return;
  //   _rules.forEach((element) {
  //     if (element.contentType == value) _rulesFilter.add(element);
  //   });

  //   //print("_rulesFilter:${_rulesFilter.length},_rules:${_rules.length}");
  // }

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
    _allRules = List.from(_rules);
    try {
      print("Profile().ruleGroupFilter:${Profile().ruleGroupFilter}");
      var res = jsonDecode(Profile().ruleGroupFilter);

      if (res is List) {
        _groupFilter.addAll(res.cast<String>());
        // final groups = _allRules.map((e) => e.group.trim()).toList();
        // _groupFilter.forEach((element) {
        //   if (!groups.contains(element)) {
        //   }
        // });
        //  _groupFilter.removeWhere(null);

        print("_groupFilter:${_groupFilter}");
        setShowGroup(null);
      }
    } catch (e) {
      print("e:${e}");
    }

    _isLoading = false;
    // _setRuleContentType(_ruleContentType);
    notifyListeners();
  }

  void handleSelect(List<Rule> rules, MenuEditSource type,
      [String group]) async {
    if (_isLoading) return;
    if (type != MenuEditSource.all && (rules == null || rules.isEmpty)) return;
    bool updateFlag = false;
    switch (type) {
      case MenuEditSource.save:
        print("保存:${rules.first.name},${rules.first.enableDiscover}");

        final index =
            _rules.indexWhere((element) => element.id == rules.first.id);
        // 是否为新建规则
        final rulef = Rule.fromJson(rules.first.toJson());
        if (index == -1) {
          _rules.add(rulef);
          _allRules.add(rulef);
        } else {
          // 深拷贝
          _rules[index] = rulef;
          _allRules[index] = rulef;
          print("深拷贝name:${_rules[index].name}");
        }
        setShowGroup(null);
        updateFlag = true;
        break;
      case MenuEditSource.fuben:
        final copyRule = Rule.fromJson(rules.first.toJson());
        copyRule.id = Uuid().v4();
        copyRule.name = "${copyRule.name}-${DateTime.now().millisecond}";
        copyRule.createTime = DateTime.now().microsecondsSinceEpoch;
        copyRule.modifiedTime = DateTime.now().microsecondsSinceEpoch;
        rules.clear();
        rules.add(copyRule);
        _rules.add(copyRule);
        _allRules.add(copyRule);
        setShowGroup(null);
        updateFlag = true;
        break;
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

        print("maxSort:${maxSort}");
        rules.reversed.forEach((rule) => rule.sort = maxSort++);

        rules.addAll(_allRules.where((rule) {
          return checkSelectMap.length == 0
              ? rules.first.id != rule.id
              : checkSelectMap[rule.id] != true;
        }));

        // _rules.clear();
        _rules = rules;
        _allRules = rules;
        setShowGroup(null);

        updateFlag = true;
        break;
      case MenuEditSource.down:
        rules.reversed.forEach((rule) => rule.sort = 1);
        // print("checkSelectMap.length:${checkSelectMap.length}");
        rules.addAll(_rules.where((rule) {
          return checkSelectMap.length == 0
              ? rules.first.id != rule.id
              : checkSelectMap[rule.id] != true;
        }));
        rules.sort(((a, b) => a.sort.compareTo(b.sort)));
        _rules.clear();
        _rules = rules.reversed.toList();
        _allRules = _rules;
        setShowGroup(null);
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
        rules.forEach((rule) {
          Set<String> groups = rule.group.split(',')?.toSet() ?? Set();
          if (groups.length <= 0 || !groups.contains(group)) {
            groups.add(group);
            groups.removeWhere((element) => element.isEmpty);
            rule.group = groups.join(',');
            print("rule.group:${rule.group}");
            _rules.forEach((element) {
              if (element.id == rule.id) {
                element.group = rule.group;
              }
            });
            _allRules.forEach((element) {
              if (element.id == rule.id) {
                element.group = rule.group;
              }
            });
          }
        });

        updateFlag = true;
        break;
      case MenuEditSource.delete_group:
        if (group.trim().isEmpty) return;
        // 取出需要移除的分组
        Set<String> removeGroups = group.split(',')?.toSet() ?? Set();
        if (removeGroups.length <= 0) return;

        rules.forEach((rule) {
          // 取出当前规则所有分组
          Set<String> groups = rule.group.split(',')?.toSet() ?? Set();
          // 移除包含的分组
          groups.removeWhere((element) => removeGroups.contains(element));
          rule.group = groups.join(',');

          _rules.forEach((element) {
            if (element.id == rule.id) {
              element.group = rule.group;
            }
          });
          _allRules.forEach((element) {
            if (element.id == rule.id) {
              element.group = rule.group;
            }
          });
        });

        // _allRules.where((element) => removeGroups.contains(element));

        // _groupFilter.removeWhere((element) => element == group);
        setShowGroup(null);

        updateFlag = true;

        break;
      case MenuEditSource.delete:
        _rules.removeWhere((rule) => checkSelectMap[rule.id] == true);
        _allRules.removeWhere((rule) => checkSelectMap[rule.id] == true);

        _isLoading = true;
        await Global.ruleDao.deleteRules(rules);
        _isLoading = false;

        setShowGroup(null);
        notifyListeners();
        return;
      case MenuEditSource.delete_this:
        final rule = rules.first;
        _isLoading = true;
        await Global.ruleDao.deleteRule(rule);
        _allRules.removeWhere((element) => element.id == rule.id);
        _rules.removeWhere((element) => element.id == rule.id);
        setShowGroup(null);
        print("删除:${rule.name}");
        _isLoading = false;
        notifyListeners();
        _updateList++;
        return;
      default:
        return;
    }
    try {
      if (updateFlag) {
        // _isLoading = true;
        print('edit source update database');
        final count = await Global.ruleDao.insertOrUpdateRules(rules);
        // _isLoading = false;
        _updateList++;
        if (type == MenuEditSource.save) {
          if (count.length > 0) {
            Utils.toast("保存成功");
          } else {
            Utils.toast("保存失败");
          }
        }
      }
      if (type != MenuEditSource.add_group &&
          type != MenuEditSource.delete_group) notifyListeners();
    } catch (e) {
      _isLoading = false;
      Utils.toast(e);
    }
  }

  DateTime _loadKey = DateTime.now();
  String _searchName;
  void getRuleListByNameDebounce(String name, {int type}) {
    if (type == null) type = this.type;
    _loadKey = DateTime.now();
    _searchName = name;
    if (_isLoading) return;
    (DateTime loadKey) {
      Future.delayed(const Duration(milliseconds: 200), () async {
        if (loadKey == _loadKey) {
          await getRuleListByName(_searchName, type: type);
        }
      });
    }(_loadKey);
  }

  ///搜索
  Future<void> getRuleListByName(String name, {int type}) async {
    if (type == null) type = this.type;
    if (_isLoading) return;
    _isLoading = true;
    print("读取数据库 %$name%");
    switch (type) {
      case 1:
        _rules = await Global.ruleDao.getRuleByName('%$name%');
        break;
      case 2:
        _rules = await Global.ruleDao.getDiscoverRuleByName('%$name%');
        break;
    }
    _allRules = _rules;
    setShowGroup(null);
    // _setRuleContentType(_ruleContentType);
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
