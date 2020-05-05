import 'dart:convert';

import 'package:eso/database/rule.dart';
import 'package:eso/model/analyze_rule/analyze_rule.dart';
import 'package:eso/model/analyze_rule/analyze_url.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../../api/api.dart';

class DebugRulePage extends StatefulWidget {
  final Rule rule;
  const DebugRulePage({
    this.rule,
    Key key,
  }) : super(key: key);

  @override
  _DebugRulePageState createState() => _DebugRulePageState();
}

class _DebugRulePageState extends State<DebugRulePage> {
  Widget _buildBigText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Text _buildDetailsText(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.black54, fontSize: 16, height: 2),
    );
  }

  TextEditingController _controller;
  final searchDebugReport = <String>["等待中..."];
  final chapterDebugReport = <String>["等待中..."];
  final contentDebugReport = <String>["等待中..."];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  Future<bool> parseSearch() async {
    searchDebugReport.removeRange(1, searchDebugReport.length);
    chapterDebugReport.removeRange(1, searchDebugReport.length);
    contentDebugReport.removeRange(1, searchDebugReport.length);
    setState(() {});
    final searchResult = await AnalyzeUrl.urlRuleParser(
      widget.rule.searchUrl,
      host: widget.rule.host,
      key: _controller.text,
    );
    final baseUrl = searchResult.request.url.toString();
    setState(() {
      searchDebugReport.add("成功获取搜索响应");
      searchDebugReport.add("搜索地址: " + baseUrl);
    });
    final analyzer = AnalyzeRule(utf8.decode(searchResult.bodyBytes), baseUrl);
    final searchList = await analyzer.getElements(widget.rule.searchList);
    final resultCount = searchList.length;
    if (resultCount == 0) {
      setState(() {
        searchDebugReport.add("搜索结果列表个数为0，解析结束！");
      });
      return false;
    }
    setState(() {
      searchDebugReport.add("搜索结果列表个数: " + resultCount.toString());
      searchDebugReport.add("开始解析第一个搜索结果");
    });
    await parseFirstSearchResult(searchList.first, baseUrl);
    return true;
  }

  Future<bool> parseFirstSearchResult(dynamic first, String baseUrl) async {
    try {
      final analyzer = AnalyzeRule(first, baseUrl);
      searchDebugReport.add("名称: " + await analyzer.getString(widget.rule.searchName));
      searchDebugReport.add("作者: " + await analyzer.getString(widget.rule.searchAuthor));
      searchDebugReport.add("封面: " + await analyzer.getString(widget.rule.searchCover));
      searchDebugReport.add("章节: " + await analyzer.getString(widget.rule.searchChapter));
      searchDebugReport.add("简介: " + await analyzer.getString(widget.rule.searchDescription));
      searchDebugReport.add("标签: " + await analyzer.getString(widget.rule.searchTags));
      final result = await analyzer.getString(widget.rule.searchResult);
      searchDebugReport.add("结果: " + result);
      setState(() {});
      await parseChapter(result);
    } catch (e) {
      Toast.show(e.toString(), context, duration: 3);
      setState(() {
        searchDebugReport.add("解析已结束");
      });
    }
    return true;
  }

  Future<bool> parseChapter(String result) async {
    if(widget.rule.chapterUrl.isEmpty){
      chapterDebugReport.add("chapterUrl规则为空，使用searchResult作为请求地址");
      final chapterResult = await AnalyzeUrl.urlRuleParser(
        result,
        host: widget.rule.host,
      );
      final baseUrl = chapterResult.request.url.toString();
      setState(() {
        chapterDebugReport.add("成功获取章节响应");
        chapterDebugReport.add("章节地址: " + baseUrl);
      });
      final analyzer = AnalyzeRule(utf8.decode(chapterResult.bodyBytes), baseUrl);
      final chapterList = await analyzer.getElements(widget.rule.chapterList);
      final resultCount = chapterList.length;
      if (resultCount == 0) {
        setState(() {
          chapterDebugReport.add("章节结果列表个数为0，解析结束！");
        });
        return false;
      }
      setState(() {
        chapterDebugReport.add("章节结果列表个数: " + resultCount.toString());
        chapterDebugReport.add("开始解析第一个章节");
      });
      await parseFirstChapterResult(chapterList.first, baseUrl);

    }else{
      chapterDebugReport.add("暂不支持chapterUrl规则");
    }
    return true;
  }

  Future<bool> parseFirstChapterResult(dynamic first, String baseUrl) async {
    try {
      final analyzer = AnalyzeRule(first, baseUrl);
      chapterDebugReport.add("名称: " + await analyzer.getString(widget.rule.chapterName));
      chapterDebugReport.add("付费: " + await analyzer.getString(widget.rule.chapterLock));
      chapterDebugReport.add("封面: " + await analyzer.getString(widget.rule.chapterCover));
      chapterDebugReport.add("时间: " + await analyzer.getString(widget.rule.chapterTime));
      final result = await analyzer.getString(widget.rule.chapterResult);
      chapterDebugReport.add("结果: " + result);
      chapterDebugReport.add("正文解析暂未实现，解析已结束！");
      setState(() {});
    } catch (e) {
      Toast.show(e.toString(), context, duration: 3);
      setState(() {
        chapterDebugReport.add("解析已结束");
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onSubmitted: (value) => parseSearch(),
          cursorColor: Theme.of(context).primaryTextTheme.title.color,
          style: TextStyle(
            color: Theme.of(context).primaryTextTheme.title.color,
          ),
          autofocus: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryTextTheme.title.color,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryTextTheme.title.color,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildBigText('基础信息'),
          _buildDetailsText("""
创建时间：${DateTime.fromMicrosecondsSinceEpoch(widget.rule.createTime)}
修改时间：${DateTime.fromMicrosecondsSinceEpoch(widget.rule.modifiedTime)}
作者：${widget.rule.author}
签名档：${widget.rule.postScript}
名称：${widget.rule.name}
域名：${widget.rule.host}
类型：${API.getRuleContentTypeName(widget.rule.contentType)}"""),
          _buildBigText('搜索测试'),
          _buildDetailsText(searchDebugReport.join("\n")),
          _buildBigText('目录测试'),
          _buildDetailsText(chapterDebugReport.join("\n")),
          _buildBigText('正文测试'),
          _buildDetailsText(contentDebugReport.join("\n")),
        ],
      ),
    );
  }
}
