import 'package:eso/api/analyzer_jsonpath.dart';
import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';

class _U17Rule {
  final searchUrl = r'';
  final searchList = r'$.data.returnData.comics';
  final searchCover = r'$.cover';
  final searchName = r'$.name';
  final searchAuthor = r'$.author';
  final searchChapter = r'';
  final searchTags = r'$.tags';
  final searchDescription = r'$.description||$.tags.*';
  final searchResultUrl =
      r'http://app.u17.com/v3/appV3_3/android/phone/comic/detail_static_new?comicid={$.comicId||$.comic_id}';
  final chapterList = r'$["data"]["returnData"]["chapter_list"]';
  final chapterCover = r'';
  final chapterName = r'$.name';
  final chapterTime = r'$.pass_time';
  final chapterLock = r'$.type';
  final chapterResultUrl =
      r'http://app.u17.com/v3/appV3_3/android/phone/comic/chapterNew?chapter_id={$.chapter_id}';
  final content = r'$.data.returnData..location';
}

class U17 implements API {
  @override
  String get origin => '有妖气';

  @override
  String get originTag => 'U17';

  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final rule = _U17Rule();
    return AnalyzerJSonPath().parse(res.body).getElements(rule.searchList).map((item) {
      AnalyzerJSonPath analyzer = AnalyzerJSonPath().parse(item);
      return SearchItem(
        cover: analyzer.getString(rule.searchCover),
        name: analyzer.getString(rule.searchName),
        author: analyzer.getString(rule.searchAuthor),
        chapter: analyzer.getString(rule.searchChapter),
        description: analyzer.getString(rule.searchDescription),
        url: analyzer.getString(rule.searchResultUrl),
        tags: analyzer.getStringList(rule.searchTags),
        api: this,
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return commonParse(
        'http://app.u17.com/v3/appV3_3/android/phone/list/conditionScreenlists?${params["分类"].value}&page=$page');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        'http://app.u17.com/v3/appV3_3/android/phone/search/searchResult?q=$query&page=$page');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get(url);
    final rule = _U17Rule();
    return AnalyzerJSonPath()
        .parse(res.body)
        .getElements(rule.chapterList)
        .map((chapter) {
      AnalyzerJSonPath analyzer = AnalyzerJSonPath().parse(chapter);
      final passTime = chapter["pass_time"];
      final time = DateTime.fromMillisecondsSinceEpoch(
          ((passTime is int) ? passTime : int.parse(passTime)) * 1000);
      final type = chapter["type"];
      return ChapterItem(
        cover: analyzer.getString(rule.chapterCover),
        name: '${type == 2 ? "🔒" : type == 3 ? "🔓" : ""}' +
            analyzer.getString(rule.chapterName),
        url: analyzer.getString(rule.chapterResultUrl),
        time: '$time'.trim().substring(0, 16),
      );
    }).toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    return AnalyzerJSonPath().parse(res.body).getStringList(_U17Rule().content);
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap("分类", <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('搞笑', 'params=theme%3A1'),
        DiscoverPair('魔幻', 'params=theme%3A2'),
        DiscoverPair('生活', 'params=theme%3A3'),
        DiscoverPair('恋爱', 'params=theme%3A4'),
        DiscoverPair('动作', 'params=theme%3A5'),
        DiscoverPair('科幻', 'params=theme%3A6'),
        DiscoverPair('战争', 'params=theme%3A7'),
        DiscoverPair('体育', 'params=theme%3A8'),
        DiscoverPair('推理', 'params=theme%3A9'),
        DiscoverPair('惊奇', 'params=theme%3A11'),
        DiscoverPair('同人', 'params=theme%3A12'),
        DiscoverPair('少年', 'params=cate%3A1'),
        DiscoverPair('少女', 'params=cate%3A2'),
        DiscoverPair('纯爱', 'params=theme%3A10'),
        DiscoverPair('VIP', 'params=topic%3A14'),
        DiscoverPair('订阅', 'params=topic%3A12'),
        DiscoverPair('免费', 'params=vip%3A5'),
        DiscoverPair('新作', 'params=vip%3A2'),
        DiscoverPair('连载', 'params=serial%3A1'),
        DiscoverPair('完结', 'params=serial%3A2'),
      ]),
    ];
  }
}
