import 'dart:convert';
import 'dart:io';

import 'package:eso/database/rule.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:eso/utils/rule_comparess.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../global.dart';
import '../utils/auto_decode_cli.dart';

class UIAddRuleDialog extends StatelessWidget {
  final VoidCallback refresh;
  final String fileContent;
  final String fileName;
  const UIAddRuleDialog({
    Key key,
    this.refresh,
    this.fileContent,
    this.fileName = "未选择文件",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(8.0),
      content: ChangeNotifierProvider<AddRuleProvider>(
          create: (context) => AddRuleProvider(
              refresh, () => Navigator.pop(context), fileContent, fileName),
          builder: (context, child) {
            final provider = Provider.of<AddRuleProvider>(context, listen: true);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // OutlinedButton(
                      //   child: Text('新建'),
                      //   onPressed: () => Navigator.of(context).pushReplacement(
                      //       MaterialPageRoute(builder: (context) => EditRulePage())),
                      // ),
                      OutlinedButton(
                        child: Text(provider.fileName),
                        onPressed: () => provider.selectFile(context),
                      ),
                      Text(
                        '${provider.currentFileIndex}/${provider.totalFileIndex}',
                      ),
                      OutlinedButton(
                        child: Text("前"),
                        onPressed: provider.pre,
                      ),
                      OutlinedButton(
                        child: Text("后"),
                        onPressed: provider.next,
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: provider.ruleController,
                  minLines: 1,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: "填入规则(eso://)或网址(http[s]://)或预览规则文件或json",
                  ),
                ),
                Container(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Wrap(
                    spacing: 12,
                    children: [
                      // OutlinedButton(
                      //   child: Text("取消"),
                      //   onPressed: () => Navigator.pop(context),
                      // ),
                      // OutlinedButton(
                      //   child: Text("新建"),
                      //   onPressed: () => Navigator.of(context).pushReplacement(
                      //       MaterialPageRoute(builder: (context) => EditRulePage())),
                      // ),
                      TextButton(
                        child: Text("重置"),
                        onPressed: provider.clear,
                      ),
                      TextButton(
                        child: Text("格式化"),
                        onPressed: provider.stringify,
                      ),
                      TextButton(
                        child: Text(provider.importText),
                        onPressed: provider.import,
                      ),
                    ],
                  ),
                )
              ],
            );
          }),
    );
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
  final VoidCallback close;

  String _fileName = '[未选择文件]';
  List _fileContent = [];
  String get fileName => _fileName;
  int _currentFileIndex = 0;
  int get currentFileIndex => _currentFileIndex;
  int _totalFileIndex = 0;
  int get totalFileIndex => _totalFileIndex;

  String _importText = "格式不对";
  String get importText => _importText;
  ImportType _importType = ImportType.error;

  final httpStart = RegExp("https?://", caseSensitive: false);
  final esoStart = RuleCompress.tag;
  final jsonStart = RegExp("\\[|\\{");
  void ruleListener() {
    var compare = true;
    if (_importType == ImportType.file) {
      _importText = '导入文件';
      compare = false;
      // return;
    }
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
    } else if (s.startsWith('"' + esoStart)) {
      try {
        final ds = RuleCompress.decompassString(jsonDecode(s));
        ruleController.text = prettyJson(ds);
        importType = ImportType.eso;
      } catch (e) {
        Utils.toast("eso://内容格式不对");
      }
    } else if (s.startsWith(jsonStart)) {
      importType = ImportType.eso;
    } else if (s.contains("https://netcut.cn")) {
      _importType = ImportType.error;
      Utils.toast("下版本支持直接导入https://netcut.cn");
    }
    if (compare && importType != _importType) {
      _importType = importType;
      final import = const [
        "格式不对", //0
        "导入网址", //1
        "添加规则", //2
        "导入文件", //3
      ];
      _importText = import[_importType.index];
      notifyListeners();
    }
  }

  AddRuleProvider(this.refresh, this.close, String fileContent, String fileName) {
    ruleController.addListener(ruleListener);
    if (fileContent != null) {
      _fileName = fileName;
      handleFileContent(fileContent);
      ruleListener();
    }
  }

  void clear() {
    _importType = ImportType.error;
    _importText = '格式不对';
    _fileName = '[未选择文件]';
    _fileContent = [];
    _currentFileIndex = 0;
    _totalFileIndex = 0;
    ruleController.clear();
    notifyListeners();
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

  void selectFile(BuildContext context) async {
    // String fileContent;
    // if (Global.isDesktop) {
    //   final f = await showOpenPanel(
    //     confirmButtonText: '选择规则文件',
    //     allowedFileTypes: <FileTypeFilterGroup>[
    //       FileTypeFilterGroup(
    //         label: 'json或txt文本',
    //         fileExtensions: <String>['json', 'txt', 'bin'],
    //       ),
    //       FileTypeFilterGroup(
    //         label: '其他',
    //         fileExtensions: <String>[],
    //       ),
    //     ],
    //   );
    //   if (f.canceled) {
    //     Utils.toast('未选取文件');
    //     return;
    //   }
    //   final rules = f.paths.first;
    //   _fileName = Utils.getFileNameAndExt(rules);
    //   fileContent = File(rules).readAsStringSync();
    // } else {
    //   FilePickerResult rulesPick =
    //       await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    //   if (rulesPick == null) {
    //     Utils.toast('未选取文件');
    //     return;
    //   }
    //   final rules = rulesPick.files.single;
    //   _fileName = Utils.getFileNameAndExt(rules.path);
    //   fileContent = utf8.decode(rules.bytes);
    // }
    // final d = await CacheUtil.getCacheBasePath(true);
    // String f = await FilesystemPicker.open(
    //   title: '选择规则文件',
    //   rootName: d,
    //   context: context,
    //   rootDirectory: Directory(d),
    //   fsType: FilesystemType.file,
    //   folderIconColor: Colors.teal,
    //   allowedExtensions: ['.json', '.txt', '.bin', ''],
    //   fileTileSelectMode: FileTileSelectMode.wholeTile,
    //   requestPermission: CacheUtil.requestPermission,
    // );
    // if (f == null) {
    //   Utils.toast('未选取文件');
    //   return;
    // }
    FilePickerResult result = await FilePicker.platform
        .pickFiles(withData: false, dialogTitle: "选择txt或者epub导入亦搜");
    if (result == null) {
      Utils.toast("未选择文件");
      return;
    }
    final platformFile = result.files.first;
    print("platformFile.path:${platformFile.path}");

    var fileContent = autoReadFile(platformFile.path).trim();
    if (fileContent.startsWith(esoStart)) {
      fileContent = RuleCompress.decompassString(fileContent);
    } else if (fileContent.startsWith('"' + esoStart) && fileContent.endsWith('"')) {
      fileContent = fileContent.substring(1, fileContent.length - 1);
    }
    _fileName = Utils.getFileNameAndExt(platformFile.name);
    handleFileContent(fileContent);
  }

  void handleFileContent(String fileContent) {
    try {
      final json = jsonDecode(fileContent);
      if (json is Map) {
        _fileContent = [json];
      } else if (json is List) {
        _fileContent = json;
      }
      if (_fileContent.length == 0) {
        _currentFileIndex = 0;
        Utils.toast("$_fileName is empty");
      } else {
        _currentFileIndex = 1;
        _importType = ImportType.file;
        ruleController.text = JsonEncoder.withIndent("  ").convert(_fileContent.first);
      }
      _totalFileIndex = _fileContent.length;
    } catch (e) {
      Utils.toast("文件格式不对");
    }
    notifyListeners();
  }

  void pre() {
    if (_fileContent.length < 2) return;
    _currentFileIndex = _currentFileIndex - 1;
    if (_currentFileIndex < 1) {
      _currentFileIndex = _totalFileIndex;
    }
    ruleController.text =
        JsonEncoder.withIndent("  ").convert(_fileContent[_currentFileIndex - 1]);
    notifyListeners();
  }

  void next() {
    if (_fileContent.length < 2) return;
    _currentFileIndex = _currentFileIndex + 1;
    if (_currentFileIndex >= _totalFileIndex) {
      _currentFileIndex = 1;
    }
    ruleController.text =
        JsonEncoder.withIndent("  ").convert(_fileContent[_currentFileIndex - 1]);
    notifyListeners();
  }

  VoidCallback get import {
    final importType = _importType;
    if (importType == ImportType.error) return null;
    return () {
      _importText = "导入中..";
      _importType = ImportType.error;
      notifyListeners();
      if (importType == ImportType.eso) {
        insertOrUpdateRule(ruleController.text);
      } else if (importType == ImportType.file) {
        insertOrUpdateRule('', _fileContent);
      } else if (importType == ImportType.http) {
        () async {
          final uri = Uri.tryParse("${ruleController.text.trim()}");
          if (uri == null) {
            Utils.toast("地址格式不对");
            return;
          }
          final res = await http.get(uri, headers: {
            'User-Agent':
                'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36'
          });
          insertOrUpdateRule(autoReadBytes(res.bodyBytes));
        }();
      }
    };
  }

  void insertOrUpdateRule(String s, [List l]) async {
    try {
      dynamic json;
      if (l != null) {
        json = l;
      } else {
        json = jsonDecode(s.trim());
      }
      if (json is Map) {
        final id = await Global.ruleDao.insertOrUpdateRule(Rule.fromJson(json));
        if (id != null) {
          Utils.toast("成功 1 条规则");
        }
      } else if (json is List) {
        final okrules = json
            .map((rule) => Rule.fromJson(rule))
            .where((rule) => rule.name.isNotEmpty && rule.host.isNotEmpty)
            .toList();
        final ids = await Global.ruleDao.insertOrUpdateRules(okrules);
        if (ids.length > 0) {
          Utils.toast("成功 ${okrules.length} 条规则");
        } else {
          Utils.toast("失败，未导入规则！");
        }
      }
      close();
      refresh();
    } catch (e) {
      Utils.toast("格式不对$e");
    }
  }
}
