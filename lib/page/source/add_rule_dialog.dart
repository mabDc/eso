import 'dart:convert';

import 'package:eso/utils.dart';
import 'package:eso/utils/rule_comparess.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../global.dart';

Future addRuleDialog(BuildContext context, VoidCallback refresh) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => Dialog(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: _AddRule(refresh: refresh),
    )),
  );
}

class _AddRule extends StatelessWidget {
  final VoidCallback refresh;
  const _AddRule({
    Key key,
    this.refresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddRuleProvider>(
        create: (_) => AddRuleProvider(refresh),
        builder: (context, child) {
          final importText =
              context.select((AddRuleProvider provider) => provider.importText);
          final provider = Provider.of<AddRuleProvider>(context, listen: false);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 10,
                children: [
                  OutlinedButton(
                    child: Text("[未选择文件]"),
                    onPressed: null,
                  ),
                  Text(
                    '0/0',
                    style: TextStyle(height: 1.5),
                  ),
                  OutlinedButton(
                    child: Text("前一个"),
                    onPressed: null,
                  ),
                  OutlinedButton(
                    child: Text("后一个"),
                    onPressed: null,
                  ),
                ],
              ),
              TextField(
                controller: provider.ruleController,
                minLines: 1,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: "填入规则(eso://)或网址(http[s]://)或预览规则文件",
                ),
              ),
              Wrap(
                spacing: 16,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    child: Text("取消"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  OutlinedButton(
                    child: Text("清空"),
                    onPressed: provider.clear,
                  ),
                  OutlinedButton(
                    child: Text("格式化"),
                    onPressed: provider.stringify,
                  ),
                  OutlinedButton(
                    child: Text(importText),
                    onPressed: null,
                  ),
                ],
              )
            ],
          );
        });
  }
}

enum ImportType { error, http, eso, file }

class AddRuleProvider extends ChangeNotifier {
  @override
  void dispose() {
    ruleController
      ..removeListener(ruleListener)
      ..dispose();
    super.dispose();
  }

  final TextEditingController ruleController = TextEditingController();
  final VoidCallback refresh;

  String _fileName = '[未选择文件]';
  String _fileContent = '';
  String get fileName => _fileName;
  int _currentFileIndex = 0;
  int get currentFileIndex => _currentFileIndex;
  int _totalFileIndex = 0;
  int get totalFileIndex => _totalFileIndex;

  String _importText = "格式不符";
  String get importText => _importText;
  ImportType _importType;

  final httpStart = RegExp("https?://", caseSensitive: false);
  final esoStart = RuleCompress.tag;
  final jsonStart = RegExp("\\[|\\{");
  void ruleListener() {
    if (_importType == ImportType.file) return;
    final s = ruleController.text.trim();
    ImportType importType = ImportType.error;
    if (s.startsWith(httpStart)) {
      importType = ImportType.http;
    } else if (s.startsWith(esoStart)) {
      try {
        final ds = RuleCompress.decompassString(s);
        ruleController.text = prettyJson(ds);
        importType = ImportType.eso;
      } catch (e) {
        Utils.toast("eso://内容格式不对");
      }
    } else if (s.startsWith(jsonStart)) {
      importType = ImportType.eso;
    }
    if (importType != _importType) {
      _importType = importType;
      final import = const [
        "格式不符", //0
        "导入网址", //1
        "添加规则", //2
        "导入文件", //3
      ];
      _importText = import[_importType.index];
      notifyListeners();
    }
  }

  AddRuleProvider(this.refresh) {
    ruleController.addListener(ruleListener);
  }

  void clear() {
    _importType = ImportType.error;
    _fileName = '[未选择文件]';
    _fileContent = '';
    _currentFileIndex = 0;
    _totalFileIndex = 0;
    ruleController.clear();
  }

  String prettyJson(String s) => JsonEncoder.withIndent("  ").convert(jsonDecode(s));

  void stringify() {
    final s = ruleController.text.trim();
    if (s.startsWith("[") || s.startsWith("{")) {
      try {
        ruleController.text = prettyJson(s);
      } catch (e) {
        Utils.toast("json格式不对");
      }
    } else {
      Utils.toast("只能格式化json");
    }
  }

  void import() {
    if (_importType == ImportType.eso) {
      insertOrUpdateRule(ruleController.text);
    } else if (_importType == ImportType.file) {
      insertOrUpdateRule(_fileContent);
    } else if (_importType == ImportType.http) {
      () async {
        final res = await http.get("${ruleController.text.trim()}", headers: {
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36'
        });
        insertOrUpdateRule(utf8.decode(res.bodyBytes));
      }();
    }
  }

  void selectFile(){
    
  }

  void insertOrUpdateRule(String s) {
    final json = jsonDecode(s.trim());
    if (json is Map) {
      final id = await Global.ruleDao.insertOrUpdateRule(
          isFromYICIYUAN ? Rule.fromYiCiYuan(json) : Rule.fromJson(json));
      if (id != null) {
        _isLoadingUrl = false;
        refreshData();
        return 1;
      }
    } else if (json is List) {
      final ids = await Global.ruleDao.insertOrUpdateRules(json
          .map((rule) => isFromYICIYUAN ? Rule.fromYiCiYuan(rule) : Rule.fromJson(rule))
          .toList());
      if (ids.length > 0) {
        _isLoadingUrl = false;
        refreshData();
        return ids.length;
      }
    }
  }
}
