import 'dart:convert';
import 'dart:io';
import 'package:eso/main.dart';
import 'package:path/path.dart' as path;
import 'package:epubx/epubx.dart';
import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/auto_decode_cli.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../api/analyzer_html.dart';
import '../database/search_item.dart';
import '../utils/cache_util.dart';
import 'search_page.dart';

class AddLocalItemPage extends StatefulWidget {
  final PlatformFile platformFile;
  AddLocalItemPage({Key key, this.platformFile}) : super(key: key);

  @override
  State<AddLocalItemPage> createState() => _AddLocalItemPageState();
}

class _AddLocalItemPageState extends State<AddLocalItemPage> {
  PlatformFile platformFile;
  String content;
  EpubBook epubBook;
  SearchItem searchItem;
  TextEditingController textEditingController;
  TextEditingController textEditingControllerReg;
  final List<String> contents = <String>[];

  final defaultReg =
      "(\\s|\\n|^)(第)([\\u4e00-\\u9fa5a-zA-Z0-9]{1,7})[章|节|回|卷][^\\n]{1,35}(\\n|\$)";

  @override
  void initState() {
    platformFile = widget.platformFile;
    textEditingController = TextEditingController();
    textEditingControllerReg = TextEditingController();
    init();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController?.dispose();
    textEditingControllerReg?.dispose();
    contents.clear();
    super.dispose();
  }

  void parseEpubChapter(List<ChapterItem> c, List<EpubChapter> chapters) {
    for (var chapter in chapters) {
      var temp = AnalyzerHtml.getHtmlString(chapter.HtmlContent);
      while (temp.trimLeft().startsWith(chapter.Title)) {
        temp = temp.trimLeft().substring(chapter.Title.length);
      }
      contents.add(temp.trimLeft());
      c.add(ChapterItem(name: chapter.Title, url: "${contents.length}.txt"));
      if (chapter.SubChapters.isNotEmpty) {
        parseEpubChapter(c, chapter.SubChapters);
      }
    }
  }

  void parseEpub() {
    searchItem.chapters?.clear();
    contents.clear();
    searchItem.chapters = <ChapterItem>[];
    parseEpubChapter(searchItem.chapters, epubBook.Chapters);
    searchItem.chaptersCount = searchItem.chapters.length;
    setState(() {});
  }

  void parseText() {
    searchItem.chapters?.clear();
    contents.clear();
    final chapters = <ChapterItem>[];
    var start = 0;
    var name = "";
    var i = 0;
    // content = content.trim();
    for (var r in RegExp(textEditingControllerReg.text).allMatches(content)) {
      if (start == 0 && r.start > 0) {
        chapters.add(ChapterItem(name: "无名", url: "${i++}.txt"));
      }

      final tempName = content.substring(r.start, r.end).trim();
      if (tempName == name) continue;

      var temp = content.substring(start, r.start).trim();
      if (temp.startsWith(name)) {
        contents.add(temp.substring(name.length));
      } else {
        contents.add(temp);
      }
      start = r.end;
      name = tempName;
      chapters.add(ChapterItem(name: name, url: "${i++}.txt"));
    }

    if (start < content.length) {
      var temp = content.substring(start);
      if (temp.startsWith(name)) {
        contents.add(temp.substring(name.length));
      } else {
        contents.add(temp);
      }
    } else {
      contents.add("全文完");
    }
    searchItem.chapters = chapters;
    searchItem.chaptersCount = searchItem.chapters.length;
    setState(() {});
  }

  init() async {
    if (platformFile == null) {
      FilePickerResult result = await FilePicker.platform
          .pickFiles(withData: false, dialogTitle: "选择txt或者epub导入亦搜");
      if (result == null) {
        Utils.toast("未选择文件");
        if (platformFile == null) {
          Navigator.of(context).pop();
          return;
        }
      } else {
        platformFile = result.files.first;
      }
    }
    if (platformFile.extension == "epub") {
      try {
        epubBook = await EpubReader.readBook(File(platformFile.path).readAsBytesSync());
        textEditingController.text = epubBook.Title;
        searchItem = SearchItem(
          cover: "data:image/png;base64," + base64Encode(epubBook.CoverImage.getBytes()),
          name: epubBook.Title,
          author: epubBook.Author,
          chapter: epubBook.Chapters.isNotEmpty ? epubBook.Chapters.last.Title : "",
          description: "",
          url: platformFile.path,
          api: BaseAPI(origin: "本地", originTag: "本地", ruleContentType: API.NOVEL),
          tags: [],
        );
        textEditingControllerReg.text = "";
        // epubBook.Chapters.forEach((element) {
        //   element.Title ;
        // });
      } catch (e) {
        Utils.toast("$e");
      }
      parseEpub();
    } else {
      if (platformFile.size ~/ 1024 > 20000) {
        Utils.toast("文件太大 放弃");
        return;
      }
      try {
        content = autoReadFile(platformFile.path);
        textEditingController.text = Utils.getFileName(platformFile.name);
        if (textEditingControllerReg.text.isEmpty) {
          textEditingControllerReg.text = defaultReg;
        }
        searchItem = SearchItem(
          cover: "",
          name: textEditingController.text,
          author: "",
          chapter: "",
          description: "",
          url: platformFile.path,
          api: BaseAPI(origin: "本地", originTag: "本地", ruleContentType: API.NOVEL),
          tags: [],
        );
        parseText();
      } catch (e) {
        Utils.toast("$e");
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: globalDecoration,
      child: Scaffold(
        appBar: AppBar(
          title: Text("导入本地txt或epub"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: Text(
                  "点击选择 ${platformFile?.extension} ${(platformFile?.size ?? 0) ~/ 1024}KB ${platformFile?.path}",
                ),
                onTap: init,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("书名："),
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        searchItem.name = value;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("正则："),
                  Expanded(
                    child: TextField(controller: textEditingControllerReg),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 10,
              alignment: WrapAlignment.start,
              children: [
                TextButton(
                    onPressed: () async {
                      final r = await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              SimpleChangeRule(searchItem: searchItem)));
                      if (r != null && r is SearchItem) {
                        searchItem.localAddInfo(r);
                        setState(() {});
                      } else {
                        Utils.toast("未选择");
                      }
                    },
                    child: Text("在线搜索")),
                TextButton(
                    onPressed: () {
                      textEditingControllerReg.text = defaultReg;
                    },
                    child: Text("默认正则")),
                TextButton(
                    onPressed: () {
                      if (platformFile.extension == "epub") {
                        // parseEpub();
                      } else {
                        parseText();
                      }
                    },
                    child: Text("分割目录")),
                TextButton(
                  onPressed: () async {
                    // 写入文件
                    final cache = CacheUtil(
                        basePath: "cache${Platform.pathSeparator}${searchItem.id}");
                    final dir = await cache.cacheDir();
                    final d = Directory(dir);
                    if (!d.existsSync()) {
                      d.createSync(recursive: true);
                    }
                    Utils.toast("写入文件中 $dir");
                    final reg = RegExp(r"^\s*|(\s{2,}|\n)\s*");
                    for (var i = 0; i < contents.length; i++) {
                      File(path.join(dir, '$i.txt')).writeAsStringSync(
                          contents[i].split(reg).map((s) => s.trimLeft()).join("\n"));
                    }
                    SearchItemManager.addSearchItem(searchItem);
                    Utils.toast("成功");
                  },
                  child: Text("导入"),
                ),
              ],
            ),
            if (searchItem != null) UiSearchItem(item: searchItem),
            Expanded(
              child: Card(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemExtent: 26,
                  itemCount: searchItem?.chapters?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 26,
                      child: Text(
                          "${(index + 1).toString().padLeft(4)}   ${searchItem.chapters[index].name}"),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
