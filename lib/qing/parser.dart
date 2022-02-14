import 'package:eso/api/analyzer_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'const.dart';

class Parser extends StatelessWidget {
  const Parser({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          TextField(
            decoration: const InputDecoration(labelText: "请求结果与解析目标"),
            controller: data.html,
            maxLines: 15,
            minLines: 1,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "规则"),
            controller: data.rule,
            maxLines: 15,
            minLines: 1,
          ),
          TextField(
            decoration: const InputDecoration(labelText: "规则缓存"),
            controller: data.cache,
            maxLines: 15,
            minLines: 1,
          ),
          Wrap(
            children: [
              TextButton(
                onPressed: () async {
                  final s =
                      await AnalyzerManager(data.html.text).getElements(data.rule.text);
                  data.result.text = "$s";
                },
                child: const Text("解析列表"),
              ),
              TextButton(
                onPressed: () async {
                  final s =
                      await AnalyzerManager(data.html.text).getString(data.rule.text);
                  data.result.text = s;
                },
                child: const Text("解析字符串"),
              ),
              TextButton(
                onPressed: () async {
                  final s =
                      await AnalyzerManager(data.html.text).getStringList(data.rule.text);
                  data.result.text = "$s";
                },
                child: const Text("解析字符串数组"),
              ),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: data.rule.text));
                },
                child: const Text("复制规则"),
              ),
              TextButton(
                onPressed: () {
                  data.cache.text = data.rule.text;
                  data.rule.text = "";
                },
                child: const Text("写入缓存并清空"),
              ),
              TextButton(
                onPressed: () {
                  data.rule.text = data.cache.text;
                },
                child: const Text("使用缓存"),
              ),
            ],
          ),
          TextField(
            decoration: const InputDecoration(labelText: "解析结果"),
            controller: data.result,
            maxLines: 15,
            minLines: 1,
          ),
        ],
      ),
    );
  }
}
