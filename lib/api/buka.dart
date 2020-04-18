import 'dart:convert';

import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';

class Buka implements API {
  @override
  String get origin => "布卡";

  @override
  String get originTag => "Buka";

  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(
      String url, Map<String, String> body) async {
    final res = await http.post(url, body: body);
    final json = jsonDecode(res.body);
    return (json["datas"]["items"] as List)
        .map((item) => SearchItem(
              api: this,
              cover: '${item["logo"]}',
              name: '${item["name"]}',
              author: '${item["author"]}',
              chapter: '',
              description: '',
              url: 'http://m.buka.cn/m/${item["mid"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String,DiscoverPair> params, int page, int pageSize) async {
    List<String> query = params["分类"].value.split('&');
    return commonParse("http://m.buka.cn/category/ajax_group", {
      "start": '${pageSize * (page - 1)}',
      "count": '$pageSize',
      "fun":query[0].substring('fun='.length),
      "param":query[1].substring('param='.length),
      "gname":query[2].substring('gname='.length),
    });
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse("http://m.buka.cn/search/ajax_search", {
      "key": query,
      "start": '${pageSize * (page - 1)}',
      "count": '$pageSize',
    });
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('#episodes a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}'.replaceAll(RegExp('\\s'),''),
              url: 'http://buka.cn${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    return parse(res.body)
        .querySelectorAll('#manga-imgs img')
        .map((image) =>
            '${image.attributes["data-original"] ?? image.attributes["src"]}')
        .toList();
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap("分类", <DiscoverPair>[
        DiscoverPair('最近更新', 'fun=14&param=&gname=最近更新'),
        DiscoverPair('今日热榜', 'fun=1&param=10018&gname=今日热榜'),
        DiscoverPair('已完结', 'fun=1&param=12022&gname=已完结'),
        DiscoverPair('高分精选', 'fun=1&param=12064&gname=高分精选'),
        DiscoverPair('等待免费', 'fun=1&param=12114&gname=等待免费'),
        DiscoverPair('付费漫画', 'fun=1&param=12128&gname=付费漫画'),
        DiscoverPair('最近上新', 'fun=1&param=12084&gname=最近上新'),
        DiscoverPair('日韩', 'fun=1&param=12053&gname=日韩'),
        DiscoverPair('经典', 'fun=1&param=303&gname=经典'),
        DiscoverPair('联合出品', 'fun=1&param=12033&gname=联合出品'),
        DiscoverPair('条漫', 'fun=1&param=12036&gname=条漫'),
        DiscoverPair('百合', 'fun=1&param=206&gname=百合'),
        DiscoverPair('肥皂', 'fun=1&param=12009&gname=肥皂'),
        DiscoverPair('玄幻', 'fun=1&param=12041&gname=玄幻'),
        DiscoverPair('霸道总裁', 'fun=1&param=12116&gname=霸道总裁'),
        DiscoverPair('恋爱', 'fun=1&param=404&gname=恋爱'),
        DiscoverPair('用户原创', 'fun=1&param=12091&gname=用户原创'),
        DiscoverPair('游戏', 'fun=1&param=12018&gname=游戏'),
        DiscoverPair('治愈', 'fun=1&param=202&gname=治愈'),
        DiscoverPair('科幻', 'fun=1&param=403&gname=科幻'),
        DiscoverPair('搞笑', 'fun=1&param=10008&gname=搞笑'),
        DiscoverPair('鬼怪', 'fun=1&param=211&gname=鬼怪'),
        DiscoverPair('励志', 'fun=1&param=12023&gname=励志'),
        DiscoverPair('格斗', 'fun=1&param=410&gname=格斗'),
        DiscoverPair('少女漫', 'fun=1&param=12103&gname=少女漫'),
        DiscoverPair('少年漫', 'fun=1&param=12104&gname=少年漫'),
        DiscoverPair('真人漫', 'fun=1&param=12117&gname=真人漫'),
      ]),
    ];
  }
}
