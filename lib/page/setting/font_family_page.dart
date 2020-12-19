import 'dart:io';
import 'dart:ui';

import 'package:eso/page/langding_page.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../profile.dart';
import '../../global.dart';

class FontFamilyPage extends StatelessWidget {
  static const setGlobal = 0;
  static const setNovel = 1;
  final int option;
  final bool showAppbar;
  const FontFamilyPage({
    Key key,
    this.option = setGlobal,
    this.showAppbar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppbar
          ? AppBar(
              title: Text("字体管理"),
              actions: [
                Tooltip(
                  message: '请选配置项再设置字体',
                  child: IconButton(
                    icon: Icon(Icons.help_outline),
                    onPressed: () => null,
                    tooltip: '请选配置项再设置字体',
                  ),
                ),
              ],
            )
          : null,
      body: ChangeNotifierProvider(
        create: (context) => _FontFamilyProvider(option),
        builder: (context, child) {
          context.select((_FontFamilyProvider provider) => provider._ttfList?.length);
          int option = context.select((_FontFamilyProvider provider) => provider.option);
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
                  SizedBox(width: 16),
                  Text('配置'),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Container(
                            width: 160,
                            child: RadioListTile(
                              value: setGlobal,
                              groupValue: option,
                              onChanged: (value) => fontFamilyProvider.option = value,
                              title: Text(
                                '全局界面',
                                style: TextStyle(fontSize: option == setGlobal ? 16 : 14),
                              ),
                            ),
                          ),
                          Container(
                            width: 160,
                            child: RadioListTile(
                              value: setNovel,
                              groupValue: option,
                              onChanged: (value) => fontFamilyProvider.option = value,
                              title: Text(
                                '文字正文',
                                style: TextStyle(fontSize: option == setNovel ? 16 : 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Divider(),
              _buildFontListTile("默认", null, profile, option),
              _buildFontListTile("Roboto", 'Roboto', profile, option),
              for (final ttf in fontFamilyProvider.ttfList)
                _buildFontListTile(ttf, ttf, profile, option),
              ListTile(
                onTap: fontFamilyProvider.pickFont,
                title: Row(
                  children: [
                    Icon(Icons.add_outlined),
                    Expanded(
                      child: Text(
                        '添加本地字体文件',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                subtitle: Text('路径 ${fontFamilyProvider.dir}'),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildFontListTile(String name, String fontFamily, Profile profile, int option) {
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
                color: Color(profile.primaryColor),
              ),
            ),
          if (profile.novelFontFamily == fontFamily)
            Text(
              '√正文 ',
              style: TextStyle(
                color: Color(profile.primaryColor),
              ),
            ),
        ],
      ),
      onTap: () {
        if (option == setGlobal) {
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
  int _option;
  int get option => _option;
  set option(int value) {
    if (_option != value) {
      _option = value;
      notifyListeners();
    }
  }

  _FontFamilyProvider(int option) {
    _option = option;
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
    if (Global.isDesktop) {
      final f = await showOpenPanel(
        confirmButtonText: '选择字体',
        allowedFileTypes: <FileTypeFilterGroup>[
          FileTypeFilterGroup(
            label: '字体文件',
            fileExtensions: <String>['ttf', 'ttc', 'otf'],
          ),
          FileTypeFilterGroup(
            label: '其他',
            fileExtensions: <String>[],
          ),
        ],
      );
      if (f.canceled) {
        Utils.toast('未选取字体文件');
        return;
      }
      final ttf = f.paths.first;
      final file = File(ttf);
      final name = Utils.getFileName(ttf);
      await _cacheUtil.putFile(name, file);
      await loadFontFromList(file.readAsBytesSync(), fontFamily: name);
      _ttfList.add(name);
      notifyListeners();
      Utils.toast('字体已保存到$_dir');
    } else {
      FilePickerResult ttfPick = await FilePicker.platform.pickFiles(
        type: FileType.custom,
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
  }

  Future<void> _loadFont(String fontName) async {
    await loadFontFromList(await File(dir + fontName).readAsBytes(),
        fontFamily: fontName);
  }
}
