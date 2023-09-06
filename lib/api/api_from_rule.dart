import 'dart:convert';

import 'package:eso/api/analyzer_manager.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/utils.dart';
import '../global.dart';
import 'analyze_url.dart';
import 'package:eso/utils/decode_body.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';
import 'api_js_engine.dart';

class APIFromRUle implements API {
  final Rule rule;
  String _origin;
  String _originTag;
  int _ruleContentType;

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
    } else if (hasNextUrlRule && page > 1) {
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
      if (res != null) {
        if (res.contentLength == 0) {
          return <SearchItem>[];
        }
        discoverUrl = res.request.url.toString();
        body = DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
      }
    }
    await JSEngine.setEnvironment(page, rule, "", discoverUrl, "", "");
    final bodyAnalyzer = AnalyzerManager(body);
    if (hasNextUrlRule) {
      setNextUrl(url, await bodyAnalyzer.getString(rule.discoverNextUrl));
    } else {
      setNextUrl(url, null);
    }
    final list = await bodyAnalyzer.getElements(rule.discoverList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzerManager(item);
      final tag = await analyzer.getString(rule.discoverTags);
      List<String> tags = <String>[];
      if (tag != null && tag.trim().isNotEmpty) {
        tags = tag.split(APIConst.tagsSplitRegExp)..removeWhere((tag) => tag.isEmpty);
      }
      result.add(SearchItem(
        searchUrl: discoverUrl,
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
    return result;
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final hasNextUrlRule = rule.searchNextUrl != null && rule.searchNextUrl.isNotEmpty;
    String searchRule;
    var url = rule.searchUrl;
    final re = RegExp("url@.+@url", dotAll: true).stringMatch(query);
    if (re != null && re.isNotEmpty) {
      url = re.substring("url@".length, re.length - "@url".length);
      query = query.substring(re.length);
    }
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
      if (res != null) {
        if (res.contentLength == 0) {
          return <SearchItem>[];
        }
        searchUrl = res.request.url.toString();
        body = DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
      }
    }
    await JSEngine.setEnvironment(page, rule, "", searchUrl, query, "");
    final bodyAnalyzer = AnalyzerManager(body);
    if (hasNextUrlRule) {
      setNextUrl(url, await bodyAnalyzer.getString(rule.searchNextUrl));
    } else {
      setNextUrl(url, null);
    }
    final list = await bodyAnalyzer.getElements(rule.searchList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzerManager(item);
      final tag = await analyzer.getString(rule.searchTags);
      List<String> tags = <String>[];
      if (tag != null && tag.trim().isNotEmpty) {
        tags = tag.split(APIConst.tagsSplitRegExp)..removeWhere((tag) => tag.isEmpty);
      }
      result.add(SearchItem(
        searchUrl: searchUrl,
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
    return result;
  }

  String checkString(String s) => s != null && s.isNotEmpty ? s : null;
  static String chapterNextUrl;

  // page放进chapter里头
  @override
  Future<List<ChapterItem>> chapter(final String lastResult, [int page]) async {
    if (rule.chapterUrl == "正文") {
      return [ChapterItem(url: lastResult, name: "正文")];
    }
    API.chapterUrl = null;
    if (page != null) {
      // 这里拦截再退出
      final result = <ChapterItem>[];
      final reversed = false; //rule.chapterList.startsWith("-"); //暂时关闭
      if (page == 1) {
        chapterNextUrl = null;
      }
      try {
        final url =
            checkString(chapterNextUrl) ?? checkString(rule.chapterUrl) ?? lastResult;
        var chapterUrl = url;
        API.chapterUrl = chapterUrl;
        var body = '';
        if (url != "null") {
          final res = await AnalyzeUrl.urlRuleParser(
            url,
            rule,
            result: lastResult,
            page: page,
          );
          if (res != null) {
            if (res.contentLength == 0) {
              return result;
            }
            chapterUrl = res.request.url.toString();
            API.chapterUrl = chapterUrl;
            body = DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
          }
        }
        if (page == 1) {
          await JSEngine.setEnvironment(page, rule, "", chapterUrl, "", lastResult);
        } else {
          await JSEngine.evaluate(
              "baseUrl = ${jsonEncode(chapterUrl)}; page = ${jsonEncode(page)};");
        }
        final bodyAnalyzer = AnalyzerManager(body);
        if (rule.chapterNextUrl != null && rule.chapterNextUrl.isNotEmpty) {
          chapterNextUrl = await bodyAnalyzer.getString(rule.chapterNextUrl);
        }
        if (rule.enableMultiRoads) {
          final roads = await bodyAnalyzer.getElements(rule.chapterRoads);
          if (roads.isEmpty) {
            return result;
          }
          for (final road in roads) {
            final roadAnalyzer = AnalyzerManager(road);
            result.add(ChapterItem(
              name: "@线路" + await roadAnalyzer.getString(rule.chapterRoadName),
            ));
            final list = await roadAnalyzer
                .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
            if (list.isEmpty) {
              break;
            }
            for (final item in (reversed ? list.reversed : list)) {
              final analyzer = AnalyzerManager(item);
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
          final list = await bodyAnalyzer
              .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
          if (list.isEmpty) {
            return result;
          }
          for (final item in (reversed ? list.reversed : list)) {
            final analyzer = AnalyzerManager(item);
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
      } catch (e) {}
      return result;
    }
    final result = <ChapterItem>[];
    final reversed = rule.chapterList.startsWith("-");
    final hasNextUrlRule = rule.chapterNextUrl != null && rule.chapterNextUrl.isNotEmpty;
    final url = rule.chapterUrl != null && rule.chapterUrl.isNotEmpty
        ? rule.chapterUrl
        : lastResult;
    String next;
    String chapterUrlRule;
    for (var page = 1;; page++) {
      chapterUrlRule = null;
      if (page == 1) {
        chapterUrlRule = url;
      } else if (hasNextUrlRule) {
        if (next != null && next.isNotEmpty) {
          chapterUrlRule = next;
        }
      } else if (url.contains(APIConst.pagePattern)) {
        chapterUrlRule = url;
      }
      if (chapterUrlRule == null) {
        break;
      }
      try {
        var chapterUrl = chapterUrlRule;
        API.chapterUrl = chapterUrl;
        var body = '';
        if (chapterUrlRule != 'null') {
          final res = await AnalyzeUrl.urlRuleParser(
            chapterUrlRule,
            rule,
            result: lastResult,
            page: page,
          );
          if (res != null) {
            if (res.contentLength == 0) {
              break;
            }
            chapterUrl = res.request.url.toString();
            body = DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
          }
        }
        API.chapterUrl = chapterUrl;
        if (page == 1) {
          await JSEngine.setEnvironment(page, rule, "", chapterUrl, "", lastResult);
        } else {
          await JSEngine.evaluate(
              "baseUrl = ${jsonEncode(chapterUrl)}; page = ${jsonEncode(page)};");
        }

        final bodyAnalyzer = AnalyzerManager(body);
        if (hasNextUrlRule) {
          next = await bodyAnalyzer.getString(rule.chapterNextUrl);
        } else {
          next = null;
        }
        if (rule.enableMultiRoads) {
          final roads = await bodyAnalyzer.getElements(rule.chapterRoads);
          if (roads.isEmpty) {
            break;
          }
          for (final road in roads) {
            final roadAnalyzer = AnalyzerManager(road);
            result.add(ChapterItem(
              name: "@线路" + await roadAnalyzer.getString(rule.chapterRoadName),
            ));
            final list = await roadAnalyzer
                .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
            if (list.isEmpty) {
              break;
            }
            for (final item in (reversed ? list.reversed : list)) {
              final analyzer = AnalyzerManager(item);
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
          final list = await bodyAnalyzer
              .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
          if (list.isEmpty) {
            break;
          }
          for (final item in (reversed ? list.reversed : list)) {
            final analyzer = AnalyzerManager(item);
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
    return result;
  }

  @override
  Future<List<String>> content(final String lastResult) async {
    API.contentUrl = null;
    final result = <String>[];
    final hasNextUrlRule = rule.contentNextUrl != null && rule.contentNextUrl.isNotEmpty;
    final url = rule.contentUrl != null && rule.contentUrl.isNotEmpty
        ? rule.contentUrl
        : lastResult;
    String next;
    String contentUrlRule;
    for (var page = 1;; page++) {
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
        return result;
      }
      try {
        var contentUrl = '';
        var body = '';
        if (contentUrlRule != 'null') {
          final res = await AnalyzeUrl.urlRuleParser(
            contentUrlRule,
            rule,
            result: lastResult,
            page: page,
          );
          if (res != null) {
            if (res.contentLength == 0) {
              break;
            }
            contentUrl = res.request.url.toString();
            body = DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
          }
        }
        API.contentUrl = contentUrl;
        if (page == 1) {
          await JSEngine.setEnvironment(page, rule, "", contentUrl, "", lastResult);
        } else {
          await JSEngine.evaluate(
              "baseUrl = ${jsonEncode(contentUrl)}; page = ${jsonEncode(page)};");
        }
        final bodyAnalyzer = AnalyzerManager(body);
        if (hasNextUrlRule) {
          next = await bodyAnalyzer.getString(rule.contentNextUrl);
        } else {
          next = null;
        }
        final list = await bodyAnalyzer.getStringList(rule.contentItems);
        if (list == null || list.isEmpty || list.join().trim().isEmpty) {
          break;
        }
        result.addAll(list);
      } catch (e) {
        /// 内容为空抛出错误
        if (result.isEmpty) {
          Utils.toast("解析失败: $e");
          switch (_ruleContentType) {
            // 视频正文解析失败抛出错误
            case API.VIDEO:
              throw e;
              break;
            case API.NOVEL:
              throw e;
              break;
            case API.AUDIO:
            case API.MANGA:
              break;
            default:
          }
        }
        break;
      }
    }
    return result;
  }

  @override
  Future<List<DiscoverMap>> discoverMap() async {
    final map = <DiscoverMap>[];
    final table = Map<String, int>();
    dynamic discoverUrl = rule.discoverUrl.trimLeft();
    try {
      if (discoverUrl.startsWith("@js:")) {
        await JSEngine.setEnvironment(1, rule, "", rule.host, "", "");
        discoverUrl = await JSEngine.evaluate(
            "${JSEngine.environment};${discoverUrl.substring(4)};");
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
    } catch (e) {}
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
