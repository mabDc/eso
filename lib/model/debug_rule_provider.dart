import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eso/api/analyze_url_client.dart';
import 'package:eso/api/api.dart';
import 'package:eso/api/api_js_engine.dart';
import 'package:eso/api/api_manager.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/page/photo_view_page.dart';
import 'package:eso/profile.dart';
import 'package:eso/ui/ui_fade_in_image.dart';
import 'package:eso/ui/ui_image_item.dart';
import 'package:eso/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';
import '../api/analyze_url.dart';
import '../api/analyzer_manager.dart';
import 'package:eso/utils/decode_body.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:eso/model/moreKeys.dart';

class SearchLists {
  String url;
  String resultUrl;

  SearchLists({this.url, this.resultUrl}) {}
  from(SearchLists SearchLists) {
    this.url = SearchLists.url;
    this.resultUrl = SearchLists.resultUrl;
  }
}

class DebugRuleProvider with ChangeNotifier {
  int _cupertinoTabBarValue = 0;
  int get cupertinoTabBarValue => _cupertinoTabBarValue;

  int cupertinoTabBarIIValueGetter() => _cupertinoTabBarValue;
  set cupertinoTabBarValue(int value) {
    if (_cupertinoTabBarValue != value) {
      _cupertinoTabBarValue = value;
      notifyListeners();
    }
  }

  DateTime _startTime;
  final Rule rule;
  final Color textColor;
  final int type;
  final Map<String, SearchLists> debugRuleResult;

  bool disposeFlag;
  ScrollController _controller;
  ScrollController get controller => _controller;
  TextEditingController _editController = TextEditingController();
  TextEditingController get editController => _editController;
  TextEditingController _paramEditController = TextEditingController();
  TextEditingController get paramEditController => _paramEditController;

  TextEditingController _rawEditController = TextEditingController();
  TextEditingController get rawEditController => _rawEditController;
  ScrollController _scrollControllerRaw = ScrollController();
  ScrollController get scrollControllerRaw => _scrollControllerRaw;
  ScrollController _scrollControllerProtocol = ScrollController();
  ScrollController get scrollControllerProtocol => _scrollControllerProtocol;

  FocusNode _focusNode = FocusNode();
  FocusNode get focusNode => _focusNode;

  DebugRuleProvider(this.rule, this.textColor,
      {this.type = -1, this.debugRuleResult}) {
    httpLog.clear(open: false);
    switch (type) {
      case 0:
        final paramsMap = {};

        if (rule.discoverMoreKeys.trim().isNotEmpty) {
          var moreKeys =
              ItemMoreKeys.fromJson(jsonDecode(rule.discoverMoreKeys));
          Map<String, String> filters = {};
          moreKeys.list.first.requestFilters.forEach((e) {
            filters[e.key] = e.value == null ? '' : e.value;
          });
          print("filters:${jsonEncode(filters)}");

          paramsMap['tabIndex'] = 0;
          paramsMap['ignoreflt'] = false;
          paramsMap['filters'] = filters;
        }
        paramsMap['page'] = 1;
        _paramEditController.text =
            JsonEncoder.withIndent('\t\t').convert(paramsMap);
        break;
      case 1:
        final paramsMap = {};
        paramsMap['keyword'] = '都市';
        paramsMap['page'] = 1;
        _paramEditController.text =
            JsonEncoder.withIndent('\t\t').convert(paramsMap);
        break;
      case 2:
        final searchList = this.debugRuleResult['searchList'] ??
            SearchLists(resultUrl: '', url: '');
        final paramsMap = {};
        paramsMap['detaiUrl'] = searchList.resultUrl;
        _paramEditController.text =
            JsonEncoder.withIndent('\t\t').convert(paramsMap);
        break;
      case 3:
        final chapterList = this.debugRuleResult['chapterList'] ??
            SearchLists(resultUrl: '', url: '');
        final paramsMap = {};
        paramsMap['requstUrl'] = chapterList.resultUrl;
        _paramEditController.text =
            JsonEncoder.withIndent('\t\t').convert(paramsMap);
        break;

      default:
    }

    disposeFlag = false;

    _controller = ScrollController();
    initPrint();
  }

  void initPrint() async {
    await JSEngine.setFunction("__print", IsolateFunction((s, isUrl) {
      _addContent("JS", s.toString(), isUrl, true);
    }));
    JSEngine.evaluate(
        "var print = function(...args) {__print(args[0], !!args[1]);};");
  }

  final rows = <Row>[];
  @override
  void dispose() {
    rows.clear();
    _editController.dispose();
    disposeFlag = true;
    _focusNode.dispose();
    _controller.dispose();
    _scrollControllerRaw.dispose();
    searchController.dispose();

    super.dispose();
  }

  Widget _buildText(String s, [bool isUrl = false, bool fromJS = false]) {
    return Flexible(
      child: isUrl
          ? GestureDetector(
              onTap: () => launchUrl(Uri.parse(s)),
              onLongPress: () async {
                await Clipboard.setData(ClipboardData(text: s));
                showToast("结果已复制: $s");
              },
              child: Text(
                s,
                style: TextStyle(
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                  color: fromJS ? Colors.green : Colors.blue,
                  height: 2,
                ),
              ),
            )
          : SelectableText(s,
              style: TextStyle(height: 2, color: fromJS ? Colors.green : null)),
    );
  }

  void _addContent(String sInfo,
      [String s, bool isUrl = false, bool fromJS = false]) {
    final d = DateTime.now().difference(_startTime).inMicroseconds;
    rows.add(Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "• [${DateFormat("mm:ss.SSS").format(DateTime.fromMicrosecondsSinceEpoch(d))}] $sInfo${s == null ? "" : ": "}",
          style: TextStyle(color: textColor.withOpacity(0.5), height: 2),
        ),
        _buildText(s ?? "", isUrl, fromJS),
      ],
    ));
    if (sInfo == "测试预览") {
      Map<String, String> headers = null;
      PhotoItem photoItem = null;
      final index = s.indexOf("@headers");
      Future<Uint8List> _onDecrypt(Uint8List body) async {
        dynamic result = await APIManager.parseContent(rule.id, body);
        if (result is Uint8List) {
          return result;
        }
        result = jsonDecode(result);
        if (result is Map) {
          final bytes = result['bytes'].cast<int>();
          return Uint8List.fromList(bytes);
        }
        Utils.toast("解密返回数据不是OBJ");
        return body;
      }

      if (index == -1) {
        photoItem = PhotoItem(s, headers, _onDecrypt);
      } else {
        headers = (jsonDecode(s.substring(index + 8)) as Map)
            .map((k, v) => MapEntry('$k', '$v'));
        photoItem = PhotoItem(s.substring(0, index), headers, _onDecrypt);
      }

      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• [${DateFormat("mm:ss.SSS").format(DateTime.fromMicrosecondsSinceEpoch(d))}] 预览: ",
            style: TextStyle(color: textColor.withOpacity(0.5), height: 2),
          ),
          Expanded(child: UIFadeInImage(item: photoItem)),
        ],
      ));
    } else if (sInfo == "封面") {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• [${DateFormat("mm:ss.SSS").format(DateTime.fromMicrosecondsSinceEpoch(d))}] 预览: ",
            style: TextStyle(color: textColor.withOpacity(0.5), height: 2),
          ),
          Expanded(child: UIImageItem(cover: s)),
        ],
      ));
    }

    notifyListeners();
  }

  bool isEmptyResponse(Response<List<int>> resp) {
    return resp == null ||
        resp.data == null ||
        (resp.data?.isEmpty ?? true) ||
        resp.requestOptions == null;
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
            fontFamily: Profile.staticFontFamily,
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

  SearchLists _searchList = SearchLists(resultUrl: '', url: '');
  SearchLists get searchList => _searchList;

  SearchLists _chapterList = SearchLists(resultUrl: '', url: '');
  SearchLists get chapterList => _chapterList;

  void discover({bool isParseChapter = true}) async {
    _startTime = DateTime.now();
    rows.clear();
    _rawEditController.text = '';
    _beginEvent("发现");

    httpLog.clear();
    try {
      dynamic discoverRule = rule.discoverUrl.trimLeft();
      if (_paramEditController.text.trim().isEmpty) {
        httpLog.open = false;
        _addContent("参数为空");
        return;
      }
      final params = jsonDecode(_paramEditController.text);
      var page = params['page'];
      page = page is int ? page : 1;
      var tabIndex = params['tabIndex'];
      tabIndex = tabIndex is int ? tabIndex : 0;
      var ignoreflt = params['ignoreflt'];
      ignoreflt = ignoreflt is bool ? ignoreflt : false;
      var flt = params['filters'] ?? {};
      if (ignoreflt == true) {
        var moreKeys = ItemMoreKeys.fromJson(jsonDecode(rule.discoverMoreKeys));
        Map<String, String> filters = {};
        moreKeys.list.elementAt(tabIndex).requestFilters.forEach((e) {
          filters[e.key] = e.value == null ? '' : e.value;
        });
        print("filters:${jsonEncode(filters)}");
        flt = filters;
      }
      print("params:${params},page:${page},flt:${flt}");
      await JSEngine.evaluate("""
            page = $page;
            host = ${jsonEncode(rule.host)};
            params.tabIndex = $tabIndex;
            params.pageIndex = $page;
            params.filters = ${jsonEncode(flt)};
            1+1;
          """);

      if (discoverRule.startsWith("@js:")) {
        _addContent("执行发现js规则");
        // await JSEngine.setEnvironment(1, rule, "", rule.host, "", "");
        discoverRule =
            jsonEncode(await JSEngine.evaluate(discoverRule.substring(4)));

        _addContent("结果", "$discoverRule");
      }

      final discoverFirst = (discoverRule is List
              ? "${discoverRule.first}"
              : discoverRule is String
                  ? discoverRule
                      .split(RegExp(r"\n+\s*|&&"))
                      .firstWhere((s) => s.trim().isNotEmpty, orElse: () => "")
                  : "")
          .split("::")
          .last;

      print("discoverFirst:${discoverFirst}");

      var body = "";
      var discoverUrl = "";
      if (discoverFirst == 'null') {
        _addContent("地址为null跳过请求");
      } else {
        final discoverResult = await AnalyzeUrl.urlRuleParser(
          discoverFirst,
          rule,
          page: page,
          pageSize: 20,
        );
        if (isEmptyResponse(discoverResult)) {
          _addContent("响应内容为空，终止解析！");
          httpLog.open = false;
          return;
        }
        discoverUrl = discoverResult.requestOptions.uri.toString();

        body = DecodeBody().decode(
            discoverResult.data, discoverResult.headers.value("content-type"));
        _rawEditController.text = body;
        // 设置发现请求地址
        _searchList.url = discoverUrl;

        _addContent("地址", discoverUrl, true);
      }
      // Logger().d("body:${body}");

      await JSEngine.setEnvironment(page, rule, "", discoverUrl, "", "");

      _addContent("初始化js");
      final analyzer = AnalyzerManager(body);
      String next;
      if (rule.discoverNextUrl != null && rule.discoverNextUrl.isNotEmpty) {
        next = await analyzer.getString(rule.discoverNextUrl);
      } else {
        next = null;
      }
      _addContent("下一页", next);
      final discoverList = await analyzer.getElements(rule.discoverList);
      final resultCount = discoverList.length;
      if (resultCount == 0) {
        _addContent("发现结果列表个数为0，解析结束！");
      } else {
        _addContent("个数", resultCount.toString());

        parseFirstDiscover(discoverList.first, isParseChapter: isParseChapter);
      }
    } catch (e) {
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
    httpLog.open = false;
  }

  void parseFirstDiscover(dynamic firstItem,
      {bool isParseChapter = true}) async {
    _addContent("开始解析第一个结果");
    try {
      final analyzer = AnalyzerManager(firstItem);
      _addContent("名称", await analyzer.getString(rule.discoverName));
      _addContent("作者", await analyzer.getString(rule.discoverAuthor));
      _addContent("章节", await analyzer.getString(rule.discoverChapter));
      final coverUrl = await analyzer.getString(rule.discoverCover);
      _addContent("封面", coverUrl, true);
      //_texts.add(WidgetSpan(child: UIImageItem(cover: coverUrl)));
      _addContent("简介", await analyzer.getString(rule.discoverDescription));
      final tags = await analyzer.getString(rule.discoverTags);
      if (tags != null && tags.trim().isNotEmpty) {
        _addContent(
            "标签",
            (tags.split(APIConst.tagsSplitRegExp)
                  ..removeWhere((tag) => tag.isEmpty))
                .join(", "));
      } else {
        _addContent("标签", "");
      }
      final result = await analyzer.getString(rule.discoverResult);
      _addContent("结果", result);

      // 设置请求结果
      _searchList.resultUrl = result;

      if (isParseChapter) {
        parseChapter(result);
      }
    } catch (e, st) {
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n$st\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          )
        ],
      ));
      _addContent("解析结束！");
    }
  }

  final TextEditingController searchController = TextEditingController();

  void search(String value, {bool isParseChapter = true}) async {
    _startTime = DateTime.now();
    rows.clear();
    _rawEditController.text = '';
    httpLog.clear();
    _beginEvent("搜索");
    int page = 1;
    try {
      String searchUrl = "";
      String body = "";
      if (rule.searchUrl == 'null') {
        _addContent("地址为null跳过请求");
      } else {
        if (_paramEditController.text.trim().isNotEmpty) {
          final params = jsonDecode(_paramEditController.text);
          var keyword = params['keyword'];
          var pageIndex = params['page'];
          page = pageIndex is int ? pageIndex : 1;
          if ((keyword is String) == false) {
            _addContent("参数错误");
            httpLog.open = false;
            return;
          }
          value = keyword;
        } else {
          _addContent("参数错误");
          httpLog.open = false;
          return;
        }

        final searchResult = await AnalyzeUrl.urlRuleParser(
          rule.searchUrl,
          rule,
          keyword: value,
          page: page,
          pageSize: 20,
        );
        if (isEmptyResponse(searchResult)) {
          _addContent("响应内容为空，终止解析！");
          return;
        }
        searchUrl = searchResult.requestOptions.uri.toString();
        _searchList.url = searchUrl;
        _addContent("地址", searchUrl, true);
        body = DecodeBody().decode(
            searchResult.data, searchResult.headers["content-type"]?.first);
        _rawEditController.text = body;
      }
      await JSEngine.setEnvironment(page, rule, "", searchUrl, value, "");
      _addContent("初始化js");
      final analyzer = AnalyzerManager(body);
      String next;
      if (rule.searchNextUrl != null && rule.searchNextUrl.isNotEmpty) {
        next = await analyzer.getString(rule.searchNextUrl);
      } else {
        next = null;
      }
      _addContent("下一页", next);
      final searchList = await analyzer.getElements(rule.searchList);
      final resultCount = searchList.length;
      if (resultCount == 0) {
        _addContent("搜索结果列表个数为0，解析结束！");
      } else {
        _addContent("搜索结果个数", resultCount.toString());
        parseFirstSearch(searchList.first, isParseChapter: isParseChapter);
      }
    } catch (e, st) {
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n$st\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          ),
        ],
      ));
      _addContent("解析结束！");
    }
    httpLog.open = false;
  }

  void parseFirstSearch(dynamic firstItem, {bool isParseChapter = true}) async {
    _addContent("开始解析第一个结果");
    try {
      final analyzer = AnalyzerManager(firstItem);
      _addContent("名称", await analyzer.getString(rule.searchName));
      _addContent("作者", await analyzer.getString(rule.searchAuthor));
      _addContent("章节", await analyzer.getString(rule.searchChapter));
      final coverUrl = await analyzer.getString(rule.searchCover);
      _addContent("封面", coverUrl, true);
      //_texts.add(WidgetSpan(child: UIImageItem(cover: coverUrl)));
      _addContent("简介", await analyzer.getString(rule.searchDescription));
      final tags = await analyzer.getString(rule.searchTags);
      if (tags != null && tags.trim().isNotEmpty) {
        _addContent(
            "标签",
            (tags.split(APIConst.tagsSplitRegExp)
                  ..removeWhere((tag) => tag.isEmpty))
                .join(", "));
      } else {
        _addContent("标签", "");
      }
      final result = await analyzer.getString(rule.searchResult);
      _searchList.resultUrl = result;
      _addContent("结果", result);
      if (isParseChapter) {
        parseChapter(result);
      }
    } catch (e, st) {
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n$st\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          ),
        ],
      ));
      _addContent("解析结束！");
    }
  }

  void parseChapter(String result, {bool isPraseContent = true}) async {
    if (_startTime == null) {
      _startTime = DateTime.now();
    }
    if (!isPraseContent) {
      rows.clear();
    }
    httpLog.clear();
    _rawEditController.text = '';
    _beginEvent("目录");
    dynamic firstChapter;
    String next;
    String chapterUrlRule;
    final hasNextUrlRule =
        rule.chapterNextUrl != null && rule.chapterNextUrl.isNotEmpty;
    for (var page = 1;; page++) {
      if (disposeFlag) {
        httpLog.open = false;
        return;
      }

      chapterUrlRule = null;
      final url = rule.chapterUrl != null && rule.chapterUrl.isNotEmpty
          ? rule.chapterUrl
          : result;
      if (page == 1) {
        chapterUrlRule = url;
      } else if (hasNextUrlRule) {
        if (next != null && next.isNotEmpty) {
          chapterUrlRule = next;
        }
      } else if (url.contains(APIConst.pagePattern)) {
        chapterUrlRule = url;
      }
      _addContent("解析第$page页");
      _addContent("规则", "$chapterUrlRule");
      if (chapterUrlRule == null) {
        _addContent("下一页结束");
        break;
      }
      try {
        String chapterUrl = "";
        String body = "";
        if (rule.chapterUrl == 'null') {
          _addContent("地址为null跳过请求");
        } else {
          final res = await AnalyzeUrl.urlRuleParser(
            chapterUrlRule,
            rule,
            result: result,
            page: page,
          );
          if (isEmptyResponse(res)) {
            _addContent("响应内容为空，终止解析！");
            break;
          }
          chapterUrl = res.requestOptions.uri.toString();
          _addContent("地址", chapterUrl, true);
          _chapterList.resultUrl = chapterUrl;
          body =
              DecodeBody().decode(res.data, res.headers["content-type"]?.first);
        }

        if (page == 1) {
          await JSEngine.setEnvironment(
              page, rule, result, chapterUrl, "", result);
        } else {
          await JSEngine.evaluate(
              "baseUrl = ${jsonEncode(chapterUrl)};page = ${jsonEncode(page)};");
        }
        final analyzer = AnalyzerManager(body);
        if (hasNextUrlRule) {
          next = await analyzer.getString(rule.chapterNextUrl);
        } else {
          next = null;
        }
        _addContent("下一页", await analyzer.getString(rule.chapterNextUrl));
        AnalyzerManager analyzerManager;
        if (rule.enableMultiRoads) {
          final roads = await analyzer.getElements(rule.chapterRoads);
          final count = roads.length;
          if (count == 0) {
            _addContent("线路个数为0，解析结束！");
            break;
          } else {
            _addContent("个数", count.toString());
          }
          final road = roads.first;
          analyzerManager = AnalyzerManager(road);
          _addContent(
              "线路名称", await analyzerManager.getString(rule.chapterRoadName));
        } else {
          analyzerManager = analyzer;
        }
        final reversed = rule.chapterList.startsWith("-");
        if (reversed) {
          _addContent("检测规则以\"-\"开始, 结果将反序");
        }

        final chapterList = await analyzerManager.getElements(
            reversed ? rule.chapterList.substring(1) : rule.chapterList);
        final count = chapterList.length;
        if (count == 0) {
          _addContent("章节列表个数为0，解析结束！");
          break;
        } else {
          _addContent("个数", count.toString());
          if (firstChapter == null) {
            firstChapter = reversed ? chapterList.last : chapterList.first;
          }
        }
      } catch (e, st) {
        httpLog.open = false;
        rows.add(Row(
          children: [
            Flexible(
              child: SelectableText(
                "$e\n$st\n",
                style: TextStyle(color: Colors.red, height: 2),
              ),
            )
          ],
        ));
        _addContent("解析结束！");
        break;
      }
    }
    if (disposeFlag) {
      httpLog.open = false;
      return;
    }
    if (firstChapter != null) {
      parseFirstChapter(firstChapter, isPraseContent: isPraseContent);
    }
    httpLog.open = false;
  }

  void parseFirstChapter(dynamic firstItem,
      {bool isPraseContent = true}) async {
    _addContent("开始解析第一个结果");
    try {
      final analyzer = AnalyzerManager(firstItem);
      final name = await analyzer.getString(rule.chapterName);
      _addContent("名称", name);
      final lock = await analyzer.getString(rule.chapterLock);
      _addContent("lock", lock);
      if (lock != null &&
          lock.isNotEmpty &&
          lock != "undefined" &&
          lock != "false" &&
          lock != "0") {
        _addContent("名称", "🔒" + name);
      } else {
        _addContent("名称", name);
      }
      _addContent("时间", await analyzer.getString(rule.chapterTime));
      final coverUrl = await analyzer.getString(rule.chapterCover);
      _addContent("封面", coverUrl, true);
      //_texts.add(WidgetSpan(child: UIImageItem(cover: coverUrl)));
      final result = await analyzer.getString(rule.chapterResult);
      _addContent("结果", result);
      _chapterList.resultUrl = result;
      if (isPraseContent) {
        praseContent(result);
      }
    } catch (e, st) {
      rows.add(Row(
        children: [
          Flexible(
            child: SelectableText(
              "$e\n$st\n",
              style: TextStyle(color: Colors.red, height: 2),
            ),
          )
        ],
      ));
      _addContent("解析结束！");
    }
  }

  void praseContent(String result, {isParse = false}) async {
    if (isParse) {
      rows.clear();
    }
    httpLog.clear();

    if (_startTime == null) {
      _startTime = DateTime.now();
    }
    if (isParse) {
      rows.clear();
    }
    _rawEditController.text = '';

    _beginEvent("正文");
    final hasNextUrlRule =
        rule.contentNextUrl != null && rule.contentNextUrl.isNotEmpty;
    final url = rule.contentUrl != null && rule.contentUrl.isNotEmpty
        ? rule.contentUrl
        : result;
    String next;
    String contentUrlRule;
    for (var page = 1;; page++) {
      if (disposeFlag) return;
      contentUrlRule = null;
      if (page == 1) {
        contentUrlRule = url;
      } else if (hasNextUrlRule) {
        if (next != null && next.isNotEmpty) {
          contentUrlRule = next;
        }
      } else if (url.contains(APIConst.pagePattern)) {
        contentUrlRule = url;
      }
      if (contentUrlRule == null) {
        _addContent("下一页结束");
        httpLog.open = false;
        return;
      }
      _addContent("解析第$page页");
      _addContent("规则", "$contentUrlRule");
      if (contentUrlRule == null) {
        _addContent("下一页结束");
        httpLog.open = false;
        break;
      }
      try {
        var contentUrl = '';
        var body = '';
        if (contentUrlRule == 'null' || contentUrlRule == null) {
          _addContent("地址为null跳过请求");
        } else {
          final res = await AnalyzeUrl.urlRuleParser(
            contentUrlRule,
            rule,
            result: result,
            page: page,
          );
          if (isEmptyResponse(res)) {
            _addContent("响应内容为空，终止解析！");
            httpLog.open = false;
            return;
          }
          contentUrl = res.requestOptions.uri.toString();
          _addContent("地址", contentUrl, true);
          body =
              DecodeBody().decode(res.data, res.headers["content-type"]?.first);
          _rawEditController.text = body;
        }
        if (page == 1) {
          await JSEngine.setEnvironment(
              page, rule, result, contentUrl, "", result);
        } else {
          await JSEngine.evaluate(
              "baseUrl = ${jsonEncode(contentUrl)};page = ${jsonEncode(page)};");
        }
        // Logger().d(body);

        final analyzer = AnalyzerManager(body);
        if (hasNextUrlRule) {
          next = await analyzer.getString(rule.contentNextUrl);
        } else {
          next = null;
        }
        _addContent("下一页", next);
        var contentItems = await analyzer.getStringList(rule.contentItems);
        if (rule.contentType == API.NOVEL) {
          contentItems = contentItems.join("\n").split(RegExp(r"\n\s*|\s{2,}"));
        }
        final count = contentItems.length;
        if (count == 0) {
          _addContent("正文结果个数为0，解析结束！");
          httpLog.open = false;
          return;
        } else if (contentItems.join().trim().isEmpty) {
          _addContent("正文内容为空，解析结束！");
          httpLog.open = false;
          return;
        } else {
          _addContent("个数", count.toString());
          final isUrl = rule.contentType == API.MANGA ||
              rule.contentType == API.AUDIO ||
              rule.contentType == API.VIDEO;
          for (int i = 0; i < count; i++) {
            rows.add(Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "• [${'0' * (3 - i.toString().length)}$i]: ",
                  style:
                      TextStyle(color: textColor.withOpacity(0.5), height: 2),
                ),
                _buildText(contentItems[i], isUrl),
              ],
            ));
          }
          if (rule.contentType == API.MANGA) {
            _addContent("预览首个结果", '');
            _addContent("测试预览", contentItems.first, true);
          }
          notifyListeners();
        }
      } catch (e, st) {
        httpLog.open = false;
        rows.add(Row(
          children: [
            Flexible(
              child: SelectableText(
                "$e\n$st\n",
                style: TextStyle(color: Colors.red, height: 2),
              ),
            )
          ],
        ));
        _addContent("解析结束！");
        return;
      }
    }
    httpLog.open = false;
  }
}
