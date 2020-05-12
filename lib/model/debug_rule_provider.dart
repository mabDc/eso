import 'package:eso/api/api.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/model/analyze_rule/analyze_rule.dart';
import 'package:eso/model/analyze_rule/analyze_url.dart';
import 'package:eso/utils/input_stream.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DebugRuleProvider with ChangeNotifier {
  DateTime _startTime;
  final Rule rule;
  final Color textColor;
  DebugRuleProvider(this.rule, this.textColor);
  final rows = <Row>[];
  Widget _buildText(String s, [bool isUrl = false]) {
    return Flexible(
      child: isUrl
          ? GestureDetector(
              onTap: () => launch(s),
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

  void search(String value) async {
    _startTime = DateTime.now();
    rows.clear();
    _beginEvent("搜索");
    try {
      final searchResult = await AnalyzeUrl.urlRuleParser(
        rule.searchUrl,
        host: rule.host,
        key: value,
      );
      final searchUrl = searchResult.request.url.toString();
      _addContent("地址", searchUrl, true);
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
      rows.add(Row(
        children: [
          SelectableText("$e\n", style: TextStyle(color: Colors.red, height: 2))
        ],
      ));
      _addContent("解析结束！");
    }
  }

  void parseFirstSearch(dynamic firstItem, String baseUrl) async {
    _addContent("开始解析第一个结果");
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
    _addContent("地址", chapterUrl, true);
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
      _addContent("章节结果个数", count.toString());
      parseFirstChapter(
          reversed ? chapterList.last : chapterList.first, chapterUrl);
    }
  }

  void parseFirstChapter(dynamic firstItem, String baseUrl) async {
    _addContent("开始解析第一个结果");
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
    _addContent("地址", contentUrl, true);
    final contentItems = await AnalyzeRule(
      InputStream.decode(res.bodyBytes),
      contentUrl,
      rule.host,
    ).getStringList(rule.contentItems);
    final count = contentItems.length;
    if (count == 0) {
      _addContent("正文结果个数为0，解析结束！");
    } else {
      _addContent("正文结果个数", count.toString());
      final isUrl = rule.contentType == API.MANGA;
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
  }

  @override
  void dispose() {
    rows.clear();
    super.dispose();
  }
}
