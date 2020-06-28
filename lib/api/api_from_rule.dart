import 'dart:convert';

import 'package:eso/api/analyzer_manager.dart';
import 'package:eso/database/rule.dart';
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
    final res = await AnalyzeUrl.urlRuleParser(
      params.values.first.value,
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
            .replaceAll(RegExp(r"\n+"), Global.fullSpace),
        author: await analyzer.getString(rule.discoverAuthor),
        chapter: await analyzer.getString(rule.discoverChapter),
        description: await analyzer.getString(rule.discoverDescription),
        url: await analyzer.getString(rule.discoverResult),
        api: this,
        tags: await analyzer.getStringList(rule.discoverTags),
      ));
    }
    FlutterJs.close(engineId);
    return result;
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
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
            .replaceAll(RegExp(r"\n+"), Global.fullSpace),
        author: await analyzer.getString(rule.searchAuthor),
        chapter: await analyzer.getString(rule.searchChapter),
        description: await analyzer.getString(rule.searchDescription),
        url: await analyzer.getString(rule.searchResult),
        api: this,
        tags: await analyzer.getStringList(rule.searchTags),
      ));
    }
    FlutterJs.close(engineId);
    return result;
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = rule.chapterUrl.isNotEmpty
        ? await AnalyzeUrl.urlRuleParser(
            rule.chapterUrl,
            rule,
            result: url,
          )
        : await AnalyzeUrl.urlRuleParser(url, rule);
    final reversed = rule.chapterList.startsWith("-");
    final chapterUrl = res.request.url.toString();
    final engineId = await FlutterJs.initEngine();
    await FlutterJs.evaluate(
        "cookie = ${jsonEncode(rule.cookies)}; host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(chapterUrl)}; lastResult = ${jsonEncode(url)};",
        engineId);
    if (rule.loadJs.trim().isNotEmpty || rule.useCryptoJS) {
      final cryptoJS =
          rule.useCryptoJS ? await rootBundle.loadString(Global.cryptoJSFile) : "";
      await FlutterJs.evaluate(cryptoJS + rule.loadJs, engineId);
    }
    final list = await AnalyzerManager(
            DecodeBody().decode(res.bodyBytes, res.headers["content-type"]), engineId)
        .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
    final result = <ChapterItem>[];
    for (var item in list) {
      final analyzer = AnalyzerManager(item, engineId);
      final lock = await analyzer.getString(rule.chapterLock);
      // final unLock = await analyzer.getString(rule.chapterUnLock);
      var name = (await analyzer.getString(rule.chapterName))
          .trim()
          .replaceAll(RegExp(r"\n+"), Global.fullSpace);
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
    FlutterJs.close(engineId);
    return reversed ? result.reversed.toList() : result;
  }

  @override
  Future<List<String>> content(String url) async {
    final res = rule.contentUrl.isNotEmpty
        ? await AnalyzeUrl.urlRuleParser(
            rule.contentUrl,
            rule,
            result: url,
          )
        : await AnalyzeUrl.urlRuleParser(url, rule);
    final contentUrl = res.request.url.toString();
    final engineId = await FlutterJs.initEngine();
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
    final temp = await AnalyzerManager(
            DecodeBody().decode(res.bodyBytes, res.headers["content-type"]), engineId)
        .getStringList(rule.contentItems);
    FlutterJs.close(engineId);
    return temp;
  }

  @override
  List<DiscoverMap> discoverMap() {
    final map = <DiscoverMap>[];
    final table = {};
    for (var url in rule.discoverUrl.split(RegExp(r"\n+|&&"))) {
      final d = url.split("::");
      if (d.length == 2) {
        map.add(DiscoverMap(d[0].trim(), <DiscoverPair>[
          DiscoverPair("全部", d[1].trim()),
        ]));
      } else if (d.length == 3) {
        final tab = d[0].trim();
        if (table[tab] == null) {
          table[tab] = map.length;
          map.add(DiscoverMap(d[0].trim(), <DiscoverPair>[
            DiscoverPair(d[1].trim(), d[2].trim()),
          ]));
        } else {
          map[table[tab]].pairs.add(DiscoverPair(d[1].trim(), d[2].trim()));
        }
      }
    }
    return map;
  }
}
