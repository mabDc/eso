import 'api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Manhuadui implements API {
  @override
  String get origin => "漫画堆";

  @override
  String get originTag => 'Manhuadui';

  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    return parse(res.body).querySelectorAll('.itemBox,.list-comic').map((item) {
      return SearchItem(
        api: this,
        cover: '${item.querySelector('img').attributes['src']}',
        name: '${item.querySelector('.title').text}'.trim(),
        author: '${item.querySelector('.txtItme').text}',
        chapter: '${item.querySelector('.coll').text}',
        description: '${item.querySelector('.pd,.date').text}',
        url: '${item.querySelector('.title').attributes['href']}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return commonParse('https://m.manhuadui.com/${params["类型"].value}/$page/');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        'https://m.manhuadui.com/search/?keywords=$query&page=$page');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('#chapter-list-1 a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}'.trim(),
              url: 'https://m.manhuadui.com${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get('$url');
    final info = parse(res.body).querySelector('.BarTit').text;
    final len = int.parse(RegExp('\\d+\/(\\d+)').firstMatch(info)[1]);
    final sp = url.split('.html');
    final urls = List<String>(len);
    for (var i = 0; i < len; i++) {
      urls[i] = '${sp[0]}-${i + 1}.html';
    }
    return Future.wait(urls.map((u) async {
      final r = await http.get('$u');
      return parse(r.body).querySelector('mip-img').attributes["src"];
    }));
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap('类型', <DiscoverPair>[
        DiscoverPair('更新', 'update'),
        DiscoverPair('排行', 'rank'),
      ]),
    ];
  }
}
