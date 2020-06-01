import '../api.dart';
import '../../database/chapter_item.dart';
import '../../database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Yinghuaw implements API {
  @override
  String get origin => "樱花动漫W";

  @override
  String get originTag => 'Yinghuaw';

  @override
  int get ruleContentType => API.VIDEO;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    return parse(res.body).querySelectorAll('.am-list>li').map((item) {
      return SearchItem(
        tags: <String>[],
        api: this,
        cover: '${item.querySelector('img').attributes['data-original']}',
        name: '${item.querySelector('h2').text}'.trim(),
        author: '${item.querySelector('.am_list_juqing').text}',
        chapter: '',
        description: '${item.querySelector('.am_list_item_text').text}',
        url: 'https://www.6111.tv${item.querySelector('a').attributes['href']}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return commonParse(
        'https://www.6111.tv/yinghua/dongman${params["类型"].value}-$page.html');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        'https://www.6111.tv/search.php?page=$page&searchword=$query&searchtype=');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final chapters = <ChapterItem>[];
    parse(res.body).querySelectorAll('.swiper-slide').forEach((slide) {
      final slideName = '线路${slide.attributes["sort"]}';
      slide.querySelectorAll('li>a').forEach((item) => chapters.add(ChapterItem(
            cover: null,
            time: null,
            name: '$slideName · ${item.text}',
            url: 'https://www.6111.tv${item.attributes["href"]}',
          )));
    });
    return chapters;
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get('$url');
    final b = RegExp('VideoUrl=unescape\\("([^"]*)').firstMatch(res.body);
    if (b != null) {
      final res2 = await http.get(
          'https://tsdlrh.manhuafenxiao.com/GV/?u=${Uri.decodeComponent(b[1].split('%24%24')[1].split('%24')[1])}');
      final body = res2.body;
      final type1 = body.split('/GV/dp.php?url=');
      if (type1.length > 1) {
        return <String>[type1[1].split('"')[0]];
      }
      final type2 = body.split("url:'");
      if (type2.length > 1) {
        return <String>[type2[1].split("'")[0]];
      }
    }
    return <String>[];
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap('类型', <DiscoverPair>[
        DiscoverPair('国产动漫', '1'),
        DiscoverPair('日本动漫', '2'),
        DiscoverPair('欧美动漫', '3'),
        DiscoverPair('动漫电影', '4'),
        DiscoverPair('动态漫画', '5'),
      ]),
    ];
  }
}
