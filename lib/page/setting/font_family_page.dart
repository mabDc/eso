import 'dart:io';
import 'dart:ui';

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
      body: Container(
        child: InkWell(
          child: Text(''),
          onTap: () async {},
        ),
      ),
    );
  }

  Widget _buildColorListTile(MapEntry<String, String> font) {
    return Consumer<Profile>(
      builder: (BuildContext context, Profile profile, Widget widget) {
        return ListTile(
          title: Text(
            font.key,
            style: TextStyle(fontFamily: font.value),
          ),
          trailing: font.value == profile.fontFamily
              ? Icon(Icons.done,
                  size: 32,
                  color: Color(Global.colors[profile.colorName] ?? profile.customColor))
              : null,
          onTap: () => profile.fontFamily = font.value,
        );
      },
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
    _cacheUtil = CacheUtil(backup: true, basePath: "ttf_font");
    _dir = await _cacheUtil.cacheDir();
    await refreshList();
  }

  Future<void> refreshList() async {
    _ttfList?.clear();
    _ttfList = null;
    notifyListeners();
    final directory = Directory(_dir);
    final files = directory.listSync();
    _ttfList =
        files.map((file) => file.path.substring(file.parent.path.length + 1)).toList();
    notifyListeners();
    return;
  }

  void pickFont() async {
    FilePickerResult ttfPick = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['ttf', 'otf'],
    );
    if (ttfPick == null) return;
    final ttf = ttfPick.files.single;
    if (ttf.extension != 'ttf' && ttf.extension != 'otf') return;
    final cache = CacheUtil(backup: true, basePath: "ttf_font");
    await cache.putFile(ttf.name, File(ttf.path));
    Utils.toast('字体已保存到$_dir');
    await loadFontFromList(ttf.bytes, fontFamily: ttf.name.replaceAll('.', '_'));
    Utils.toast('字体已加载');
  }

  void loadFont(String fontName) async {
    await loadFontFromList(await File(dir + fontName).readAsBytes(),
        fontFamily: fontName.replaceAll('.', '_'));
    Utils.toast('字体已加载');
  }
}
