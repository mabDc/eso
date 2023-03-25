import 'dart:convert';
import 'dart:io';

import 'package:eso/eso_theme.dart';
import 'package:eso/page/hidden/linyuan_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../api/analyzer_html.dart';
import '../main.dart';
import '../utils.dart';

class SharePage extends HookWidget {
  final String text;
  final String addInfo;
  final String fileName;
  const SharePage(
      {Key key, @required this.text, @required this.addInfo, @required this.fileName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final share = useTextEditingController(text: text);
    share.text = text;
    final netcut = useTextEditingController(text: Uuid().v4());
    String id;
    return Container(
      decoration: globalDecoration,
      child: Scaffold(
        appBar: AppBar(title: Text("规则复制或分享")),
        body: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            TextField(
              controller: share,
              maxLines: 12,
              decoration: InputDecoration(
                // labelText: "规则内容",
                helperText: addInfo,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Wrap(
              children: [
                TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      Utils.toast("已保存到剪贴板 $addInfo");
                    },
                    child: Text("复制文本"),
                    style:
                        ButtonStyle(fixedSize: MaterialStateProperty.all(Size(100, 30)))),
                TextButton(
                    onPressed: () {
                      Share.share(text);
                    },
                    child: Text("分享文本"),
                    style:
                        ButtonStyle(fixedSize: MaterialStateProperty.all(Size(100, 30)))),
                TextButton(
                    onPressed: () async {
                      // 生成文件
                      final temp = await getTemporaryDirectory();
                      final file = Utils.join(temp.path, fileName + ".json");
                      File(file).writeAsStringSync(text);
                      // 分享文件
                      Share.shareFiles([file]);
                    },
                    child: Text("分享文件"),
                    style:
                        ButtonStyle(fixedSize: MaterialStateProperty.all(Size(100, 30)))),
              ],
            ),
            Divider(),
            ListTile(
              title: Text("分享至在线剪贴板netcut.cn"),
              onTap: () {
                Utils.startPageWait(
                    context,
                    LaunchUrlWithWebview(
                        title: "在线剪贴板", url: "https://netcut.cn/${netcut.text}"));
              },
            ),
            TextField(
              controller: netcut,
              decoration: InputDecoration(
                  icon: Icon(Icons.abc_rounded),
                  prefixText: "名称或id：",
                  helperMaxLines: 2,
                  helperText: "允许填写个性签名，如esoMabdc，请使用至少六位字母或数字，不要填入特殊符号",
                  labelText: "https://netcut.cn/"),
            ),
            Wrap(
              children: [
                TextButton(
                    onPressed: () async {
                      if (netcut.text.length < 6) {
                        Utils.toast("错误 名称至少六个字符");
                        return;
                      }
                      if (id == null || id.isEmpty) {
                        final u = "https://netcut.cn/${netcut.text}";
                        final res = await http.get(Uri.parse(u));
                        final ids = AnalyzerHtml()
                            .parse(res.body)
                            .getString("body[data-id]@data-id");
                        if (ids.isEmpty) {
                          final res = await http.post(
                              Uri.parse("https://netcut.cn/api/note/create/"),
                              body: {
                                "note_name": "${netcut.text}",
                                "note_content": text,
                                "note_pwd": "0",
                                "expire_time": "259200",
                              });
                          id = cast(jsonDecode(res.body)["data"]["note_id"], "");
                          Utils.toast("数据上传成功");
                        } else {
                          id = ids.first.trim();
                          await http.post(Uri.parse("https://netcut.cn/api/note/update/"),
                              body: {
                                "note_id": "$id",
                                "note_content": text,
                              });
                          Utils.toast("数据上传成功");
                        }
                      } else {
                        await http
                            .post(Uri.parse("https://netcut.cn/api/note/update/"), body: {
                          "note_id": "$id",
                          "note_content": text,
                        });
                        Utils.toast("数据上传成功");
                      }
                    },
                    child: Text("上传"),
                    style:
                        ButtonStyle(fixedSize: MaterialStateProperty.all(Size(100, 30)))),
                TextButton(
                    onPressed: () {
                      final s = """ESO APP 规则分享
    $addInfo
    内容见在线剪贴板，非盈利网站，请不要滥用
    https://netcut.cn/${netcut.text}""";
                      Clipboard.setData(ClipboardData(text: s));
                      Utils.toast("已保存到剪贴板 $s");
                    },
                    child: Text("复制网址"),
                    style:
                        ButtonStyle(fixedSize: MaterialStateProperty.all(Size(100, 30)))),
                TextButton(
                    onPressed: () {
                      final s = """ESO APP 复杂分享
    $addInfo
    内容见在线剪贴板，非盈利网站，请不要滥用
    https://netcut.cn/${netcut.text}""";
                      Share.share(s);
                    },
                    child: Text("分享网址"),
                    style:
                        ButtonStyle(fixedSize: MaterialStateProperty.all(Size(100, 30)))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
