import 'dart:convert';
import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item_manager.dart';
import 'package:eso/ui/ui_search2_item.dart';
import 'package:eso/ui/ui_search_item.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/auto_decode_cli.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../database/search_item.dart';
import 'search_page.dart';

class AddLocalItemPage extends StatefulWidget {
  AddLocalItemPage({Key key}) : super(key: key);

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

  @override
  void initState() {
    textEditingController = TextEditingController();
    init();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController?.dispose();
    textEditingControllerReg?.dispose();
    super.dispose();
  }

  init() async {
    FilePickerResult result = await FilePicker.platform
        .pickFiles(withData: false, dialogTitle: "选择txt或者epub导入亦搜");
    if (result == null) {
      Utils.toast("未选择文件");
      if (platformFile == null) {
        Navigator.of(context).pop();
      }
    } else {
      platformFile = result.files.first;
      if (platformFile.extension == "epub") {
        try {
          epubBook = await EpubReader.readBook(File(platformFile.path).readAsBytesSync());
          textEditingController.text = epubBook.Title;
          searchItem = SearchItem(
            cover:
                "data:image/png;base64," + base64Encode(epubBook.CoverImage.getBytes()),
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
      } else {
        if (platformFile.size ~/ 1024 > 20000) {
          Utils.toast("文件太大 放弃");
          return;
        }
        try {
          content = autoReadFile(platformFile.path);
          textEditingController.text = Utils.getFileName(platformFile.name);
          if (textEditingControllerReg.text.isEmpty) {
            textEditingControllerReg.text =
                "(\\s|\\n)(第)([\\u4e00-\\u9fa5a-zA-Z0-9]{1,7})[章][^\\n]{1,35}(|\\n)\n";
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
          // final chapters = <ChapterItem>[];
          // var start = 0;
          // for (var r in RegExp(textEditingControllerReg.text).allMatches(content)) {
          //   if (r.start > 0) {
          //     if (start == 0) {
          //       chapters.add(ChapterItem(name: "书", url: "0.txt"));
          //     } else {
          //       final c = content.substring(start, r.start);
          //     }
          //     start = r.end;
          //   }
          // }
        } catch (e) {
          Utils.toast("$e");
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("添加本地"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text("已选择 ${platformFile?.path}"),
            subtitle: Text(
              "类型：${platformFile?.extension} 大小：${(platformFile?.size ?? 0) ~/ 1024}KB",
            ),
            onTap: init,
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
                Text("正则："),
                Expanded(
                  child: TextField(
                    controller: textEditingControllerReg,
                    onChanged: (value) {
                      searchItem.name = value;
                    },
                  ),
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
                        builder: (context) => SimpleChangeRule(searchItem: searchItem)));
                    if (r != null && r is SearchItem) {
                      searchItem.localAddInfo(r);
                      setState(() {});
                    } else {
                      Utils.toast("未选择");
                    }
                  },
                  child: Text("在线搜索")),
              TextButton(onPressed: () {}, child: Text("分割目录")),
              TextButton(
                onPressed: () {
                  Utils.toast("还未完成");
                  // SearchItemManager.addSearchItem(searchItem);
                },
                child: Text("导入"),
              ),
            ],
          ),
          if (searchItem != null) UiSearchItem(item: searchItem),
        ],
      ),
    );
  }
}
