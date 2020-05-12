import 'dart:async';

import 'package:eso/api/api.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/utils/input_stream.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'analyze_rule/analyze_rule.dart';
import 'analyze_rule/analyze_url.dart';

class DebugRuleBloc {
  final _dataController = StreamController<TextSpan>();
  Stream<TextSpan> get dataStream => _dataController.stream;
  StreamSink<TextSpan> get _dataSink => _dataController.sink;
  void _refreshView() {
    _dataSink.add(TextSpan(children: List.of(_texts)));
  }

  final _texts = <TextSpan>[];
  final Rule rule;
  DateTime _startTime;

  DebugRuleBloc(this.rule);

  void search(String value) async {
    _startTime = DateTime.now();
    _texts.clear();
    _beginEvent("搜索");
    try {
      final searchResult = await AnalyzeUrl.urlRuleParser(
        rule.searchUrl,
        host: rule.host,
        key: value,
      );
      final searchUrl = searchResult.request.url.toString();
      _addContent("成功获取响应, 请求地址", searchUrl, true);
      final analyzer = AnalyzeRule(
          InputStream.decode(searchResult.bodyBytes), searchUrl, rule.host);
      final searchList = await analyzer.getElements(rule.searchList);
      final resultCount = searchList.length;
      if (resultCount == 0) {
        _addContent("搜索结果列表个数为0，解析结束！");
      } else {
        _addContent("搜索结果个数", resultCount.toString());
        parseFirstSearch(searchList.first, searchUrl);
      }
    } catch (e) {
      _texts.add(TextSpan(text: "$e\n", style: TextStyle(color: Colors.red)));
      _addContent("解析结束！");
    }
  }

  void parseFirstSearch(dynamic firstItem, String baseUrl) async {
    _addContent("开始解析第一个搜索结果");
    final analyzer = AnalyzeRule(firstItem, baseUrl, rule.host);
    _addContent("名称", await analyzer.getString(rule.searchName));
    _addContent("作者", await analyzer.getString(rule.searchAuthor));
    _addContent("章节", await analyzer.getString(rule.searchChapter));
    final coverUrl = await analyzer.getString(rule.searchCover);
    _addContent("封面", coverUrl, true);
    //_texts.add(WidgetSpan(child: UIImageItem(cover: coverUrl)));
    _addContent("简介", await analyzer.getString(rule.searchDescription));
    _addContent(
        "标签", (await analyzer.getStringList(rule.searchTags)).join(", "));
    final result = await analyzer.getString(rule.searchResult);
    _addContent("结果", result);
    parseChapter(result);
  }

  void parseChapter(String result) async {
    _beginEvent("目录");
    final res = rule.chapterUrl.isNotEmpty
        ? await AnalyzeUrl.urlRuleParser(
            rule.chapterUrl,
            host: rule.host,
            result: result,
          )
        : await AnalyzeUrl.urlRuleParser(result, host: rule.host);
    final chapterUrl = res.request.url.toString();
    _addContent("成功获取响应, 请求地址", chapterUrl, true);
    final reversed = rule.chapterList.startsWith("-");
    if (reversed) {
      _addContent("检测规则以\"-\"开始, 结果将反序");
    }
    final chapterList = await AnalyzeRule(
      InputStream.decode(res.bodyBytes),
      chapterUrl,
      rule.host,
    ).getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
    final count = chapterList.length;
    if (count == 0) {
      _addContent("章节列表个数为0，解析结束！");
    } else {
      _addContent("章节个数", count.toString());
      parseFirstChapter(
          reversed ? chapterList.last : chapterList.first, chapterUrl);
    }
  }

  void parseFirstChapter(dynamic firstItem, String baseUrl) async {
    _addContent("开始解析第一个章节");
    final analyzer = AnalyzeRule(firstItem, baseUrl, rule.host);
    final name = await analyzer.getString(rule.chapterName);
    _addContent("名称(解析)", name);
    final lock = await analyzer.getString(rule.chapterLock);
    _addContent("lock标志", lock);
    if (lock != null &&
        lock.isNotEmpty &&
        lock != "undefined" &&
        lock != "false") {
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
    praseContent(result);
  }

  void praseContent(String result) async {
    _beginEvent("正文");
    final res = rule.chapterUrl.isNotEmpty
        ? await AnalyzeUrl.urlRuleParser(
            rule.contentUrl,
            host: rule.host,
            result: result,
          )
        : await AnalyzeUrl.urlRuleParser(result, host: rule.host);
    final contentUrl = res.request.url.toString();
    _addContent("成功获取响应, 请求地址", contentUrl, true);
    final contentItems = await AnalyzeRule(
      InputStream.decode(res.bodyBytes),
      contentUrl,
      rule.host,
    ).getStringList(rule.contentItems);
    final count = contentItems.length;
    if (count == 0) {
      _addContent("正文结果个数为0，解析结束！");
    } else {
      _addContent("正文解析成功, 结果个数", count.toString());
      final isUrl = rule.contentType == API.MANGA;
      _texts.add(_buildDetailsText("• [序号]: 内容\n"));
      for (int i = 0; i < count; i++) {
        final ii = (i + 1).toString();
        _texts.add(_buildDetailsText("• [${'0' * (3 - ii.length)}$ii]: "));
        _texts.add(_buildDetailsText("${contentItems[i]}\n", isUrl));
      }
      _refreshView();
    }
  }

  void _beginEvent(String s) {
    _texts.add(_buildBigText("★ $s测试  "));
    _texts.add(
        _buildDetailsText(DateFormat("MM-dd HH:mm:ss").format(DateTime.now())));
    _addNewLine();
    _addContent("$s解析开始");
  }

  void _addContent(String sInfo, [String s, bool isUrl = false]) {
    final d = DateTime.now().difference(_startTime).inMicroseconds;
    _texts.add(_buildDetailsText(
        "• [${DateFormat("mm:ss.SSS").format(DateTime.fromMicrosecondsSinceEpoch(d))}] $sInfo"));
    if (null != s) {
      _texts.add(_buildDetailsText(": "));
      _texts.add(_buildDetailsText("$s", isUrl));
    }
    _addNewLine();
    _refreshView();
  }

  void _addNewLine() {
    _texts.add(TextSpan(text: "\n"));
  }

  void close() {
    _dataSink.close();
    _dataController.close();
  }

  TextSpan _buildBigText(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  TextSpan _buildDetailsText(String text, [bool isUrl = false]) {
    if (isUrl) {
      return TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 14,
          height: 2,
          decorationStyle: TextDecorationStyle.solid,
          decoration: TextDecoration.underline,
          color: Colors.blue,
        ),
        recognizer: (TapGestureRecognizer()..onTap = () => launch(text)),
      );
    }
    return TextSpan(
      text: text,
      style: TextStyle(fontSize: 14, height: 2),
    );
  }
}
