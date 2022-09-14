import 'dart:convert';

import 'package:eso/eso_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../api/analyzer_html.dart';
import '../utils.dart';

class SharePage extends HookWidget {
  final text;
  final addInfo;
  const SharePage({Key key, @required this.text, @required this.addInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final share = useTextEditingController(text: text);
    final netcut = useTextEditingController(text: Uuid().v4());
    String id;
    return Scaffold(
      appBar: AppBar(title: Text("复杂分享")),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          TextField(
            controller: share,
            maxLines: 12,
            decoration: InputDecoration(
              labelText: "规则内容",
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
                  child: Text("复制"),
                  style:
                      ButtonStyle(fixedSize: MaterialStateProperty.all(Size(100, 30)))),
              TextButton(
                  onPressed: () {
                    Share.share(text);
                  },
                  child: Text("分享"),
                  style:
                      ButtonStyle(fixedSize: MaterialStateProperty.all(Size(100, 30)))),
            ],
          ),
          ListTile(
            title: Text("分享至https://netcut.cn/"),
            subtitle: Text("点击跳转至网页查看剪贴板"),
            onTap: () {
              launchUrl(Uri.parse("https://netcut.cn/${netcut.text}"));
            },
          ),
          TextField(
            controller: netcut,
            decoration: InputDecoration(
                icon: Icon(Icons.abc_rounded),
                helperText: "剪贴板名称，不妨自己填写个性签名，如esoMabdc\n请使用至少六位字母或数字，不要填入特殊符号",
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
                        final res = await http
                            .post(Uri.parse("https://netcut.cn/api/note/create/"), body: {
                          "note_name": "${netcut.text}",
                          "note_content": text,
                          "note_pwd": "0",
                          "expire_time": "259200",
                        });
                        id = cast(jsonDecode(res.body)["data"]["note_id"], "");
                        Utils.toast("数据上传成功");
                      } else {
                        id = ids.first.trim();
                        await http
                            .post(Uri.parse("https://netcut.cn/api/note/update/"), body: {
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
                    final s = """ESO APP 复杂分享
$addInfo
内容见在线剪贴板，非盈利网站，请不要滥用
https://netcut.cn/${netcut.text}""";
                    Clipboard.setData(ClipboardData(text: s));
                    Utils.toast("已保存到剪贴板 $s");
                  },
                  child: Text("复制"),
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
                  child: Text("分享"),
                  style:
                      ButtonStyle(fixedSize: MaterialStateProperty.all(Size(100, 30)))),
            ],
          ),
        ],
      ),
    );
  }
}
