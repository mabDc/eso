import 'dart:convert';

import 'package:eso/api/analyzer_manager.dart';
import 'package:eso/database/rule.dart';
import '../global.dart';
import 'analyze_url.dart';
import 'package:eso/utils/decode_body.dart';
import 'package:flutter_js/flutter_js.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';
import 'api_const.dart';

class APIFromRUle implements API {
  final Rule rule;
  String _origin;
  String _originTag;
  int _ruleContentType;
  int _engineId;

  @override
  String get origin => _origin;

  @override
  String get originTag => _originTag;

  @override
  int get ruleContentType => _ruleContentType;

  APIFromRUle(this.rule, [int engineId]) {
    _engineId = engineId;
    _origin = rule.name;
    _originTag = rule.id;
    _ruleContentType = rule.contentType;
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    if (params.isEmpty) return <SearchItem>[];
    final discoverRule = params.values.first.value;
    if (page > 1 && !discoverRule.contains(APIConst.pagePattern)) {
      return <SearchItem>[];
    }
    final res = await AnalyzeUrl.urlRuleParser(
      discoverRule,
      rule,
      page: page,
      pageSize: pageSize,
    );
    if (res.contentLength == 0) {
      return <SearchItem>[];
    }
    final discoverUrl = res.request.url.toString();
    final engineId = await APIConst.initJSEngine(rule, discoverUrl);
    await FlutterJs.evaluate("page = ${jsonEncode(page)}", engineId);
    final list = await AnalyzerManager(
            DecodeBody().decode(res.bodyBytes, res.headers["content-type"]),
            engineId,
            rule)
        .getElements(rule.discoverList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzerManager(item, engineId, rule);
      final tag = await analyzer.getString(rule.discoverTags);
      List<String> tags = <String>[];
      if (tag != null && tag.trim().isNotEmpty) {
        tags = tag.split(APIConst.tagsSplitRegExp)..removeWhere((tag) => tag.isEmpty);
      }
      result.add(SearchItem(
        cover: await analyzer.getString(rule.discoverCover),
        name: (await analyzer.getString(rule.discoverName))
            .trim()
            .replaceAll(APIConst.largeSpaceRegExp, Global.fullSpace),
        author: await analyzer.getString(rule.discoverAuthor),
        chapter: await analyzer.getString(rule.discoverChapter),
        description: await analyzer.getString(rule.discoverDescription),
        url: await analyzer.getString(rule.discoverResult),
        api: this,
        tags: tags,
      ));
    }
    FlutterJs.close(engineId);
    return result;
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    if (page > 1 && !rule.searchUrl.contains(APIConst.pagePattern)) {
      return <SearchItem>[];
    }
    final res = await AnalyzeUrl.urlRuleParser(
      rule.searchUrl,
      rule,
      page: page,
      pageSize: pageSize,
      keyword: query,
    );
    if (res.contentLength == 0) {
      return <SearchItem>[];
    }
    final searchUrl = res.request.url.toString();
    final engineId = await APIConst.initJSEngine(rule, searchUrl, engineId: _engineId);
    await FlutterJs.evaluate("page = ${jsonEncode(page)}", engineId);
    final list = await AnalyzerManager(
            DecodeBody().decode(res.bodyBytes, res.headers["content-type"]),
            engineId,
            rule)
        .getElements(rule.searchList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzerManager(item, engineId, rule);
      final tag = await analyzer.getString(rule.searchTags);
      List<String> tags = <String>[];
      if (tag != null && tag.trim().isNotEmpty) {
        tags = tag.split(APIConst.tagsSplitRegExp)..removeWhere((tag) => tag.isEmpty);
      }
      result.add(SearchItem(
        cover: await analyzer.getString(rule.searchCover),
        name: (await analyzer.getString(rule.searchName))
            .trim()
            .replaceAll(APIConst.largeSpaceRegExp, Global.fullSpace),
        author: await analyzer.getString(rule.searchAuthor),
        chapter: await analyzer.getString(rule.searchChapter),
        description: await analyzer.getString(rule.searchDescription),
        url: await analyzer.getString(rule.searchResult),
        api: this,
        tags: tags,
      ));
    }
    FlutterJs.close(engineId);
    return result;
  }

  @override
  Future<List<ChapterItem>> chapter(final String url) async {
    final result = <ChapterItem>[];
    int engineId;
    for (var page = 1;; page++) {
      final chapterUrlRule = rule.chapterUrl.isNotEmpty ? rule.chapterUrl : url;
      if (page > 1 && !chapterUrlRule.contains(APIConst.pagePattern)) {
        break;
      }
      final res = await AnalyzeUrl.urlRuleParser(
        chapterUrlRule,
        rule,
        result: url,
        page: page,
      );
      if (res.contentLength == 0) {
        break;
      }
      final chapterUrl = res.request.url.toString();
      final reversed = rule.chapterList.startsWith("-");
      if (engineId == null) {
        engineId = await APIConst.initJSEngine(rule, chapterUrl, lastResult: url);
        await FlutterJs.evaluate("page = ${jsonEncode(page)}", engineId);
      } else {
        await FlutterJs.evaluate(
            "baseUrl = ${jsonEncode(chapterUrl)}; page = ${jsonEncode(page)};", engineId);
      }
      try {
        final list = await AnalyzerManager(
                DecodeBody().decode(res.bodyBytes, res.headers["content-type"]),
                engineId,
                rule)
            .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
        if (list.isEmpty) {
          break;
        }
        for (var item in (reversed ? list.reversed : list)) {
          final analyzer = AnalyzerManager(item, engineId, rule);
          final lock = await analyzer.getString(rule.chapterLock);
          // final unLock = await analyzer.getString(rule.chapterUnLock);
          var name = (await analyzer.getString(rule.chapterName))
              .trim()
              .replaceAll(APIConst.largeSpaceRegExp, Global.fullSpace);
          // if (unLock != null && unLock.isNotEmpty && unLock != "undefined" && unLock != "false") {
          //   name = "🔓" + name;
          // }else
          if (lock != null &&
              lock.isNotEmpty &&
              lock != "undefined" &&
              lock != "false" &&
              lock != "0") {
            name = "🔒" + name;
          }
          result.add(ChapterItem(
            cover: await analyzer.getString(rule.chapterCover),
            name: name,
            time: await analyzer.getString(rule.chapterTime),
            url: await analyzer.getString(rule.chapterResult),
          ));
        }
      } catch (e) {
        break;
      }
    }
    FlutterJs.close(engineId);
    return result;
  }

  @override
  Future<List<String>> content(final String url) async {
    final result = <String>[];
    int engineId;
    for (var page = 1;; page++) {
      final contentUrlRule = rule.contentUrl.isNotEmpty ? rule.contentUrl : url;
      if (page > 1 && !contentUrlRule.contains(APIConst.pagePattern)) break;
      final res = await AnalyzeUrl.urlRuleParser(
        contentUrlRule,
        rule,
        result: url,
        page: page,
      );
      if (res.contentLength == 0) {
        break;
      }
      final contentUrl = res.request.url.toString();
      if (engineId == null) {
        engineId = await APIConst.initJSEngine(rule, contentUrl, lastResult: url);
        await FlutterJs.evaluate("page = ${jsonEncode(page)}", engineId);
      } else {
        await FlutterJs.evaluate(
            "baseUrl = ${jsonEncode(contentUrl)}; page = ${jsonEncode(page)};", engineId);
      }
      try {
        final list = await AnalyzerManager(
                DecodeBody().decode(res.bodyBytes, res.headers["content-type"]),
                engineId,
                rule)
            .getStringList(rule.contentItems);
        if (list == null || list.isEmpty || list.join().trim().isEmpty) {
          break;
        }
        result.addAll(list);
      } catch (e) {
        /// 视频正文解析失败抛出错误
        if (_ruleContentType == API.VIDEO && result.isEmpty) {
          FlutterJs.close(engineId);
          throw e;
        }
        break;
      }
    }
    FlutterJs.close(engineId);
    return result;
  }

  @override
  Future<List<DiscoverMap>> discoverMap() async {
    final map = <DiscoverMap>[];
    final table = Map<String, int>();
    dynamic discoverUrl = rule.discoverUrl.trimLeft();
    if (discoverUrl.startsWith("@js:")) {
      final engineId = await APIConst.initJSEngine(rule, "");
      discoverUrl = await FlutterJs.evaluate(discoverUrl.substring(4), engineId);
      FlutterJs.close(engineId);
    }
    final discovers = (discoverUrl is List)
        ? discoverUrl.map((e) => "$e")
        : (discoverUrl is String)
            ? discoverUrl.split(RegExp(r"\n\s*|&&"))
            : <String>[];
    for (var url in discovers) {
      if (url.trim().isEmpty) continue;
      final d = url.split("::");
      final rule = d.last.trim();
      String tab;
      String className;
      if (d.length == 1) {
        tab = "全部";
        className = "全部";
      } else if (d.length == 2) {
        tab = d[0].trim();
        className = "全部";
      } else if (d.length == 3) {
        tab = d[0].trim();
        className = d[1].trim();
      }
      if (table[tab] == null) {
        table[tab] = map.length;
        map.add(DiscoverMap(tab, <DiscoverPair>[
          DiscoverPair(className, rule),
        ]));
      } else {
        map[table[tab]].pairs.add(DiscoverPair(className, rule));
      }
    }
    if (map.isEmpty) {
      if (rule.host.startsWith("http")) {
        map.add(DiscoverMap("全部", <DiscoverPair>[
          DiscoverPair("全部", rule.host),
        ]));
      } else {
        map.add(DiscoverMap("example", <DiscoverPair>[
          DiscoverPair("example", "http://example.com/"),
        ]));
      }
    }
    return map;
  }
}
