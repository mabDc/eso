import 'dart:convert';

import 'package:eso/api/analyzer_manager.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/utils.dart';
import 'package:flutter/services.dart';
import '../global.dart';
import 'analyze_url.dart';
import 'package:eso/utils/decode_body.dart';
import 'package:flutter_js/flutter_js.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';

class APIFromRUle implements API {
  final Rule rule;
  String _origin;
  String _originTag;
  int _ruleContentType;
  int _engineId;
  final largeSpaceRegExp = RegExp(r"\n+|\s{2,}");
  final tagsSplitRegExp = RegExp(r"[　 ,\|\&\%]+");

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
    if (page > 1 && !discoverRule.contains("page")) {
      return <SearchItem>[];
    }
    final res = await AnalyzeUrl.urlRuleParser(
      discoverRule,
      rule,
      page: page,
      pageSize: pageSize,
    );
    final discoverUrl = res.request.url.toString();
    final engineId = await FlutterJs.initEngine(_engineId);
    await FlutterJs.evaluate(
        "cookie = ${jsonEncode(rule.cookies)}; host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(discoverUrl)};",
        engineId);
    if (rule.loadJs.trim().isNotEmpty || rule.useCryptoJS) {
      final cryptoJS =
          rule.useCryptoJS ? await rootBundle.loadString(Global.cryptoJSFile) : "";
      await FlutterJs.evaluate(cryptoJS + rule.loadJs, engineId);
    }
    final list = await AnalyzerManager(
            DecodeBody().decode(res.bodyBytes, res.headers["content-type"]), engineId)
        .getElements(rule.discoverList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzerManager(item, engineId);
      result.add(SearchItem(
        cover: await analyzer.getString(rule.discoverCover),
        name: (await analyzer.getString(rule.discoverName))
            .trim()
            .replaceAll(largeSpaceRegExp, Global.fullSpace),
        author: await analyzer.getString(rule.discoverAuthor),
        chapter: await analyzer.getString(rule.discoverChapter),
        description: await analyzer.getString(rule.discoverDescription),
        url: await analyzer.getString(rule.discoverResult),
        api: this,
        tags: (await analyzer.getString(rule.discoverTags)).split(tagsSplitRegExp)
          ..removeWhere((tag) => Utils.empty(tag)),
      ));
    }
    FlutterJs.close(engineId);
    return result;
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    if (page > 1 && !rule.searchUrl.contains("page")) {
      return <SearchItem>[];
    }
    final res = await AnalyzeUrl.urlRuleParser(
      rule.searchUrl,
      rule,
      page: page,
      pageSize: pageSize,
      keyword: query,
    );
    final searchUrl = res.request.url.toString();
    final engineId = await FlutterJs.initEngine();
    await FlutterJs.evaluate(
        "cookie = ${jsonEncode(rule.cookies)}; host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(searchUrl)};",
        engineId);
    if (rule.loadJs.trim().isNotEmpty || rule.useCryptoJS) {
      final cryptoJS =
          rule.useCryptoJS ? await rootBundle.loadString(Global.cryptoJSFile) : "";
      await FlutterJs.evaluate(cryptoJS + rule.loadJs, engineId);
    }
    final list = await AnalyzerManager(
            DecodeBody().decode(res.bodyBytes, res.headers["content-type"]), engineId)
        .getElements(rule.searchList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzerManager(item, engineId);
      result.add(SearchItem(
        cover: await analyzer.getString(rule.searchCover),
        name: (await analyzer.getString(rule.searchName))
            .trim()
            .replaceAll(largeSpaceRegExp, Global.fullSpace),
        author: await analyzer.getString(rule.searchAuthor),
        chapter: await analyzer.getString(rule.searchChapter),
        description: await analyzer.getString(rule.searchDescription),
        url: await analyzer.getString(rule.searchResult),
        api: this,
        tags: (await analyzer.getString(rule.searchTags)).split(tagsSplitRegExp)
          ..removeWhere((tag) => Utils.empty(tag)),
      ));
    }
    FlutterJs.close(engineId);
    return result;
  }

  @override
  Future<List<ChapterItem>> chapter(final String url) async {
    final result = <ChapterItem>[];
    final engineId = await FlutterJs.initEngine();
    var bodyBytesLength = 0;
    for (var page = 1;; page++) {
      final chapterUrlRule = rule.chapterUrl.isNotEmpty ? rule.chapterUrl : url;
      if (page > 1 && !chapterUrlRule.contains("page")) break;
      final res = await AnalyzeUrl.urlRuleParser(
        chapterUrlRule,
        rule,
        result: url,
        page: page,
      );
      if (bodyBytesLength == res.bodyBytes.length) {
        break;
      }
      bodyBytesLength = res.bodyBytes.length;
      final chapterUrl = res.request.url.toString();
      final reversed = rule.chapterList.startsWith("-");
      await FlutterJs.evaluate(
          "cookie = ${jsonEncode(rule.cookies)}; host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(chapterUrl)}; lastResult = ${jsonEncode(url)};",
          engineId);
      if (rule.loadJs.trim().isNotEmpty || rule.useCryptoJS) {
        final cryptoJS =
            rule.useCryptoJS ? await rootBundle.loadString(Global.cryptoJSFile) : "";
        await FlutterJs.evaluate(cryptoJS + rule.loadJs, engineId);
      }
      try {
        final list = await AnalyzerManager(
                DecodeBody().decode(res.bodyBytes, res.headers["content-type"]), engineId)
            .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
        if (list.isEmpty) break;
        for (var item in (reversed ? list.reversed : list)) {
          final analyzer = AnalyzerManager(item, engineId);
          final lock = await analyzer.getString(rule.chapterLock);
          // final unLock = await analyzer.getString(rule.chapterUnLock);
          var name = (await analyzer.getString(rule.chapterName))
              .trim()
              .replaceAll(largeSpaceRegExp, Global.fullSpace);
          // if (unLock != null && unLock.isNotEmpty && unLock != "undefined" && unLock != "false") {
          //   name = "🔓" + name;
          // }else
          if (lock != null && lock.isNotEmpty && lock != "undefined" && lock != "false") {
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
    final engineId = await FlutterJs.initEngine();
    var bodyBytesLength = 0;
    for (var page = 1;; page++) {
      final contentUrlRule = rule.contentUrl.isNotEmpty ? rule.contentUrl : url;
      if (page > 1 && !contentUrlRule.contains("page")) break;
      final res = await AnalyzeUrl.urlRuleParser(
        contentUrlRule,
        rule,
        result: url,
        page: page,
      );
      if (bodyBytesLength == res.bodyBytes.length) {
        break;
      }
      bodyBytesLength = res.bodyBytes.length;
      final contentUrl = res.request.url.toString();
      if (rule.contentItems.contains("@js:")) {
        await FlutterJs.evaluate(
            "cookie = ${jsonEncode(rule.cookies)}; host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(contentUrl)}; lastResult = ${jsonEncode(url)};",
            engineId);
        if (rule.loadJs.trim().isNotEmpty || rule.useCryptoJS) {
          final cryptoJS =
              rule.useCryptoJS ? await rootBundle.loadString(Global.cryptoJSFile) : "";
          await FlutterJs.evaluate(cryptoJS + rule.loadJs, engineId);
        }
      }
      try {
        final list = await AnalyzerManager(
                DecodeBody().decode(res.bodyBytes, res.headers["content-type"]), engineId)
            .getStringList(rule.contentItems);
        if (list == null || list.isEmpty || list.join().trim().isEmpty) {
          break;
        }
        result.addAll(list);
      } catch (e) {
        break;
      }
    }
    FlutterJs.close(engineId);
    return result;
  }

  @override
  List<DiscoverMap> discoverMap() {
    final map = <DiscoverMap>[];
    final table = Map<String, int>();
    var discoverUrl = rule.discoverUrl;
    for (var url in discoverUrl.split(RegExp(r"\n+|&&"))) {
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
    return map;
  }
}
