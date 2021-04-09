import 'dart:io';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/profile.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global.dart';
import '../utils.dart';
import 'source/edit_rule_page.dart';

class VideoPageDesktop extends StatelessWidget {
  final SearchItem searchItem;
  const VideoPageDesktop({this.searchItem, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = Profile();
    final primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title:
            Text("${searchItem.name} - ${searchItem.durChapter} - ${searchItem.origin}"),
        actions: [
          IconButton(
            icon: Icon(OMIcons.settingsEthernet),
            tooltip: "编辑规则",
            onPressed: () async {
              final rule = await Global.ruleDao.findRuleById(searchItem.originTag);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EditRulePage(rule: rule)));
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider<VPDProvider>(
        create: (context) => VPDProvider(searchItem: searchItem, profile: profile),
        builder: (BuildContext context, child) {
          final provider = Provider.of<VPDProvider>(context, listen: true);
          return ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      if (provider.isLoading)
                        LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          backgroundColor: Colors.transparent,
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: provider.controller,
                              maxLines: 10,
                            ),
                          ),
                          Container(
                            height: 200,
                            child: TextButton(
                              onPressed: provider.parse,
                              child: Text("解析"),
                            ),
                          ),
                        ],
                      ),
                      ListTile(
                        title: Text('查看目录原网页'),
                        subtitle: Text(searchItem.chapterUrl ?? "无"),
                        onTap: () => launch(searchItem.chapterUrl ?? ""),
                      ),
                      ListTile(
                        title: Text('查看正文原网页'),
                        subtitle: Text(
                            searchItem.chapters[searchItem.durChapterIndex].contentUrl ??
                                "请先解析"),
                        onTap: () => launch(
                            searchItem.chapters[searchItem.durChapterIndex].contentUrl ??
                                ""),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text('点击设置本地播放器'),
                              subtitle: Text(Utils.empty(profile.desktopPlayer)
                                  ? "未选择播放器"
                                  : profile.desktopPlayer),
                              onTap: () => provider.setPlayer(context),
                            ),
                          ),
                          Container(
                            height: 60,
                            child: TextButton(
                              onPressed: provider.play,
                              child: Text("本地播放"),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: provider.controllerWeb,
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            height: 60,
                            child: TextButton(
                              onPressed: provider.playWeb,
                              child: Text("网页播放"),
                            ),
                          ),
                        ],
                      ),
                      ListTile(
                        title: Text('网页打开链接'),
                        subtitle: Text(provider.url ?? "请先解析"),
                        onTap: () => launch(provider.url),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        '嗅探(任意安装一个, 二选一)',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('edge内测版'),
                      subtitle: Text('https://www.microsoftedgeinsider.com/zh-cn/'),
                      onTap: () => launch('https://www.microsoftedgeinsider.com/zh-cn/'),
                    ),
                    ListTile(
                      title: Text('webview2 运行时'),
                      subtitle: Text(
                          'https://developer.microsoft.com/zh-cn/microsoft-edge/webview2/'),
                      onTap: () => launch(
                          'https://developer.microsoft.com/zh-cn/microsoft-edge/webview2/'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class VPDProvider extends ChangeNotifier {
  final SearchItem searchItem;
  final Profile profile;

  VPDProvider({
    @required this.searchItem,
    @required this.profile,
  }) {
    parse(true);
  }
  String _url;
  String get url => _url;
  Process _process;
  bool _isLoading;
  bool get isLoading => _isLoading == true;

  final _format = DateFormat("HH:mm:ss");

  log(String s) {
    controller.text += "\n[${_format.format(DateTime.now())}] $s";
    controller.selection = controller.selection.copyWith(
      baseOffset: controller.text.length,
      extentOffset: controller.text.length,
    );
  }

  parse([bool autoPlay = false]) async {
    if (_isLoading == true) {
      log("已在解析中...");
      return;
    }
    _isLoading = true;
    log("正在解析 请等待...");
    notifyListeners();
    try {
      final content = await APIManager.getContent(
          searchItem.originTag, searchItem.chapters[searchItem.durChapterIndex].url);
      searchItem.chapters[searchItem.durChapterIndex].contentUrl = API.contentUrl;
      if (content.isEmpty || content.first.isEmpty) {
        _url = null;
        log("错误 内容为空！");
      } else {
        _url = content.first;
        if (autoPlay == true) {
          log("播放地址 $_url\n自动开始本地播放");
          play();
        } else {
          log("播放地址 $_url");
        }
      }
    } catch (e, st) {
      log("失败\n$e\n$st");
    }
    _isLoading = false;
    notifyListeners();
  }

  play() async {
    if (_url == null || _url.isEmpty) {
      log("请先解析");
      return;
    }
    if (profile.desktopPlayer == null || profile.desktopPlayer.isEmpty) {
      log("请设置播放器");
      return;
    }
    _process?.kill();
    _process = await Process.start(
      profile.desktopPlayer,
      <String>[_url],
    );
  }

  playWeb() async {
    if (_url == null || _url.isEmpty) {
      log("请先解析");
      return;
    }
    launch(controllerWeb.text.replaceFirst("=%s", "=" + _url));
  }

  void setPlayer(BuildContext context) async {
    // final f = await showOpenPanel(
    //   confirmButtonText: '选择本地播放器',
    //   allowedFileTypes: <FileTypeFilterGroup>[
    //     FileTypeFilterGroup(
    //       label: '可执行文件',
    //       fileExtensions: <String>['exe'],
    //     ),
    //     FileTypeFilterGroup(
    //       label: '其他',
    //       fileExtensions: <String>[],
    //     ),
    //   ],
    // );
    // if (f.canceled) {
    //   Utils.toast('未选取字体文件');
    //   return;
    // }
    // profile.desktopPlayer = f.paths.first;
    profile.desktopPlayer = await FilesystemPicker.open(
      title: '选择本地播放器',
      rootName: profile.desktopPlayer ?? 'C:\\',
      context: context,
      rootDirectory: Directory(Utils.dirname(profile.desktopPlayer ?? "C:\\")),
      fsType: FilesystemType.file,
      folderIconColor: Colors.teal,
      allowedExtensions: ['.exe'],
      fileTileSelectMode: FileTileSelectMode.wholeTile,
      requestPermission: CacheUtil.requestPermission,
    );
    if (profile.desktopPlayer == null) Utils.toast('未选取文件');
  }

  final controller = TextEditingController(text: "解析日志\n");
  final controllerWeb = TextEditingController(text: "http://www.m3u8player.top/?play=%s");
  @override
  void dispose() {
    controller.dispose();
    controllerWeb.dispose();
    super.dispose();
  }
}
