import 'dart:convert';

import 'package:eso/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  String _importText = "格式不符";
  String get importText => _importText;
  ImportType _importType;

  final httpStart = RegExp("https?://", caseSensitive: false);
  final esoStart = RegExp("\\[|\\{|eso://");
  void ruleListener() {
    if (_importType == ImportType.file) return;
    final s = ruleController.text.trim();
    ImportType importType = ImportType.error;
    if (s.startsWith(httpStart)) {
      importType = ImportType.http;
    } else if (s.startsWith(esoStart)) {
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

  void clear() => ruleController.clear();

  void stringify() {
    final s = ruleController.text.trim();
    if (s.startsWith("[") || s.startsWith("{")) {
      ruleController.text = JsonEncoder.withIndent("  ").convert(jsonDecode(s));
    } else {
      Utils.toast("格式化必须是json");
    }
  }
}
