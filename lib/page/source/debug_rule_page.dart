import 'dart:async';

import 'package:eso/database/rule.dart';
import 'package:eso/model/analyze_rule/analyze_rule.dart';
import 'package:eso/model/analyze_rule/analyze_url.dart';
import 'package:eso/utils/input_stream.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DebugRulePage extends StatefulWidget {
  final Rule rule;
  DebugRulePage({this.rule, Key key}) : super(key: key);

  @override
  _DebugRulePageState createState() => _DebugRulePageState();
}

class _DebugRulePageState extends State<DebugRulePage> {
  DebugHelper _debugHelper;
  @override
  void dispose() {
    _debugHelper.close();
    super.dispose();
  }

  @override
  void initState() {
    _debugHelper = DebugHelper(widget.rule);
    super.initState();
  }

  Widget _buildTextField() {
    return TextField(
      onSubmitted: _debugHelper.search,
      cursorColor: Theme.of(context).primaryTextTheme.headline6.color,
      style: TextStyle(
        color: Theme.of(context).primaryTextTheme.headline6.color,
      ),
      autofocus: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryTextTheme.headline6.color,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryTextTheme.headline6.color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildTextField(),
      ),
      body: StreamBuilder<List<TextSpan>>(
        stream: _debugHelper.dataStream, //stream,
        // initialData: <TextSpan>[
        //   TextSpan(text: "请输入关键词开始搜索", style: TextStyle(fontSize: 20))
        // ],
        builder:
            (BuildContext context, AsyncSnapshot<List<TextSpan>> snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: Text("请输入关键词开始搜索"),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SelectableText.rich(
              TextSpan(children: List.from(snapshot.data)),
            ),
          );
        },
      ),
    );
  }
}

class DebugHelper {
  final _dataController = StreamController<List<TextSpan>>();
  StreamSink<List<TextSpan>> get _dataSink => _dataController.sink;
  Stream<List<TextSpan>> get dataStream => _dataController.stream;
  StreamSubscription _dataSubscription;
  final _texts = <TextSpan>[];
  final Rule rule;
  DateTime _startTime;
  DebugHelper(this.rule);
  // init() {
  //   ///监听事件
  //   _dataSubscription = dataStream.listen((value) {
  //     ///do change
  //   });

  //   ///改变事件
  //   _dataSink.add([TextSpan(text: "11")]);
  // }
  void search(String value) async {
    _startTime = DateTime.now();
    _texts.clear();
    _addTitle("搜索测试");
    _addContent("搜索开始");
    _dataSink.add(_texts);
    try {
      final searchResult = await AnalyzeUrl.urlRuleParser(
        rule.searchUrl,
        host: rule.host,
        key: value,
      );
      final searchUrl = searchResult.request.url.toString();
      _addContent("成功获取响应，搜索地址", searchUrl, true);
      _dataSink.add(_texts);
      final analyzer = AnalyzeRule(
          InputStream.decode(searchResult.bodyBytes), searchUrl, rule.host);
      final searchList = await analyzer.getElements(rule.searchList);
      final resultCount = searchList.length;
      if (resultCount == 0) {
        _addContent("搜索结果列表个数为0，解析结束！");
      } else {
        _addContent("搜索结果个数", resultCount.toString());
        _addContent("开始解析第一个搜索结果");
      }
    } catch (e) {
      _texts.add(TextSpan(text: "$e", style: TextStyle(color: Colors.red)));
      _dataSink.add(_texts);
    }
  }

  void _addContent(String sInfo, [String s = '', bool isUrl = false]) {
    final d = DateTime.now().difference(_startTime).inMicroseconds;
    _texts.add(_buildDetailsText(
        "• [${DateFormat("mm:ss.SSS").format(DateTime.fromMicrosecondsSinceEpoch(d))}] $sInfo"));
    if (s.isNotEmpty) {
      _texts.add(_buildDetailsText(": "));
      _texts.add(_buildDetailsText("$s", isUrl));
    }
    _addNewLine();
  }

  void _addNewLine() {
    _texts.add(TextSpan(text: "\n"));
  }

  void _addTitle(String s) {
    _texts.add(_buildBigText("★ $s  "));
    _texts.add(
        _buildDetailsText(DateFormat("MM-dd HH:mm:ss").format(DateTime.now())));
    _addNewLine();
  }

  close() {
    _dataSubscription.cancel();
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
          fontSize: 12,
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
      style: TextStyle(fontSize: 12, height: 2),
    );
  }

  // Future<bool> parseSearch() async {
  //   final DateTime now = new DateTime.now();
  //   // searchDebugReport.removeRange(1, searchDebugReport.length);
  //   // chapterDebugReport.removeRange(1, searchDebugReport.length);
  //   // contentDebugReport.removeRange(1, searchDebugReport.length);
  //   setState(() {
  //     searchDebugReport.add("• [00:00.000] 搜索开始");
  //   });
  //   final searchResult = await AnalyzeUrl.urlRuleParser(
  //     widget.rule.searchUrl,
  //     host: widget.rule.host,
  //     key: _controller.text,
  //   );
  //   final baseUrl = searchResult.request.url.toString();
  //   setState(() {
  //     searchDebugReport.add("• 搜索地址: " + baseUrl);
  //   });
  //   final analyzer = AnalyzeRule(
  //       utf8.decode(searchResult.bodyBytes), baseUrl, widget.rule.host);
  //   final searchList = await analyzer.getElements(widget.rule.searchList);
  //   final resultCount = searchList.length;
  //   if (resultCount == 0) {
  //     setState(() {
  //       searchDebugReport.add("• 搜索结果列表个数为0，解析结束！");
  //     });
  //     return false;
  //   }
  //   setState(() {
  //     searchDebugReport.add("• 搜索结果列表个数: " + resultCount.toString());
  //     searchDebugReport.add("• 开始解析第一个搜索结果");
  //   });
  //   return parseFirstSearchResult(searchList.first, baseUrl, now);
  // }

  // Future<bool> parseFirstSearchResult(
  //     dynamic first, String baseUrl, DateTime now) async {
  //   try {
  //     final analyzer = AnalyzeRule(first, baseUrl, widget.rule.host);
  //     searchDebugReport
  //         .add("• 名称: " + await analyzer.getString(widget.rule.searchName));
  //     searchDebugReport
  //         .add("• 作者: " + await analyzer.getString(widget.rule.searchAuthor));
  //     searchDebugReport
  //         .add("• 封面: " + await analyzer.getString(widget.rule.searchCover));
  //     searchDebugReport
  //         .add("• 章节: " + await analyzer.getString(widget.rule.searchChapter));
  //     searchDebugReport.add(
  //         "• 简介: " + await analyzer.getString(widget.rule.searchDescription));
  //     searchDebugReport
  //         .add("• 标签: " + await analyzer.getString(widget.rule.searchTags));
  //     final result = await analyzer.getString(widget.rule.searchResult);
  //     searchDebugReport.add("• 结果: " + result);
  //     searchDebugReport.add("• [${parseTime(now)}] 搜索结束");
  //     setState(() {});
  //     return parseChapter(result, now);
  //   } catch (e) {
  //     Toast.show(e.toString(), context, duration: 3);
  //   }
  //   return false;
  // }

  // Future<bool> parseChapter(String result, DateTime now) async {
  //   setState(() {
  //     chapterDebugReport.add("• [${parseTime(now)}] 目录开始");
  //   });
  //   if (widget.rule.chapterUrl.isEmpty) {
  //     chapterDebugReport.add("• chapterUrl规则为空，使用searchResult作为请求地址");
  //     final chapterResult = await AnalyzeUrl.urlRuleParser(
  //       result,
  //       host: widget.rule.host,
  //     );
  //     final baseUrl = chapterResult.request.url.toString();
  //     setState(() {
  //       chapterDebugReport.add("• 成功获取章节响应");
  //       chapterDebugReport.add("• 章节地址: " + baseUrl);
  //     });
  //     final analyzer = AnalyzeRule(
  //         utf8.decode(chapterResult.bodyBytes), baseUrl, widget.rule.host);
  //     final chapterList = await analyzer.getElements(widget.rule.chapterList);
  //     final resultCount = chapterList.length;
  //     if (resultCount == 0) {
  //       setState(() {
  //         chapterDebugReport.add("• 章节结果列表个数为0，解析结束！");
  //       });
  //       return false;
  //     }
  //     setState(() {
  //       chapterDebugReport.add("• 章节结果列表个数: " + resultCount.toString());
  //       chapterDebugReport.add("• 开始解析第一个章节");
  //     });
  //     await parseFirstChapterResult(chapterList.first, baseUrl, now);
  //   } else {
  //     chapterDebugReport.add("• 暂不支持chapterUrl规则");
  //   }
  //   setState(() {
  //     chapterDebugReport.add("• [${parseTime(now)}] 目录结束");
  //   });
  //   return true;
  // }

  // Future<bool> parseFirstChapterResult(
  //     dynamic first, String baseUrl, DateTime now) async {
  //   try {
  //     final analyzer = AnalyzeRule(first, baseUrl, widget.rule.host);
  //     contentDebugReport.add("• [${parseTime(now)}] 正文开始");
  //     contentDebugReport
  //         .add("• 名称: " + await analyzer.getString(widget.rule.chapterName));
  //     contentDebugReport
  //         .add("• 付费: " + await analyzer.getString(widget.rule.chapterLock));
  //     contentDebugReport
  //         .add("• 封面: " + await analyzer.getString(widget.rule.chapterCover));
  //     contentDebugReport
  //         .add("• 时间: " + await analyzer.getString(widget.rule.chapterTime));
  //     final result = await analyzer.getString(widget.rule.chapterResult);
  //     contentDebugReport.add("• 结果: " + result);
  //     contentDebugReport.add("• 正文解析暂未实现，解析已结束！");
  //     setState(() {});
  //   } catch (e) {
  //     Toast.show(e.toString(), context, duration: 3);
  //     setState(() {
  //       contentDebugReport.add("• 解析已结束");
  //     });
  //   }
  //   setState(() {
  //     contentDebugReport.add("• [${parseTime(now)}] 正文结束");
  //   });
  //   return true;
  // }
}
