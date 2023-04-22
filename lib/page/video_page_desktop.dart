import 'dart:io';

import 'package:eso/database/search_item.dart';
import 'package:eso/eso_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

import '../global.dart';
import '../ui/ui_dash.dart';
import '../utils.dart';
import 'content_page_manager.dart';
import 'source/edit_rule_page.dart';

class VideoPageDesktop extends StatefulWidget {
  final SearchItem searchItem;
  const VideoPageDesktop({this.searchItem, Key key}) : super(key: key);

  @override
  State<VideoPageDesktop> createState() => _VideoPageDesktopState();
}

class _VideoPageDesktopState extends State<VideoPageDesktop> {
  WebviewController webviewController;
  ESOTheme profile;
  Color primaryColor;

  @override
  void initState() {
    profile = ESOTheme();
    if (webviewController == null) webviewController = WebviewController();
    // (() async {
    //   try {
    //     if (!webviewController.value.isInitialized) {
    //       await webviewController.initialize();
    //       if (mounted) setState(() {});
    //     }
    //   } catch (e) {}
    // })();
    super.initState();
  }

  @override
  void dispose() {
    webviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    primaryColor = Theme.of(context).primaryColor;
    final _divider = UIDash(height: Global.lineSize, dashWidth: 4, color: Colors.black);
    final contentProvider = Provider.of<ContentProvider>(context);
    return ChangeNotifierProvider<VPDProvider>(
      create: (context) => VPDProvider(
          searchItem: widget.searchItem,
          profile: profile,
          webcontroller: webviewController,
          contentProvider: contentProvider),
      builder: (BuildContext context, child) {
        final searchItem = widget.searchItem;
        final provider = Provider.of<VPDProvider>(context, listen: true);
        return Scaffold(
            appBar: provider.systemFullScreen
                ? null
                : AppBar(
                    title: Text(
                        "${searchItem.name} - ${searchItem.durChapter} - ${searchItem.origin}"),
                    actions: [
                      IconButton(
                        icon: Icon(OMIcons.settingsEthernet),
                        tooltip: "编辑规则",
                        onPressed: () async {
                          final rule =
                              await Global.ruleDao.findRuleById(searchItem.originTag);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EditRulePage(rule: rule)));
                        },
                      ),
                      IconButton(
                        icon: Icon(OMIcons.details),
                        tooltip: "解析日志和其他信息",
                        onPressed: provider.toggleWindowFullScreen,
                      ),
                      IconButton(
                        icon: Icon(OMIcons.menu),
                        tooltip: "剧集列表",
                        onPressed: provider.toggleshowList,
                      ),
                      IconButton(
                        icon: Icon(OMIcons.fullscreen),
                        tooltip: "系统全屏",
                        onPressed: provider.toggleSystemFullScreen,
                      ),
                    ],
                  ),
            body: Stack(
              alignment: Alignment.bottomRight,
              children: [
                provider.windowFullScreen
                    ? !webviewController.value.isInitialized
                        ? Center(
                            child: const Text(
                              '\n\n正在初始化播放器。。。\n\n如果没反应请尝试滑动到页面底部下载微软的运行时\n\n已增加剧集 预解析 缓存\n\n',
                              style: TextStyle(fontSize: 30.0),
                            ),
                          )
                        : Center(child: Webview(webviewController))
                    : ListView(
                        children: [
                          !webviewController.value.isInitialized
                              ? const Text(
                                  '\n\n正在初始化播放器。。。\n\n如果没反应请尝试滑动到页面底部下载微软的运行时\n\n已增加剧集 预解析 缓存\n\n',
                                  style: TextStyle(fontSize: 30.0),
                                )
                              : Container(
                                  height: 500,
                                  child: Center(child: Webview(webviewController)),
                                ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  if (provider.isLoading)
                                    LinearProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(Colors.red),
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
                                          onPressed: () => provider.playChapter(
                                              searchItem.durChapterIndex, false),
                                          child: Text("解析"),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ListTile(
                                    title: Text('浏览器播放'),
                                    subtitle: Text(provider.url ?? "请先解析"),
                                    onTap: () => launch(provider.url),
                                  ),
                                  ListTile(
                                    title: Text('查看目录原网页'),
                                    subtitle: Text(searchItem.chapterUrl ?? "无"),
                                    onTap: () => launch(searchItem.chapterUrl ?? ""),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text('点击设置本地播放器'),
                                          subtitle: Text(
                                              Utils.empty(profile.desktopPlayer)
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
                                ],
                              ),
                            ),
                          ),
                          Card(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    'webview2用于嗅探和视频播放(任意安装一个都可以)',
                                    style: TextStyle(color: primaryColor),
                                  ),
                                ),
                                Divider(),
                                ListTile(
                                  title: Text('edge内测版'),
                                  subtitle:
                                      Text('https://www.microsoftedgeinsider.com/zh-cn/'),
                                  onTap: () => launch(
                                      'https://www.microsoftedgeinsider.com/zh-cn/'),
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
                      ),
                if (provider.showList)
                  Card(
                    margin: EdgeInsets.only(top: 26, bottom: 50, right: 26),
                    color: Colors.grey.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      width: 350,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) => Divider(),
                              itemCount: searchItem.chapters.length,
                              itemBuilder: (BuildContext context, int index) {
                                final chapter = searchItem.chapters[index];
                                return ListTile(
                                  leading: index == searchItem.durChapterIndex
                                      ? Icon(Icons.check, color: Colors.white70)
                                      : null,
                                  title: Text(
                                    chapter.name,
                                    style: TextStyle(color: Colors.white70),
                                    maxLines: 1,
                                  ),
                                  onTap: () => provider.playChapter(index),
                                  subtitle:
                                      chapter.time != null && chapter.time.isNotEmpty
                                          ? Text(
                                              chapter.time,
                                              style: TextStyle(color: Colors.white70),
                                              maxLines: 1,
                                            )
                                          : null,
                                );
                              },
                            ),
                          ),
                          Divider(),
                          ListTile(
                            onTap: provider.toggleshowList,
                            leading: Icon(Icons.close, color: Colors.white70),
                            title: Text(
                              "关闭列表",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (provider.windowFullScreen)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 26, bottom: 5, top: 5),
                          child: Icon(
                            OMIcons.list,
                            color: Colors.grey.withOpacity(0.1),
                            size: 30,
                          ),
                        ),
                        onTap: provider.toggleshowList,
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 26, bottom: 5, top: 5),
                          child: Icon(
                            OMIcons.fullscreen,
                            color: Colors.grey.withOpacity(0.1),
                            size: 30,
                          ),
                        ),
                        onTap: provider.toggleSystemFullScreen,
                      ),
                    ],
                  ),
              ],
            ));
      },
    );
  }
}

class VPDProvider extends ChangeNotifier {
  final SearchItem searchItem;
  final ESOTheme profile;
  final WebviewController webcontroller;
  final ContentProvider contentProvider;

  VPDProvider({
    @required this.searchItem,
    @required this.profile,
    @required this.webcontroller,
    @required this.contentProvider,
  }) {
    playChapter(searchItem.durChapterIndex, false);
  }
  String _url;
  String get url => _url;
  Process _process;
  bool _isLoading;
  bool get isLoading => _isLoading == true;

  bool _systemFullScreen;
  bool get systemFullScreen => _systemFullScreen == true;

  void toggleSystemFullScreen() async {
    if (systemFullScreen) {
      _systemFullScreen = false;
    } else {
      _systemFullScreen = true;
      _windowFullScreen = true;
    }
    await windowManager.setFullScreen(_systemFullScreen);
    notifyListeners();
  }

  bool _windowFullScreen;
  bool get windowFullScreen => _windowFullScreen == true;

  void toggleWindowFullScreen() {
    if (windowFullScreen) {
      _windowFullScreen = false;
    } else {
      _windowFullScreen = true;
    }
    notifyListeners();
  }

  bool _showList;
  bool get showList => _showList == true;

  void toggleshowList() {
    if (showList) {
      _showList = false;
    } else {
      _showList = true;
    }
    notifyListeners();
  }

  final _format = DateFormat("HH:mm:ss");

  log(String s) {
    controller.text += "\n[${_format.format(DateTime.now())}] $s";
    controller.selection = controller.selection.copyWith(
      baseOffset: controller.text.length,
      extentOffset: controller.text.length,
    );
  }

  playChapter(int index, [bool autoCross = true]) async {
    if (_isLoading == true) {
      log("已在解析中...");
      return;
    }
    if (autoCross && searchItem.durChapterIndex == index) {
      log("选中章节正在播放 跳过");
      notifyListeners();
      return;
    }
    if (index >= searchItem.chapters.length || index < 0) {
      log("错误 不存在选中章节");
      notifyListeners();
      return;
    }
    _isLoading = true;
    final chapter = searchItem.chapters[index];
    searchItem.durChapterIndex = index;
    searchItem.durChapter = chapter.name;
    log("正在解析 请等待...");
    log("章节信息："
        "\n    index = ${index}"
        "\n    chapter.name = ${chapter.name}"
        "\n    chapter.time = ${chapter.time}"
        "\n    chapter.cover = ${chapter.cover}"
        "\n    chapter.url = ${chapter.url}");
    notifyListeners();
    try {
      // final content = await APIManager.getContent(searchItem.originTag, chapter.url);
      final content = await contentProvider.loadChapter(index);
      // searchItem.chapters[searchItem.durChapterIndex].contentUrl = API.contentUrl;
      if (content.isEmpty || content.first.isEmpty) {
        _url = null;
        log("错误 内容为空！");
      } else {
        _url = content.first;
        log("播放地址 $_url\n自动开始本地播放");
        if (!webcontroller.value.isInitialized) await webcontroller.initialize();
        // if (_url.startsWith("https")) {
        // _url = "https://jx.parwix.com:4433/player/?url=" + Uri.encodeFull(_url);
        // } else {
        var dir = kDebugMode
            ? Utils.join(Directory.current.path, "player.html")
            : Utils.join(Directory.current.path, "data", "flutter_assets", "player.html");
        dir = Uri.encodeFull(dir).replaceAll("%5C", "\\");
        _url = "file:///$dir#$_url";
        // }
        await webcontroller.loadUrl(_url);
        _windowFullScreen = true;
        // if (autoPlay == true) {
        //   log("播放地址 $_url\n自动开始本地播放");
        //   play();
        // } else {
        //   log("播放地址 $_url");
        // }
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

    // profile.desktopPlayer = await FilesystemPicker.openDialog(
    //     title: '选择本地播放器',
    //     rootName: profile.desktopPlayer ?? 'C:\\',
    //     context: context,
    //     permissionText: "没有权限读取该文件夹",
    //     rootDirectory: Directory(Utils.dirname(profile.desktopPlayer ?? "C:\\")),
    //     fsType: FilesystemType.file,
    //     folderIconColor: Theme.of(context).iconTheme.color,
    //     allowedExtensions: ['.exe'],
    //     fileTileSelectMode: FileTileSelectMode.wholeTile,
    //     requestPermission: CacheUtil.requestPermission,
    //     contextActions: <FilesystemPickerContextAction>[
    //       FilesystemPickerContextAction(
    //           action: (context, path) => null,
    //           text: "读取",
    //           icon: Icon(
    //             Icons.open_in_new,
    //             color: Theme.of(context).iconTheme.color,
    //           ))
    //     ]);
    final r = await Utils.pickFile(context, ['.exe'], profile.desktopPlayer ?? 'C:\\',
        title: '选择本地播放器');
    if (r != null) {
      profile.desktopPlayer = r;
      notifyListeners();
    }
  }

  final controller = TextEditingController(text: "解析日志\n");

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
