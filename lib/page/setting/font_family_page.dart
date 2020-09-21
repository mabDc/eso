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
  const FontFamilyPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("字体管理"),
      ),
      body: ChangeNotifierProvider(
        create: (context) => _FontFamilyProvider(),
        builder: (context, child) {
          context.select((_FontFamilyProvider provider) => provider._ttfList?.length);
          final profile = Provider.of<Profile>(context, listen: true);
          final fontFamilyProvider =
              Provider.of<_FontFamilyProvider>(context, listen: false);
          if (fontFamilyProvider.ttfList == null) {
            return LandingPage();
          }
          return ListView(
            children: [
              _buildFontListTile("默认", null, profile),
              _buildFontListTile("Roboto", 'Roboto', profile),
              for (final ttf in fontFamilyProvider.ttfList)
                _buildFontListTile(ttf, ttf, profile),
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

  Widget _buildFontListTile(String name, String fontFamily, Profile profile) {
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
      onTap: () => profile.fontFamily = fontFamily,
      onLongPress: () => profile.novelFontFamily = fontFamily,
    );
  }
}

class _FontFamilyProvider with ChangeNotifier {
  CacheUtil _cacheUtil;
  String _dir;
  String get dir => _dir;

  List<String> _ttfList;
  List<String> get ttfList => _ttfList;

  _FontFamilyProvider() {
    init();
  }

  void init() async {
    _cacheUtil = CacheUtil(backup: true, basePath: "font");
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
