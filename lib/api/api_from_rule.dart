import 'dart:convert';

import 'package:eso/api/analyzer_manager.dart';
import 'package:eso/database/rule.dart';
import 'package:flutter/services.dart';
import '../global.dart';
import 'analyze_url.dart';
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
      rule,
      page: page,
      pageSize: pageSize,
    );
    final discoverUrl = res.request.url.toString();
    final engineId = await FlutterJs.initEngine();
    await FlutterJs.evaluate(
        "host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(discoverUrl)};",
        engineId);
    if (rule.loadJs.trim().isNotEmpty) {
      await FlutterJs.evaluate(rule.loadJs, engineId);
    }
    final list = await AnalyzerManager(InputStream.autoDecode(res.bodyBytes), engineId)
        .getElements(rule.discoverList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzerManager(item, engineId);
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
      rule,
      page: page,
      pageSize: pageSize,
      keyword: query,
    );
    final searchUrl = res.request.url.toString();
    final engineId = await FlutterJs.initEngine();
    await FlutterJs.evaluate(
        "host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(searchUrl)};", engineId);
    if (rule.loadJs.trim().isNotEmpty) {
      await FlutterJs.evaluate(rule.loadJs, engineId);
    }
    final list = await AnalyzerManager(InputStream.autoDecode(res.bodyBytes), engineId)
        .getElements(rule.searchList);
    final result = <SearchItem>[];
    for (var item in list) {
      final analyzer = AnalyzerManager(item, engineId);
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

  // Future<bool> searchBackground(
  //   String query,
  //   int page,
  //   int pageSize, {
  //   int engineId,
  //   List<SearchItem> searchListNone,
  //   List<SearchItem> searchListNormal,
  //   List<SearchItem> searchListAccurate,
  //   VoidCallback successCallback,
  //   VoidCallback failureCallback,
  //   String key,
  //   Map<String, bool> keys,
  //   List<FlutterIsolate> isolates,
  // }) async {
  //   final res = await AnalyzeUrl.urlRuleParser(
  //     rule.searchUrl,
  //     rule,
  //     page: page,
  //     pageSize: pageSize,
  //     keyword: query,
  //   );
  //   final searchUrl = res.request.url.toString();
  //   final isolate = await backgroundParseSearch(
  //     searchListNone: searchListNone,
  //     searchListNormal: searchListNormal,
  //     searchListAccurate: searchListAccurate,
  //     successCallback: successCallback,
  //     failureCallback: failureCallback,
  //     rule: rule,
  //     api: this,
  //     searchUrl: searchUrl,
  //     content: InputStream.autoDecode(res.bodyBytes),
  //     keyword: query,
  //     engineId: engineId,
  //     key: key,
  //     keys: keys,
  //   );
  //   isolates.add(isolate);
  //   return true;
  // }

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
        "host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(chapterUrl)}; lastResult = ${jsonEncode(url)};",
        engineId);
    if (rule.loadJs.trim().isNotEmpty) {
      await FlutterJs.evaluate(rule.loadJs, engineId);
    }
    final list = await AnalyzerManager(InputStream.autoDecode(res.bodyBytes), engineId)
        .getElements(reversed ? rule.chapterList.substring(1) : rule.chapterList);
    final result = <ChapterItem>[];
    for (var item in list) {
      final analyzer = AnalyzerManager(item, engineId);
      final lock = await analyzer.getString(rule.chapterLock);
      var name = await analyzer.getString(rule.chapterName);
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
          "host = ${jsonEncode(rule.host)}; baseUrl = ${jsonEncode(contentUrl)}; lastResult = ${jsonEncode(url)};",
          engineId);
      if (rule.loadJs.trim().isNotEmpty) {
        await FlutterJs.evaluate(rule.loadJs, engineId);
      }
      if (rule.useCryptoJS) {
        final cryptoJS = await rootBundle.loadString(Global.cryptoJSFile);
        await FlutterJs.evaluate(cryptoJS, engineId);
      }
    }
    final temp = await AnalyzerManager(InputStream.autoDecode(res.bodyBytes), engineId)
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

// Future<FlutterIsolate> backgroundParseSearch({
//   List<SearchItem> searchListNone,
//   List<SearchItem> searchListNormal,
//   List<SearchItem> searchListAccurate,
//   VoidCallback successCallback,
//   VoidCallback failureCallback,
//   Rule rule,
//   API api,
//   String searchUrl,
//   String content,
//   String keyword,
//   int engineId,
//   String key,
//   Map<String, bool> keys,
// }) async {
//   //首先创建一个ReceivePort，为什么要创建这个？
//   //因为创建isolate所需的参数，必须要有SendPort，SendPort需要ReceivePort来创建
//   final response = new ReceivePort();
//   //开始创建isolate,Isolate.spawn函数是isolate.dart里的代码,_isolate是我们自己实现的函数
//   //_isolate是创建isolate必须要的参数。
//   //创建导致内存泄漏，应该创建一次!!
//   final isolate = await FlutterIsolate.spawn(_isolate, response.sendPort);
//   //获取sendPort来发送数据
//   final sendPort = await response.first as SendPort;
//   //接收消息的ReceivePort
//   final answer = new ReceivePort();
//   //获得数据并返回
//   answer.listen((message) {
//     if (keys[key]) {
//       if (message is String) {
//         print(message);
//         failureCallback();
//         (isolate as FlutterIsolate)
//           ..pause()
//           ..kill();
//       } else {
//         (message as List).forEach((json) {
//           final item = SearchItem.fromJson(json)..chapters = null;
//           searchListNone.add(item);
//           if (item.name.contains(keyword)) {
//             searchListNormal.add(item);
//             if (item.name == keyword) {
//               searchListAccurate.add(item);
//             }
//           }
//         });
//         successCallback();
//         (isolate as FlutterIsolate)
//           ..pause()
//           ..kill();
//       }
//     }
//   });
//   //发送数据
//   sendPort.send([
//     engineId,
//     api.ruleContentType,
//     Map<String, String>.of({
//       "host": rule.host,
//       "searchUrl": searchUrl,
//       "loadJs": rule.loadJs,
//       "content": content,
//       "searchList": rule.searchList,
//       "searchCover": rule.searchCover,
//       "searchName": rule.searchName,
//       "searchAuthor": rule.searchAuthor,
//       "searchChapter": rule.searchChapter,
//       "searchDescription": rule.searchDescription,
//       "searchResult": rule.searchResult,
//       "searchTags": rule.searchTags,
//       "origin": api.origin,
//       "originTag": api.originTag,
//     }),
//     answer.sendPort,
//   ]);
//   return isolate as FlutterIsolate;
// }

// //创建isolate必须要的参数
// void _isolate(SendPort initialReplyTo) {
//   final port = new ReceivePort();
//   //绑定
//   initialReplyTo.send(port.sendPort);
//   //监听
//   port.listen((message) async {
//     final _engineId = message[0] as int;
//     final ruleContentType = message[1] as int;
//     final ruleApiJson = message[2] as Map<String, String>;
//     final send = message[3] as SendPort;
//     //返回结果
//     try {
//       final engineId = await FlutterJs.initEngine(_engineId);
//       await FlutterJs.evaluate(
//           "host = ${jsonEncode(ruleApiJson["host"])}; baseUrl = ${jsonEncode(ruleApiJson["searchUrl"])};",
//           engineId);
//       if (ruleApiJson["loadJs"].trim().isNotEmpty) {
//         await FlutterJs.evaluate(ruleApiJson["loadJs"], engineId);
//       }
//       final list = await AnalyzerManager(ruleApiJson["content"], engineId).getElements(
//         ruleApiJson["searchList"],
//       );
//       final result = <Map<String, dynamic>>[];
//       for (var item in list) {
//         final analyzer = AnalyzerManager(item, engineId);
//         result.add(SearchItem(
//           cover: await analyzer.getString(ruleApiJson["searchCover"]),
//           name: await analyzer.getString(ruleApiJson["searchName"]),
//           author: await analyzer.getString(ruleApiJson["searchAuthor"]),
//           chapter: await analyzer.getString(ruleApiJson["searchChapter"]),
//           description: await analyzer.getString(ruleApiJson["searchDescription"]),
//           url: await analyzer.getString(ruleApiJson["searchResult"]),
//           api: BaseAPI(
//             origin: ruleApiJson["origin"],
//             originTag: ruleApiJson["originTag"],
//             ruleContentType: ruleContentType,
//           ),
//           tags: await analyzer.getStringList(ruleApiJson["searchTags"]),
//         ).toJson());
//       }
//       await FlutterJs.close(engineId);
//       send.send(result);
//     } catch (e) {
//       send.send("$e");
//     }
//   });
// }
