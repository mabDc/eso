import 'dart:io';
import 'dart:ui';

import 'package:eso/page/langding_page.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/profile.dart';
import '../../global.dart';

class FontFamilyPage extends StatelessWidget {
  final checkGlobal;
  const FontFamilyPage({
    Key key,
    this.checkGlobal = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("字体管理"),
        actions: [
          Tooltip(
            message: '选择配置项\n点击设置',
            child: IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () => null,
              tooltip: '选择配置项\n点击设置',
            ),
          ),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (context) => _FontFamilyProvider(checkGlobal),
        builder: (context, child) {
          context.select((_FontFamilyProvider provider) => provider._ttfList?.length);
          bool checkGlobal =
              context.select((_FontFamilyProvider provider) => provider.checkGlobal);
          final profile = Provider.of<Profile>(context, listen: true);
          final fontFamilyProvider =
              Provider.of<_FontFamilyProvider>(context, listen: false);
          if (fontFamilyProvider.ttfList == null) {
            return LandingPage();
          }
          return ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      value: checkGlobal,
                      title: Text('全局界面', style: TextStyle(fontSize: 16)),
                      dense: true,
                      onChanged: (value) => fontFamilyProvider.checkGlobal = true,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      value: !checkGlobal,
                      title: Text('文字正文', style: TextStyle(fontSize: 16)),
                      dense: true,
                      onChanged: (value) => fontFamilyProvider.checkGlobal = false,
                    ),
                  ),
                ],
              ),
              Divider(),
              _buildFontListTile("默认", null, profile, checkGlobal),
              _buildFontListTile("Roboto", 'Roboto', profile, checkGlobal),
              for (final ttf in fontFamilyProvider.ttfList)
                _buildFontListTile(ttf, ttf, profile, checkGlobal),
              ListTile(
                title: InkWell(
                  onTap: fontFamilyProvider.pickFont,
                  child: Row(
                    children: [
                      Icon(Icons.add_outlined),
                      Text('添加本地 ttf或ttc或otf 字体文件'),
                    ],
                  ),
                ),
                subtitle: Text('字体路径 ${fontFamilyProvider.dir}'),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildFontListTile(
      String name, String fontFamily, Profile profile, bool checkGlobal) {
    return ListTile(
      title: Text(
        name,
        style: TextStyle(fontFamily: fontFamily),
      ),
      subtitle: Text(
        '这是一段测试文本',
        style: TextStyle(fontFamily: fontFamily),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (profile.fontFamily == fontFamily)
            Text(
              '√全局 ',
              style: TextStyle(
                color: Color(Global.colors[profile.colorName] ?? profile.customColor),
              ),
            ),
          if (profile.novelFontFamily == fontFamily)
            Text(
              '√正文 ',
              style: TextStyle(
                color: Color(Global.colors[profile.colorName] ?? profile.customColor),
              ),
            ),
        ],
      ),
      onTap: () {
        if (checkGlobal) {
          profile.fontFamily = fontFamily;
        } else {
          profile.novelFontFamily = fontFamily;
        }
      },
      // onLongPress: () => profile.novelFontFamily = fontFamily,
    );
  }
}

class _FontFamilyProvider with ChangeNotifier {
  CacheUtil _cacheUtil;
  String _dir;
  String get dir => _dir;

  List<String> _ttfList;
  List<String> get ttfList => _ttfList;
  bool _checkGlobal;
  bool get checkGlobal => _checkGlobal;
  set checkGlobal(bool value) {
    if (_checkGlobal != value) {
      _checkGlobal = value;
      notifyListeners();
    }
  }

  _FontFamilyProvider(bool checkGlobal) {
    _checkGlobal = checkGlobal != false;
    init();
  }

  void init() async {
    _cacheUtil = CacheUtil(backup: true, basePath: "font");
    try {
      final p = await _cacheUtil.requestPermission();
      if (!p) {
        Utils.toast('读取字体需要存储权限');
        _ttfList = <String>[];
        return;
      }
    } catch (e) {
      Utils.toast('读取字体需要存储权限');
      _ttfList = <String>[];
      return;
    }
    _dir = await _cacheUtil.cacheDir();
    await refreshList();
  }

  Future<void> refreshList() async {
    if (!Directory(_dir).existsSync()) {
      await Directory(_dir).create(recursive: true);
    }
    final directory = Directory(_dir);
    final files = directory.listSync();
    _ttfList =
        files.map((file) => file.path.substring(file.parent.path.length + 1)).toList();
    _ttfList.forEach((ttf) async => await _loadFont(ttf));
    notifyListeners();
    return;
  }

  void pickFont() async {
    FilePickerResult ttfPick = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['ttf', 'otf', 'ttc'],
    );
    if (ttfPick == null) {
      Utils.toast('未选取字体文件');
      return;
    }
    final ttf = ttfPick.files.single;
    if (ttf.extension != 'ttf' && ttf.extension != 'ttc' && ttf.extension != 'otf') {
      Utils.toast('只支持扩展名为ttf或otf或ttc的字体文件');
      return;
    }
    await _cacheUtil.putFile(ttf.name, File(ttf.path));
    await loadFontFromList(ttf.bytes, fontFamily: ttf.name);
    _ttfList.add(ttf.name);
    notifyListeners();
    Utils.toast('字体已保存到$_dir');
  }

  Future<void> _loadFont(String fontName) async {
    await loadFontFromList(await File(dir + fontName).readAsBytes(),
        fontFamily: fontName);
  }
}
