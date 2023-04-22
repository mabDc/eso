import 'dart:io';
import 'dart:ui';

import 'package:eso/hive/theme_box.dart';
import 'package:eso/main.dart';
import 'package:eso/page/langding_page.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../eso_theme.dart';

class FontFamilyPage extends StatelessWidget {
  const FontFamilyPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: globalDecoration,
      child: Scaffold(
        appBar: AppBar(
          title: Text("字体管理"),
        ),
        body: ChangeNotifierProvider(
          create: (context) => _FontFamilyProvider(),
          builder: (context, child) {
            context.select((_FontFamilyProvider provider) => provider._ttfList?.length);
            final profile = ESOTheme();
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
                  onTap: () => fontFamilyProvider.pickFont(context),
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
      ),
    );
  }

  Widget _buildFontListTile(String name, String fontFamily, ESOTheme profile) {
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
                color: Color(primaryColor),
              ),
            ),
        ],
      ),
      onTap: () {
        profile.fontFamily = fontFamily;
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

  _FontFamilyProvider() {
    init();
  }

  void init() async {
    _cacheUtil = CacheUtil(backup: true, basePath: "font");
    try {
      final p = await CacheUtil.requestPermission();
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

  void pickFont(BuildContext context) async {
    // String ttf = await FilesystemPicker.open(
    //   title: '选择字体',
    //   context: context,
    //   rootName: _dir,
    //   rootDirectory: Directory(_dir),
    //   fsType: FilesystemType.file,
    //   folderIconColor: Colors.teal,
    //   allowedExtensions: ['.ttf', '.ttc', '.otf'],
    //   fileTileSelectMode: FileTileSelectMode.wholeTile,
    //   requestPermission: CacheUtil.requestPermission,
    // );
    String ttf =
        await Utils.pickFile(context, ['.ttf', '.ttc', '.otf'], _dir, title: "选择字体");
    if (ttf == null) {
      Utils.toast('未选取字体文件');
      return;
    }
    final file = File(ttf);
    final name = Utils.getFileNameAndExt(ttf);
    await _cacheUtil.putFile(name, file);
    await loadFontFromList(file.readAsBytesSync(), fontFamily: name);
    _ttfList.add(name);
    notifyListeners();
    Utils.toast('字体已保存到$_dir');
    // if (Global.isDesktop) {
    //   final f = await showOpenPanel(
    //     confirmButtonText: '选择字体',
    //     allowedFileTypes: <FileTypeFilterGroup>[
    //       FileTypeFilterGroup(
    //         label: '字体文件',
    //         fileExtensions: <String>['ttf', 'ttc', 'otf'],
    //       ),
    //       FileTypeFilterGroup(
    //         label: '其他',
    //         fileExtensions: <String>[],
    //       ),
    //     ],
    //   );
    //   if (f.canceled) {
    //     Utils.toast('未选取字体文件');
    //     return;
    //   }
    //   final ttf = f.paths.first;
    //   final file = File(ttf);
    //   final name = Utils.getFileName(ttf);
    //   await _cacheUtil.putFile(name, file);
    //   await loadFontFromList(file.readAsBytesSync(), fontFamily: name);
    //   _ttfList.add(name);
    //   notifyListeners();
    //   Utils.toast('字体已保存到$_dir');
    // } else {
    //   FilePickerResult ttfPick = await FilePicker.platform.pickFiles(
    //     type: FileType.custom,
    //   );
    //   if (ttfPick == null) {
    //     Utils.toast('未选取字体文件');
    //     return;
    //   }
    //   final ttf = ttfPick.files.single;
    //   if (ttf.extension != 'ttf' && ttf.extension != 'ttc' && ttf.extension != 'otf') {
    //     Utils.toast('只支持扩展名为ttf或otf或ttc的字体文件');
    //     return;
    //   }
    //   await _cacheUtil.putFile(ttf.name, File(ttf.path));
    //   await loadFontFromList(ttf.bytes, fontFamily: ttf.name);
    //   _ttfList.add(ttf.name);
    //   notifyListeners();
    //   Utils.toast('字体已保存到$_dir');
    // }
  }

  Future<void> _loadFont(String fontName) async {
    await loadFontFromList(await File(dir + fontName).readAsBytes(),
        fontFamily: fontName);
  }
}
