import 'dart:io';

import 'package:eso/api/api.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/main.dart';
import 'package:eso/ui/widgets/draggable_scrollbar_sliver.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../global.dart';
import '../utils.dart';
import 'package:path_provider/path_provider.dart' as path;

class NovelCacheService {
  NovelCacheService._privateConstructor()
      : _listeners = [],
        _startTable = {};
  static final NovelCacheService _instance = NovelCacheService._privateConstructor();
  factory NovelCacheService() {
    return _instance;
  }

  String exportDir;

  final List<Function()> _listeners;
  addListener(Function() listener) {
    _listeners.add(listener);
  }

  removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  notifyListeners() => _listeners.forEach((l) => l());

  final Map<int, Set<String>> _startTable;

  Set<String> getCachedIndex(int id) =>
      _startTable.containsKey(id) ? _startTable[id] : Set<String>();

  bool isCached(int id, int index) =>
      _startTable.containsKey(id) && _startTable[id].contains(index);

  bool isCaching(int id) => _startTable.containsKey(id);

  bool _exportLoading;

  void exportCache(SearchItem searchItem, String exportChapterName, bool isShare) async {
    if (_exportLoading == true) {
      Utils.toast("正在导出...");
      return;
    }
    _exportLoading = true;
    Utils.toast("开始导出已缓存章节");
    final rule = await Global.ruleDao.findRuleById(searchItem.originTag);
    final chapterUrl = searchItem.chapterUrl ?? Utils.getUrl(rule.host, searchItem.url);
    try {
      final chapters = searchItem.chapters;
      final export = <String>[
        "书名: ${searchItem.name}",
        "作者: ${searchItem.author}",
        "地址: ${searchItem.searchUrl}",
        "目录: $chapterUrl",
        // ...chapters.map((ch) => ch.name).toList(),
      ];
      final _fileCache =
          CacheUtil(basePath: "cache${Platform.pathSeparator}${searchItem.id}");
      final cacheChapterIndex = Directory(await _fileCache.cacheDir())
          .listSync()
          .map((d) => Utils.getFileName(d.path))
          .toSet();
      for (final index in List.generate(chapters.length, (index) => index)) {
        String temp;
        if (cacheChapterIndex.contains(index.toString())) {
          temp = await _fileCache.getData("$index.txt",
              shouldDecode: false, hashCodeKey: false);
        }
        export.add("");
        export.add(exportChapterName
            .replaceAll("\$index", (index + 1).toString())
            .replaceAll("\$name", chapters[index].name));
        export.add("");
        if (temp != null && temp.isNotEmpty) {
          export.add(temp);
        } else {
          export.add("未缓存或内容为空");
        }
      }
      final cache = CacheUtil(basePath: "txt");
      final name = "${searchItem.name}_${searchItem.author}" +
          "searchItem${searchItem.id}".hashCode.toString() +
          ".txt";
      await cache.putData(name, export.join("\n"),
          hashCodeKey: false, shouldEncode: false);

      final filePath =
          exportDir == null ? await cache.cacheDir() + name : Utils.join(exportDir, name);
      // final download = await path.getApplicationDocumentsDirectory();
      // final filePath = Utils.join(download.path, "eso", name);
      await File(filePath).writeAsString(export.join("\n"));
      Utils.toast("成功导出到 $filePath");
      // if (isShare) await FlutterShare.shareFile(title: name, filePath: filePath);
      if (isShare) await Share.shareFiles(<String>[filePath], text: name);
    } catch (e) {
      Utils.toast("失败 $e");
    }
    _exportLoading = false;
  }

  start(SearchItem searchItem) async {
    final id = searchItem.id;
    if (_startTable.containsKey(id)) {
      // Utils.toast("已经在缓存，如需重新开始请先停止");
      return;
    }
    final chapters = searchItem.chapters;
    final originTag = searchItem.originTag;
    final _fileCache =
        CacheUtil(basePath: "cache${Platform.pathSeparator}${searchItem.id}");
    _startTable[id] = Directory(await _fileCache.cacheDir())
        .listSync()
        .map((d) => Utils.getFileName(d.path))
        .toSet();
    notifyListeners();
    await CacheUtil.requestPermission();
    for (var index = 0; index < chapters.length; index++) {
      if (!_startTable.containsKey(id)) return;
      if (_startTable[id].contains(index.toString())) continue;
      try {
        final chapter = chapters[index];
        final content = await APIManager.getContent(originTag, chapter.url);
        if (!_startTable.containsKey(id)) return;
        chapter.contentUrl = API.contentUrl;
        final c = content.join("\n").split(RegExp(r"\n\s*|\s{2,}")).join("\n");
        await _fileCache.putData('$index.txt', c,
            hashCodeKey: false, shouldEncode: false);
        if (!_startTable.containsKey(id)) return;
        _startTable[id].add(index.toString());
        notifyListeners();
      } catch (e) {}
    }
    notifyListeners();
    Utils.toast("自动缓存 ${searchItem.name} 已完成");
    _startTable.remove(searchItem.id);
    notifyListeners();
  }

  stop(SearchItem searchItem) {
    _startTable.remove(searchItem.id);
    notifyListeners();
  }
}

class NovelAutoCachePage extends StatefulWidget {
  final SearchItem searchItem;
  const NovelAutoCachePage({
    Key key,
    this.searchItem,
  }) : super(key: key);

  @override
  _NovelAutoCachePageState createState() => _NovelAutoCachePageState();
}

class _NovelAutoCachePageState extends State<NovelAutoCachePage> {
  TextEditingController exportChapterName;
  ScrollController scrollController;
  Set<String> cacheIndex = new Set<String>();
  String exportDir = "未选择，使用默认路径";
  Box<String> novel_cache_export_dir_box;
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    exportChapterName = TextEditingController(text: "\$name");
    scrollController = ScrollController();
    NovelCacheService().addListener(refresh);
    NovelCacheService().start(widget.searchItem);
    novel_cache_export_dir_box = await Hive.openBox<String>('novel_cache_export_dir');
    exportDir = novel_cache_export_dir_box.get(0);
    if (exportDir == null) {
      final cache = CacheUtil(basePath: "txt");
      exportDir = await cache.cacheDir();
    } else {
      NovelCacheService().exportDir = exportDir;
    }
  }

  void refresh() => setState(() {});

  @override
  void dispose() {
    NovelCacheService().removeListener(refresh);
    exportChapterName.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchItem = widget.searchItem;
    final chapters = searchItem.chapters;
    final service = NovelCacheService();
    final cacheIndexA = service.getCachedIndex(searchItem.id);
    if (cacheIndexA.isNotEmpty) cacheIndex = cacheIndexA;
    const cacheText = const Text("已缓存", style: TextStyle(color: Colors.green));
    const noCacheText = const Text("未缓存", style: TextStyle(color: Colors.grey));
    final isCaching = service.isCaching(searchItem.id);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          '${searchItem.name} - ${searchItem.origin}',
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                service.exportCache(searchItem, exportChapterName.text, true),
            icon: Icon(Icons.share),
            tooltip: "导出并分享已缓存章节",
          ),
          IconButton(
            onPressed: () =>
                service.exportCache(searchItem, exportChapterName.text, false),
            icon: Icon(Icons.exit_to_app),
            tooltip: "导出已缓存章节",
          ),
          IconButton(
            onPressed: () =>
                isCaching ? service.stop(searchItem) : service.start(searchItem),
            icon: Icon(isCaching ? Icons.stop : Icons.play_arrow),
            tooltip: isCaching ? "取消缓存" : "开始缓存",
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(2),
        decoration: globalDecoration,
        child: DraggableScrollbar.semicircle(
          controller: scrollController,
          labelTextBuilder: (double offset) => Text("${offset ~/ 30 + 1}"),
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            cacheExtent: 30,
            itemCount: searchItem.chaptersCount + 2,
            itemBuilder: (BuildContext context, int i) {
              if (i == 0) {
                return ListTile(
                  title: Text("导出路径"),
                  subtitle: Text(exportDir),
                  onTap: () async {
                    // Directory rootDirectory;
                    // switch (Platform.operatingSystem) {
                    //   case 'android':
                    //     print(Platform.operatingSystemVersion);
                    //     rootDirectory = await path.getApplicationDocumentsDirectory();
                    //     break;
                    //   case 'ios':
                    //     rootDirectory = await path.getApplicationDocumentsDirectory();
                    //     break;
                    //   case 'windows':
                    //     rootDirectory = await path.getApplicationDocumentsDirectory();
                    //     break;
                    //   case 'macos':
                    //     rootDirectory = await path.getApplicationDocumentsDirectory();
                    //     break;
                    //   default:
                    //     rootDirectory = await path.getApplicationDocumentsDirectory();
                    // }
                    // final p = await FilesystemPicker.open(
                    //   context: context,
                    //   rootDirectory:
                    //       Directory(rootDirectory.path + Platform.pathSeparator),
                    //   fileTileSelectMode: FileTileSelectMode.checkButton,
                    //   fsType: FilesystemType.folder,
                    //   requestPermission: CacheUtil.requestPermission,
                    //   rootName: rootDirectory.path,
                    // );
                    final p = await Utils.pickFolder(context,title: "选择导出路径",
                        initialDirectory: novel_cache_export_dir_box.get(0));
                    if (p != null) {
                      exportDir = p;
                      novel_cache_export_dir_box.put(0, p);
                      NovelCacheService().exportDir = p;
                      refresh();
                    }
                  },
                );
              }
              if (i == 1) {
                return TextField(
                  maxLines: 10,
                  minLines: 1,
                  controller: exportChapterName,
                  decoration: InputDecoration(
                    hintText: "序号(\$index) 名称(\$name) 可空",
                    labelText: "自定义导出章节名格式",
                  ),
                  autofocus: false,
                );
              }
              final index = i - 2;
              return Container(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        chapters[index].name ?? 0,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    cacheIndex.contains(index.toString()) ? cacheText : noCacheText,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
