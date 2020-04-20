import 'dart:convert';
import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class Bainian implements API {
  @override
  String get origin => '百年';
  @override
  String get originTag => 'Bainian';
  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    return parse(res.body).querySelectorAll('#list_img li').map((item) {
      return SearchItem(
        api: this,
        cover: '${item.querySelector('img').attributes['data-src']}',
        name: '${item.querySelector('p').text}',
        author: '',
        chapter: '${item.querySelector('span').text}',
        description: '${item.querySelector('.red')?.text ?? ''}',
        url:
            'https://www.bnmanhua.com${item.querySelector('a').attributes['href']}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    String query = '${params["分类"].value}';
    if (query.contains('classid')) {
      return commonParse(
          'https://www.bnmanhua.com/index.php?m=vod-search-pg-$page-$query');
    }
    return commonParse(
        'https://www.bnmanhua.com${query.replaceFirst('searchPage', '$page')}');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        'https://www.bnmanhua.com/index.php?m=vod-search-pg-$page-wd-$query.html');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('.jslist01 a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}',
              url: 'https://www.bnmanhua.com${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    // final rule = '''
    //   var z_yurl = result.match(/z_yurl='([^']*)'/)[1];
    //   var z_img = result.match(/z_img='([^']*)'/)[1];
    //   result = JSON.parse(z_img).map((pic) => '' + z_yurl + pic)
    // ''';

    // // analyze by rule
    // // 解析流程
    // final res = await http.get(url);
    // final json = {
    //   "result": res.body,
    //   "baseUrl": url,
    // };
    // final _idJsEngine = await FlutterJs.initEngine();
    // String result = await FlutterJs.evaluate("""
    //     var json = ${jsonEncode(json)};
    //     var result = json.result;
    //     var baseUrl = json.baseUrl;
    //     $rule;
    //     JSON.stringify(result)
    //     """, _idJsEngine);
    // return (jsonDecode(result) as List).map((u) => '$u').toList();
    final res = await http.get(url);
    final zyurl = RegExp("z_yurl='([^']*)'").firstMatch(res.body)[1];
    final zimg = RegExp("z_img='([^']*)").firstMatch(res.body)[1];
    return (jsonDecode(zimg) as List).map((pic) => '$zyurl$pic').toList();
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap("分类", <DiscoverPair>[
        DiscoverPair('少年漫画', '/list/1/searchPage.html'),
        DiscoverPair('少女漫画', '/list/2/searchPage.html'),
        DiscoverPair('青年漫画', '/list/3/searchPage.html'),
        DiscoverPair('女性漫画', '/list/4/searchPage.html'),
        DiscoverPair('日韩', '/page/rihan/searchPage.html'),
        DiscoverPair('国产', '/page/guochan/searchPage.html'),
        DiscoverPair('最近更新', '/page/new/searchPage.html'),
        DiscoverPair('最新加载', '/page/wanjie/searchPage.html'),
        DiscoverPair('排行榜', '/page/hot/searchPage.html'),
        DiscoverPair('热血', 'classid-1.html'),
        DiscoverPair('玄幻', 'classid-2.html'),
        DiscoverPair('科幻', 'classid-3.html'),
        DiscoverPair('恐怖', 'classid-4.html'),
        DiscoverPair('后宫', 'classid-5.html'),
        DiscoverPair('竞技', 'classid-6.html'),
        DiscoverPair('搞笑', 'classid-7.html'),
        DiscoverPair('魔幻', 'classid-8.html'),
        DiscoverPair('恋爱', 'classid-9.html'),
        DiscoverPair('悬疑', 'classid-10.html'),
        DiscoverPair('治愈', 'classid-11.html'),
        DiscoverPair('耽美', 'classid-12.html'),
        DiscoverPair('格斗', 'classid-13.html'),
        DiscoverPair('推理', 'classid-14.html'),
        DiscoverPair('美食', 'classid-15.html'),
        DiscoverPair('励志', 'classid-16.html'),
        DiscoverPair('复仇', 'classid-17.html'),
        DiscoverPair('生活', 'classid-18.html'),
        DiscoverPair('百合', 'classid-19.html'),
        DiscoverPair('仙侠', 'classid-20.html'),
        DiscoverPair('邪恶', 'classid-21.html'),
        DiscoverPair('穿越', 'classid-22.html'),
        DiscoverPair('运动', 'classid-23.html'),
        DiscoverPair('恐怖', 'classid-24.html'),
        DiscoverPair('虐心', 'classid-25.html'),
        DiscoverPair('纯爱', 'classid-26.html'),
        DiscoverPair('暗黑', 'classid-27.html'),
        DiscoverPair('脑洞', 'classid-28.html'),
        DiscoverPair('血腥', 'classid-29.html'),
        DiscoverPair('灵异', 'classid-30.html'),
        DiscoverPair('同人', 'classid-31.html'),
        DiscoverPair('体育', 'classid-32.html'),
        DiscoverPair('惊险', 'classid-33.html'),
        DiscoverPair('真人', 'classid-34.html'),
        DiscoverPair('冒险', 'classid-35.html'),
        DiscoverPair('生活', 'classid-36.html'),
        DiscoverPair('霸总', 'classid-37.html'),
      ]),
    ];
  }
}
