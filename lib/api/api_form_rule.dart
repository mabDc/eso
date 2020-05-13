import 'dart:convert';

import 'package:eso/database/rule.dart';
import 'package:eso/model/analyze_rule/analyze_rule.dart';
import 'package:eso/model/analyze_rule/analyze_url.dart';
import 'package:eso/utils/input_stream.dart';
import 'package:flutter_js/flutter_js.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';

class APIFromRUle implements API {
  final Rule rule;
  String _origin;
  String _originTag;
  int _ruleContentType;

  @override
  String get origin => _origin;

  @override
  String get originTag => _originTag;

  @override
  int get ruleContentType => _ruleContentType;

  APIFromRUle(this.rule) {
    _origin = rule.name;
    _originTag = rule.id;
    _ruleContentType = rule.contentType;
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    if (params.isEmpty) return <SearchItem>[];
    final res = await AnalyzeUrl.urlRuleParser(
      params["分类"].value,
      host: rule.host,
      page: page,
      pageSize: pageSize,
      ua: rule.userAgent,
    );
    final discoverUrl = res.request.url.toString();
    final engineId = await FlutterJs.initEngine();
    await FlutterJs.evaluate(
        "host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(discoverUrl)};",
        engineId);
    if (rule.loadJs.trim().isNotEmpty) {
      await FlutterJs.evaluate(rule.loadJs, engineId);
    }
    final list =
        await AnalyzeRule(InputStream.autoDecode(res.bodyBytes), engineId)
            .getElements(rule.discoverList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzeRule(item, engineId);
      result.add(SearchItem(
        cover: await analyzer.getString(rule.discoverCover),
        name: await analyzer.getString(rule.discoverName),
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
      host: rule.host,
      page: page,
      pageSize: pageSize,
      key: query,
      ua: rule.userAgent,
    );
    final searchUrl = res.request.url.toString();
    final engineId = await FlutterJs.initEngine();
    await FlutterJs.evaluate(
        "host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(searchUrl)};",
        engineId);
    if (rule.loadJs.trim().isNotEmpty) {
      await FlutterJs.evaluate(rule.loadJs, engineId);
    }
    final list =
        await AnalyzeRule(InputStream.autoDecode(res.bodyBytes), engineId)
            .getElements(rule.searchList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzeRule(item, engineId);
      result.add(SearchItem(
        cover: await analyzer.getString(rule.searchCover),
        name: await analyzer.getString(rule.searchName),
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
            host: rule.host,
            result: url,
          )
        : await AnalyzeUrl.urlRuleParser(url, host: rule.host);
    final reversed = rule.chapterList.startsWith("-");
    final chapterUrl = res.request.url.toString();
    final engineId = await FlutterJs.initEngine();
    await FlutterJs.evaluate(
        "host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(chapterUrl)}; lastResult = ${jsonEncode(url)};",
        engineId);
    if (rule.loadJs.trim().isNotEmpty) {
      await FlutterJs.evaluate(rule.loadJs, engineId);
    }
    final list =
        await AnalyzeRule(InputStream.autoDecode(res.bodyBytes), engineId)
            .getElements(
                reversed ? rule.chapterList.substring(1) : rule.chapterList);
    final result = <ChapterItem>[];
    for (var item in list) {
      final analyzer = AnalyzeRule(item, engineId);
      final lock = await analyzer.getString(rule.chapterLock);
      var name = await analyzer.getString(rule.chapterName);
      if (lock != null &&
          lock.isNotEmpty &&
          lock != "undefined" &&
          lock != "false") {
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
            host: rule.host,
            result: url,
          )
        : await AnalyzeUrl.urlRuleParser(url, host: rule.host);
    final contentUrl = res.request.url.toString();
    final engineId = await FlutterJs.initEngine();
    await FlutterJs.evaluate(
        "host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(contentUrl)}; lastResult = ${jsonEncode(url)};",
        engineId);
    if (rule.loadJs.trim().isNotEmpty) {
      await FlutterJs.evaluate(rule.loadJs, engineId);
    }
    final temp = AnalyzeRule(InputStream.autoDecode(res.bodyBytes), engineId)
        .getStringList(rule.contentItems);
    FlutterJs.close(engineId);
    return temp;
  }

  @override
  List<DiscoverMap> discoverMap() {
    final pairs = <DiscoverPair>[];
    for (var url in rule.discoverUrl.split(RegExp(r"\n+|&&"))) {
      final d = url.split("::");
      if (d.length == 2) {
        pairs.add(DiscoverPair(d[0].trim(), d[1].trim()));
      }
    }
    if (pairs.isEmpty) return <DiscoverMap>[];
    return <DiscoverMap>[
      DiscoverMap("分类", pairs),
    ];
  }
}
