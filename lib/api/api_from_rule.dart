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

  static Map<String, String> _nextUrl;
  static Map<String, String> get nextUrl => _nextUrl;
  static void setNextUrl(String url, String next) {
    if (_nextUrl == null) {
      _nextUrl = {url: next};
    } else {
      _nextUrl[url] = next;
    }
  }

  static void clearNextUrl() {
    _nextUrl?.clear();
  }

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
    final hasNextUrlRule =
        rule.discoverNextUrl != null && rule.discoverNextUrl.isNotEmpty;
    String discoverRule;
    final url = params.values.first.value;
    if (page == 1) {
      discoverRule = url;
    } else if (hasNextUrlRule) {
      final next = _nextUrl[url];
      if (next != null && next.isNotEmpty) {
        discoverRule = next;
      }
    } else if (url.contains(APIConst.pagePattern)) {
      discoverRule = url;
    }
    if (discoverRule == null) {
      return <SearchItem>[];
    }
    var discoverUrl = '';
    var body = '';
    if (discoverRule != 'null') {
      final res = await AnalyzeUrl.urlRuleParser(
        discoverRule,
        rule,
        page: page,
        pageSize: pageSize,
      );
      if (res.contentLength == 0) {
        return <SearchItem>[];
      }
      discoverUrl = res.request.url.toString();
      body = DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
    }

    final engineId = await APIConst.initJSEngine(rule, discoverUrl);
    await FlutterJs.evaluate("page = ${jsonEncode(page)}", engineId);
    final bodyAnalyzer = AnalyzerManager(body, engineId, rule);
    if (hasNextUrlRule) {
      setNextUrl(url, await bodyAnalyzer.getString(rule.discoverNextUrl));
    } else {
      setNextUrl(url, null);
    }
    final list = await bodyAnalyzer.getElements(rule.discoverList);
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
    final hasNextUrlRule = rule.searchNextUrl != null && rule.searchNextUrl.isNotEmpty;
    String searchRule;
    final url = rule.searchUrl;
    if (page == 1) {
      searchRule = url;
    } else if (hasNextUrlRule) {
      final next = _nextUrl[url];
      if (next != null && next.isNotEmpty) {
        searchRule = next;
      }
    } else if (url.contains(APIConst.pagePattern)) {
      searchRule = url;
    }
    if (searchRule == null) {
      return <SearchItem>[];
    }

    var searchUrl = '';
    var body = '';
    if (rule.searchUrl != 'null') {
      final res = await AnalyzeUrl.urlRuleParser(
        searchRule,
        rule,
        page: page,
        pageSize: pageSize,
        keyword: query,
      );
      if (res.contentLength == 0) {
        return <SearchItem>[];
      }
      searchUrl = res.request.url.toString();
      body = DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
    }
    final engineId = await APIConst.initJSEngine(rule, searchUrl, engineId: _engineId);
    await FlutterJs.evaluate("page = ${jsonEncode(page)}", engineId);
    final bodyAnalyzer = AnalyzerManager(body, engineId, rule);
    if (hasNextUrlRule) {
      setNextUrl(url, await bodyAnalyzer.getString(rule.searchNextUrl));
    } else {
      setNextUrl(url, null);
    }
    final list = await bodyAnalyzer.getElements(rule.searchList);
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
    final reversed = rule.chapterList.startsWith("-");
    for (var page = 1;; page++) {
      final chapterUrlRule = rule.chapterUrl.isNotEmpty ? rule.chapterUrl : url;
      if (page > 1 && !chapterUrlRule.contains(APIConst.pagePattern)) {
        break;
      }
      var chapterUrl = '';
      var body = '';
      if (chapterUrlRule != 'null') {
        final res = await AnalyzeUrl.urlRuleParser(
          chapterUrlRule,
          rule,
          result: url,
          page: page,
        );
        if (res.contentLength == 0) {
          break;
        }
        chapterUrl = res.request.url.toString();
        body = DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
      }
      if (engineId == null) {
        engineId = await APIConst.initJSEngine(rule, chapterUrl, lastResult: url);
        await FlutterJs.evaluate("page = ${jsonEncode(page)}", engineId);
      } else {
        await FlutterJs.evaluate(
            "baseUrl = ${jsonEncode(chapterUrl)}; page = ${jsonEncode(page)};", engineId);
      }
      try {
        if (rule.enableMultiRoads) {
          final roads =
              await AnalyzerManager(body, engineId, rule).getElements(rule.chapterRoads);
          for (final road in roads) {
            final roadAnalyzer = AnalyzerManager(road, engineId, rule);
            result.add(ChapterItem(
              name: "@线路" + await roadAnalyzer.getString(rule.chapterRoadName),
            ));
            final list = await roadAnalyzer
                .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
            if (list.isEmpty) {
              break;
            }
            for (final item in (reversed ? list.reversed : list)) {
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
          }
        } else {
          final list = await AnalyzerManager(body, engineId, rule)
              .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
          if (list.isEmpty) {
            break;
          }
          for (final item in (reversed ? list.reversed : list)) {
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
      if (page > 1 && !contentUrlRule.contains(APIConst.pagePattern)) {
        break;
      }
      var contentUrl = '';
      var body = '';
      if (contentUrlRule != 'null') {
        final res = await AnalyzeUrl.urlRuleParser(
          contentUrlRule,
          rule,
          result: url,
          page: page,
        );
        if (res.contentLength == 0) {
          break;
        }
        contentUrl = res.request.url.toString();
        body = DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
      }
      if (engineId == null) {
        engineId = await APIConst.initJSEngine(rule, contentUrl, lastResult: url);
        await FlutterJs.evaluate("page = ${jsonEncode(page)}", engineId);
      } else {
        await FlutterJs.evaluate(
            "baseUrl = ${jsonEncode(contentUrl)}; page = ${jsonEncode(page)};", engineId);
      }
      try {
        final list =
            await AnalyzerManager(body, engineId, rule).getStringList(rule.contentItems);
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
