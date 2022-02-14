import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:http/http.dart';

import '../utils/decode_body.dart';
import 'const.dart';
import '../api/analyze_url_client.dart' as http;

class Request extends StatelessWidget {
  const Request({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          TextField(
            decoration: const InputDecoration(labelText: "链接"),
            controller: data.url,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "用户代理字符串（UserAgent）"),
            controller: data.ua,
            maxLines: 5,
            minLines: 1,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "请求方法（method）"),
            controller: data.method,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "请求头（headers）暂未开放"),
            controller: data.headers,
            enabled: false,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "请求体（body or payload）"),
            controller: data.body,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "小饼干（cookies）"),
            controller: data.cookies,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "编码（charset or encode）"),
            controller: data.encode,
          ),
          Wrap(
            children: [
              TextButton(
                onPressed: () async {
                  var u = data.url.text.trim();
                  var method = data.method.text.trim();
                  Map<String, String> headers = {
                    'user-agent': data.ua.text.trim().isNotEmpty
                        ? data.ua.text
                        : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36',
                  };
                  if (data.cookies.text.trim().isNotEmpty) {
                    headers["cookie"] = data.cookies.text;
                  }

                  if (data.encode.text.trim().isNotEmpty) {
                    String _urlEncode(String s) {
                      if (s.length % 2 == 1) {
                        s = '0$s';
                      }
                      final sb = StringBuffer();
                      for (int i = 0; i < s.length; i += 2) {
                        sb.write('%${s[i]}${s[i + 1]}');
                      }
                      return sb.toString();
                    }

                    final encoding = data.encode.text.contains("gb")
                        ? gbk
                        : Encoding.getByName(data.encode.text) ?? const Utf8Codec();
                    u = u.replaceAllMapped(
                        RegExp(r"[^\x00-\x7F]+"),
                        (match) => encoding
                            .encode(match.group(0))
                            .map((code) =>
                                _urlEncode(code.toRadixString(16).toUpperCase()))
                            .join());
                  }
                  Response res;
                  if (method.isNotEmpty || method == 'get') {
                    res = await http.get(u, headers: headers);
                  }
                  if (method == "put") {
                    res = await http.put(u, headers: headers, body: data.body.text);
                  }
                  if (method == 'post') {
                    res = await http.post(
                      u,
                      headers: headers,
                      body: data.body.text,
                    );
                  }
                  res ??= await http.get(u, headers: headers);
                  data.html.text =
                      DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
                },
                child: const Text("请求"),
              ),
              TextButton(
                onPressed: () {
                  var u = data.url.text.trim();
                  var b = data.body.text.trim();
                  var m = data.method.text.trim().toUpperCase();
                  var e = data.encode.text.trim().toLowerCase();
                  var c = data.cookies.text.trim().toLowerCase();
                  var ua = data.ua.text.trim().toLowerCase();
                  if (e.isEmpty || e.contains("utf8")) {
                    e = "utf-8";
                  } else if (e.contains("gb")) {
                    e = "gbk";
                  }
                  if (m.isEmpty) m = "GET";
                  if (m == "GET" && b.isNotEmpty) {
                    u = u.contains("?") ? "$u&$b" : "$u?$b";
                    b = "";
                  }
                  data.string.text = """$u,{
  "method": "$m",${e == "utf-8" ? "" : '\n  "charset": "$e",'}${b.isEmpty ? "" : '\n  "body": "$b",'}
  "headers": {${c.isEmpty ? "" : '\n    "cookie": "$c",'}
    "user-agent": "$ua"
  }
}""";
                },
                child: const Text("生成阅读"),
              ),
              TextButton(
                onPressed: () {
                  var u = data.url.text.trim();
                  var b = data.body.text.trim();
                  var m = data.method.text.trim().toUpperCase();
                  var e = data.encode.text.trim().toLowerCase();
                  var c = data.cookies.text.trim().toLowerCase();
                  var ua = data.ua.text.trim().toLowerCase();
                  if (e.isEmpty || e.contains("utf8")) {
                    e = "utf-8";
                  } else if (e.contains("gb")) {
                    e = "gbk";
                  }
                  if (m.isEmpty) m = "GET";
                  if (m == "GET" && b.isNotEmpty) {
                    u = u.contains("?") ? "$u&$b" : "$u?$b";
                    b = "";
                  }
                  data.string.text = """
{
  "url": "$u",
  "method": "$m",${e == "utf-8" ? "" : '\n  "encoding": "$e",'}${b.isEmpty ? "" : '\n  "body": "$b",'}
  "headers": {${c.isEmpty ? "" : '\n    "cookie": "$c",'}${b.isEmpty || m == "GET" ? "" : '\n    "content-type": "application/x-www-form-urlencoded",'}
    "user-agent": "$ua"
  }
}""";
                },
                child: const Text("生成亦搜"),
              ),
              const TextButton(
                onPressed: null,
                child: Text("解析"),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: data.string.text));
                },
                child: const Text("复制"),
              ),
              TextButton(
                onPressed: () async {
                  final a = await Clipboard.getData(Clipboard.kTextPlain);
                  if (a?.text != null) data.string.text = a.text;
                },
                child: const Text("粘贴"),
              ),
            ],
          ),
          TextField(
            minLines: 1,
            maxLines: 15,
            controller: data.string,
            decoration: const InputDecoration(labelText: "生成结果"),
          ),
        ],
      ),
    );
  }
}
