import 'dart:convert';

import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';

class Huanyue implements API {
  @override
  String get origin => '幻月书院';

  @override
  String get originTag => 'Huanyue';

  @override
  int get ruleContentType => API.NOVEL;

  @override
  Future<List<SearchItem>> discover(
      Map<String,DiscoverPair> params, int page, int pageSize) async {
    String query = '${params["榜单"].value}${params["类型"].value}';
    final res =
        await http.get('http://m.huanyue123.com/ph/${query}_$page.html');
    final dom = parse(utf8.decode(res.bodyBytes));
    return dom
        .querySelectorAll('.hot_sale')
        .map((item) => SearchItem(
              api: this,
              cover: '${item.querySelector('img').attributes["data-original"]}',
              name: '${item.querySelector('.title').text}'.trim(),
              author: '${item.querySelector('.author').text}'.trim(),
              chapter: '',
              description: '${item.querySelector('.review').text}'.trim(),
              url:
                  'http://m.huanyue123.com${item.querySelector('a').attributes["href"]}all.html',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http.post("http://m.huanyue123.com/s.php", body: {
      "keyword": query,
      "t": '1',
    });
    final items =
        parse(utf8.decode(res.bodyBytes)).querySelectorAll('.hot_sale');
    return items
        .skip(1)
        .map((item) => SearchItem(
              api: this,
              cover: null,
              name: '${item.querySelector('.title').text}',
              author: '${item.querySelectorAll('.author')[0].text}',
              chapter: '${item.querySelectorAll('.author')[1].text}',
              description: '',
              url:
                  'http://m.huanyue123.com${item.querySelector('a').attributes["href"]}all.html',
            ))
        .toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(utf8.decode(res.bodyBytes))
        .querySelectorAll('#chapterlist a')
        .skip(1)
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}'.trim(),
              url: 'http://m.huanyue123.com${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final text = parse(utf8.decode(res.bodyBytes))
        .querySelector('#chaptercontent')
        .text
        .split('\n')[3];
    return text.split(text.substring(0, 4)).map((s) => "　　$s").toList();
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap("榜单", <DiscoverPair>[
        DiscoverPair("周榜", "week"),
        DiscoverPair("月榜", "month"),
        DiscoverPair("总榜", "all"),
      ]),
      DiscoverMap("类型", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("玄幻", "1"),
        DiscoverPair("仙侠", "2"),
        DiscoverPair("都市", "3"),
        DiscoverPair("历史", "4"),
        DiscoverPair("网游", "5"),
        DiscoverPair("科幻", "6"),
        DiscoverPair("灵异", "7"),
        DiscoverPair("言情", "8"),
        DiscoverPair("其他", "9"),
      ]),
    ];
  }
}
