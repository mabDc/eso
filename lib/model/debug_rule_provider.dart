import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/model/profile.dart';
import 'package:flutter/services.dart';
import '../api/analyze_url.dart';
import '../api/analyzer_manager.dart';
import 'package:eso/utils/decode_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global.dart';

class DebugRuleProvider with ChangeNotifier {
  DateTime _startTime;
  final Rule rule;
  final Color textColor;
  bool disposeFlag;

  DebugRuleProvider(this.rule, this.textColor) {
    disposeFlag = false;
  }

  final rows = <Row>[];
  @override
  void dispose() {
    rows.clear();
    disposeFlag = true;
    super.dispose();
  }

  Widget _buildText(String s, [bool isUrl = false]) {
    return Flexible(
      child: isUrl
          ? GestureDetector(
              onTap: () => launch(s),
              onLongPress: () => Clipboard.setData(ClipboardData(text: s)),
              child: Text(
                s,
                style: TextStyle(
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                  height: 2,
                ),
              ),
            )
          : SelectableText(s, style: TextStyle(height: 2)),
    );
  }

  void _addContent(String sInfo, [String s, bool isUrl = false]) {
    final d = DateTime.now().difference(_startTime).inMicroseconds;
    rows.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "• [${DateFormat("mm:ss.SSS").format(DateTime.fromMicrosecondsSinceEpoch(d))}] $sInfo${s == null ? "" : ": "}",
          style: TextStyle(color: textColor.withOpacity(0.5), height: 2),
        ),
        _buildText(s ?? "", isUrl),
      ],
    ));
    notifyListeners();
  }

  void _beginEvent(String s) {
    rows.add(Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "★ $s测试  ",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: Profile.fontFamily,
            height: 2,
          ),
        ),
        SelectableText(
          DateFormat("MM-dd HH:mm:ss").format(DateTime.now()),
          style: TextStyle(height: 2),
        ),
      ],
    ));
    _addContent("$s解析开始");
  }

  void discover() async {
    _startTime = DateTime.now();
    rows.clear();
    _beginEvent("发现");
    final engineId = await FlutterJs.initEngine();
    try {
      var discoverRule = rule.discoverUrl.trimLeft();
      if (discoverRule.startsWith("@js:")) {
        _addContent("开始执行发现js规则");
        final engineId = await FlutterJs.initEngine();
        await FlutterJs.evaluate(
            "cookie = ${jsonEncode(rule.cookies)}; host = ${jsonEncode(rule.host)};",
            engineId);
        discoverRule = "${await FlutterJs.evaluate(discoverRule.substring(4), engineId)}";
        _addContent("执行完成，结果如下\n" + discoverRule);
      }
      final discoverResult = await AnalyzeUrl.urlRuleParser(
        discoverRule.split(RegExp(r"\n+|&&")).first.split("::").last,
        rule,
        page: 1,
        pageSize: 20,
      );
      if (discoverResult.contentLength == 0) {
        _addContent("响应内容为空，终止解析！");
        FlutterJs.close(engineId);
        return;
      }
      final discoverUrl = discoverResult.request.url.toString();
      _addContent("地址", discoverUrl, true);
      await FlutterJs.evaluate(
          "cookie = ${jsonEncode(rule.cookies)}; host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(discoverUrl)};",
          engineId);
      if (rule.loadJs.trim().isNotEmpty || rule.useCryptoJS) {
        final cryptoJS =
            rule.useCryptoJS ? await rootBundle.loadString(Global.cryptoJSFile) : "";
        await FlutterJs.evaluate(cryptoJS + rule.loadJs, engineId);
      }
      _addContent("js预加载");
      final analyzer = AnalyzerManager(
          DecodeBody()
              .decode(discoverResult.bodyBytes, discoverResult.headers["content-type"]),
          engineId);
      final discoverList = await analyzer.getElements(rule.discoverList);
      final resultCount = discoverList.length;
      if (resultCount == 0) {
        FlutterJs.close(engineId);
        _addContent("发现结果列表个数为0，解析结束！");
      } else {
        _addContent("发现结果个数", resultCount.toString());
        parseFirstDiscover(discoverList.first, engineId);
      }
    } catch (e) {
      FlutterJs.close(engineId);
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          ),
        ],
      ));
      _addContent("解析结束！");
    }
  }

  final tagsSplitRegExp = RegExp(r"[　 ,\|\&\%]+");

  void parseFirstDiscover(dynamic firstItem, int engineId) async {
    _addContent("开始解析第一个结果");
    try {
      final analyzer = AnalyzerManager(firstItem, engineId);
      _addContent("名称", await analyzer.getString(rule.discoverName));
      _addContent("作者", await analyzer.getString(rule.discoverAuthor));
      _addContent("章节", await analyzer.getString(rule.discoverChapter));
      final coverUrl = await analyzer.getString(rule.discoverCover);
      _addContent("封面", coverUrl, true);
      //_texts.add(WidgetSpan(child: UIImageItem(cover: coverUrl)));
      _addContent("简介", await analyzer.getString(rule.discoverDescription));
      _addContent(
          "标签",
          ((await analyzer.getString(rule.discoverTags)).split(tagsSplitRegExp)
                ..removeWhere((tag) => tag.isEmpty))
              .join(", "));
      final result = await analyzer.getString(rule.discoverResult);
      _addContent("结果", result);
      await FlutterJs.close(engineId);
      parseChapter(result);
    } catch (e) {
      FlutterJs.close(engineId);
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          )
        ],
      ));
      _addContent("解析结束！");
    }
  }

  void search(String value) async {
    _startTime = DateTime.now();
    rows.clear();
    final engineId = await FlutterJs.initEngine();
    _addContent("js初始化");
    try {
      final searchResult = await AnalyzeUrl.urlRuleParser(
        rule.searchUrl,
        rule,
        keyword: value,
        page: 1,
        pageSize: 20,
      );
      if (searchResult.contentLength == 0) {
        _addContent("响应内容为空，终止解析！");
        FlutterJs.close(engineId);
        return;
      }
      final searchUrl = searchResult.request.url.toString();
      _addContent("地址", searchUrl, true);
      await FlutterJs.evaluate(
          "cookie = ${jsonEncode(rule.cookies)}; host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(searchUrl)};",
          engineId);
      if (rule.loadJs.trim().isNotEmpty || rule.useCryptoJS) {
        final cryptoJS =
            rule.useCryptoJS ? await rootBundle.loadString(Global.cryptoJSFile) : "";
        await FlutterJs.evaluate(cryptoJS + rule.loadJs, engineId);
      }
      _addContent("js预加载");
      final analyzer = AnalyzerManager(
          DecodeBody()
              .decode(searchResult.bodyBytes, searchResult.headers["content-type"]),
          engineId);
      final searchList = await analyzer.getElements(rule.searchList);
      final resultCount = searchList.length;
      if (resultCount == 0) {
        FlutterJs.close(engineId);
        _addContent("搜索结果列表个数为0，解析结束！");
      } else {
        _addContent("搜索结果个数", resultCount.toString());
        parseFirstSearch(searchList.first, engineId);
      }
    } catch (e) {
      FlutterJs.close(engineId);
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          ),
        ],
      ));
      _addContent("解析结束！");
    }
  }

  void parseFirstSearch(dynamic firstItem, int engineId) async {
    _addContent("开始解析第一个结果");
    try {
      final analyzer = AnalyzerManager(firstItem, engineId);
      _addContent("名称", await analyzer.getString(rule.searchName));
      _addContent("作者", await analyzer.getString(rule.searchAuthor));
      _addContent("章节", await analyzer.getString(rule.searchChapter));
      final coverUrl = await analyzer.getString(rule.searchCover);
      _addContent("封面", coverUrl, true);
      //_texts.add(WidgetSpan(child: UIImageItem(cover: coverUrl)));
      _addContent("简介", await analyzer.getString(rule.searchDescription));
      _addContent(
          "标签",
          ((await analyzer.getString(rule.searchTags)).split(tagsSplitRegExp)
                ..removeWhere((tag) => tag.isEmpty))
              .join(", "));
      final result = await analyzer.getString(rule.searchResult);
      _addContent("结果", result);
      await FlutterJs.close(engineId);
      parseChapter(result);
    } catch (e) {
      FlutterJs.close(engineId);
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          )
        ],
      ));
      _addContent("解析结束！");
    }
  }

  void parseChapter(String result) async {
    _beginEvent("目录");
    final engineId = await FlutterJs.initEngine();
    dynamic firstChapter;
    for (var page = 1;; page++) {
      if (disposeFlag) return;
      final chapterUrlRule = rule.chapterUrl.isNotEmpty ? rule.chapterUrl : result;
      if (page > 1) {
        if (!chapterUrlRule.contains("page")) {
          break;
        } else {
          _addContent("解析第$page页");
        }
      }
      try {
        final res = await AnalyzeUrl.urlRuleParser(
          chapterUrlRule,
          rule,
          result: result,
          page: page,
        );
        if (res.contentLength == 0) {
          _addContent("响应内容为空，终止解析！");
          break;
        }
        final chapterUrl = res.request.url.toString();
        _addContent("地址", chapterUrl, true);
        final reversed = rule.chapterList.startsWith("-");
        if (reversed) {
          _addContent("检测规则以\"-\"开始, 结果将反序");
        }
        await FlutterJs.evaluate(
            "cookie = ${jsonEncode(rule.cookies)}; host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(chapterUrl)}; lastResult = ${jsonEncode(result)}",
            engineId);
        if (rule.loadJs.trim().isNotEmpty || rule.useCryptoJS) {
          final cryptoJS =
              rule.useCryptoJS ? await rootBundle.loadString(Global.cryptoJSFile) : "";
          await FlutterJs.evaluate(cryptoJS + rule.loadJs, engineId);
        }
        final chapterList = await AnalyzerManager(
                DecodeBody().decode(res.bodyBytes, res.headers["content-type"]), engineId)
            .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
        final count = chapterList.length;
        if (count == 0) {
          _addContent("章节列表个数为0，解析结束！");
          break;
        } else {
          _addContent("章节结果个数", count.toString());
          if (firstChapter == null) {
            firstChapter = reversed ? chapterList.last : chapterList.first;
          }
        }
      } catch (e) {
        rows.add(Row(
          children: [
            Flexible(
              child: SelectableText(
                "$e\n",
                style: TextStyle(color: Colors.red, height: 2),
              ),
            )
          ],
        ));
        _addContent("解析结束！");
        break;
      }
    }
    if (firstChapter != null) {
      parseFirstChapter(firstChapter, engineId);
    } else {
      FlutterJs.close(engineId);
    }
  }

  void parseFirstChapter(dynamic firstItem, int engineId) async {
    _addContent("开始解析第一个结果");
    try {
      final analyzer = AnalyzerManager(firstItem, engineId);
      final name = await analyzer.getString(rule.chapterName);
      _addContent("名称(解析)", name);
      final lock = await analyzer.getString(rule.chapterLock);
      _addContent("lock标志", lock);
      if (lock != null && lock.isNotEmpty && lock != "undefined" && lock != "false") {
        _addContent("名称(显示)", "🔒" + name);
      } else {
        _addContent("名称(显示)", name);
      }
      _addContent("时间", await analyzer.getString(rule.chapterTime));
      final coverUrl = await analyzer.getString(rule.chapterCover);
      _addContent("封面", coverUrl, true);
      //_texts.add(WidgetSpan(child: UIImageItem(cover: coverUrl)));
      final result = await analyzer.getString(rule.chapterResult);
      _addContent("结果", result);
      await FlutterJs.close(engineId);
      praseContent(result);
    } catch (e) {
      FlutterJs.close(engineId);
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          )
        ],
      ));
      _addContent("解析结束！");
    }
  }

  void praseContent(String result) async {
    _beginEvent("正文");
    final engineId = await FlutterJs.initEngine();
    for (var page = 1;; page++) {
      if (disposeFlag) return;
      final contentUrlRule = rule.contentUrl.isNotEmpty ? rule.contentUrl : result;
      if (page > 1) {
        if (!contentUrlRule.contains("page")) {
          FlutterJs.close(engineId);
          return;
        } else {
          _addContent("解析第$page页");
        }
      }
      try {
        final res = await AnalyzeUrl.urlRuleParser(
          contentUrlRule,
          rule,
          result: result,
          page: page,
        );
        if (res.contentLength == 0) {
          _addContent("响应内容为空，终止解析！");
          FlutterJs.close(engineId);
          return;
        }
        final contentUrl = res.request.url.toString();
        _addContent("地址", contentUrl, true);
        if (rule.contentItems.contains("@js:")) {
          await FlutterJs.evaluate(
              "cookie = ${jsonEncode(rule.cookies)}; host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(contentUrl)}; lastResult = ${jsonEncode(result)};",
              engineId);
          if (rule.loadJs.trim().isNotEmpty || rule.useCryptoJS) {
            final cryptoJS =
                rule.useCryptoJS ? await rootBundle.loadString(Global.cryptoJSFile) : "";
            await FlutterJs.evaluate(cryptoJS + rule.loadJs, engineId);
          }
        }
        var contentItems = await AnalyzerManager(
                DecodeBody().decode(res.bodyBytes, res.headers["content-type"]), engineId)
            .getStringList(rule.contentItems);
        if (rule.contentType == API.NOVEL) {
          contentItems = contentItems.join("\n").split(RegExp(r"\n\s*|\s{2,}"));
        }
        final count = contentItems.length;
        if (count == 0) {
          _addContent("正文结果个数为0，解析结束！");
          FlutterJs.close(engineId);
          return;
        } else if (contentItems.join().trim().isEmpty) {
          _addContent("正文内容为空，解析结束！");
          FlutterJs.close(engineId);
          return;
        } else {
          _addContent("正文结果个数", count.toString());
          final isUrl = rule.contentType == API.MANGA ||
              rule.contentType == API.AUDIO ||
              rule.contentType == API.VIDEO;
          for (int i = 0; i < count; i++) {
            rows.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• [${'0' * (3 - i.toString().length)}$i]: ",
                  style: TextStyle(color: textColor.withOpacity(0.5), height: 2),
                ),
                _buildText(contentItems[i], isUrl),
              ],
            ));
          }
          notifyListeners();
        }
      } catch (e) {
        rows.add(Row(
          children: [
            Flexible(
              child: SelectableText(
                "$e\n",
                style: TextStyle(color: Colors.red, height: 2),
              ),
            )
          ],
        ));
        _addContent("解析结束！");
        FlutterJs.close(engineId);
        return;
      }
    }
  }
}
