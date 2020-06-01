import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Ixs implements API {
  @override
  String get origin => '爱小说';

  @override
  String get originTag => 'Ixs';

  @override
  int get ruleContentType => API.NOVEL;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final dom = parse(utf8.decode(res.bodyBytes)).querySelectorAll('.left li');
    final reg = RegExp("\\d+\\.html");
    return dom
        .skip(1)
        .take(dom.length - 2)
        .map((item) => SearchItem(
              tags: <String>[],
              api: this,
              cover: 'http://r.ixs.cc/image/logo.png',
              name: '${item.querySelector('.n2').text}',
              author: '${item.querySelector('.a2').text}',
              chapter: '${item.querySelector('.c2').text}',
              description: '${item.querySelector('.t').text}',
              url:
                  'https:${item.querySelector('.c2 a').attributes["href"].replaceFirst(reg, "")}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    String query = params["类型"].value ?? '';
    return commonParse("https://www.ixs.cc/${query}_$page.html");
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse("https://www.ixs.cc/search.htm?keyword=$query&pn=$page");
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(utf8.decode(res.bodyBytes))
        .querySelectorAll('.mulu a')
        .skip(9)
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}'.trim(),
              url: 'https:${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    return parse(utf8.decode(res.bodyBytes))
        .querySelector('.content,.text')
        .innerHtml
        .replaceFirst(
            '''<script type="text/javascript">applyChapterSetting();</script>''',
            "").split('<br>');
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap("类型", <DiscoverPair>[
        DiscoverPair("玄幻", "xuanhuan"),
        DiscoverPair("奇幻", "qihuan"),
        DiscoverPair("修真", "xiuzhen"),
        DiscoverPair("都市", "dushi"),
        DiscoverPair("言情", "yanqing"),
        DiscoverPair("历史", "lishi"),
        DiscoverPair("同人", "tongren"),
        DiscoverPair("武侠", "wuxia"),
        DiscoverPair("科幻", "kehuan"),
        DiscoverPair("游戏", "youxi"),
        DiscoverPair("军事", "junshi"),
        DiscoverPair("竞技", "jingji"),
        DiscoverPair("灵异", "lingyi"),
        DiscoverPair("其他", "qita"),
      ]),
    ];
  }
}
