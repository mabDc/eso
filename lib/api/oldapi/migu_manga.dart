import 'dart:convert';

import '../api.dart';
import '../../database/chapter_item.dart';
import '../../database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class MiguManga implements API {
  @override
  String get origin => "咪咕漫画";

  @override
  String get originTag => 'MiguManga';

  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    return parse(res.body)
        .querySelectorAll('.classificationList .comic')
        .map((item) {
      return SearchItem(
        tags: <String>[],
        api: this,
        cover: '${item.querySelector('img').attributes['src']}',
        name: '${item.querySelector('h4').text}',
        author: '',
        chapter: '${item.querySelector('.ellipsis').text}',
        description: '${item.querySelector('.info').text}',
        url:
            'http://www.migudm.cn${item.querySelector('a').attributes['href']}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    final query = params.values
        .where((pair) => pair.value != '')
        .map((pair) => pair.value)
        .join('_');
    return commonParse(
        'http://www.migudm.cn/comic/list${query == '' ? '' : '_' + query}_p$page/');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    String s = base64.encode(utf8.encode(Uri.encodeFull(query)));
    return commonParse(
        'http://www.migudm.cn/search/result/list.html?hintKey=$s&hintType=2&pageSize=30&pageNo=$page');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('#ctSectionListBd a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.attributes["title"]}',
              url: 'http://www.migudm.cn${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    // http://www.migudm.cn/opus/webQueryWatchOpusInfo.html?
    // hwOpusId=090000008359&hwItemId=091000023913&index=112&opusType=2
    final res = await http.get('$url');
    final playUrlInput =
        parse(res.body).querySelector('#playUrl').attributes['value'];
    final playUrl =
        'http://www.migudm.cn/opus/webQueryWatchOpusInfo.html?$playUrlInput';
    final json = await http.get('$playUrl');
    return (jsonDecode(json.body)["data"]["jpgList"] as List)
        .map((jpg) => '${jpg["url"]}')
        .toList();
  }

  @override
  List<DiscoverMap> discoverMap() {
    // http://www.migudm.cn/comic/list_emotion_china_end_shaonv_time_p1/
    return <DiscoverMap>[
      DiscoverMap('题材', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('情感', 'emotion'),
        DiscoverPair('热血', 'adventure'),
        DiscoverPair('搞笑', 'funny'),
        DiscoverPair('玄幻', 'fantasy'),
        DiscoverPair('都市', 'urban'),
        DiscoverPair('校园', 'school'),
        DiscoverPair('悬疑', 'suspense'),
        DiscoverPair('古风', 'antiquity'),
        DiscoverPair('科幻', 'kehuan'),
        DiscoverPair('运动', 'sports'),
        DiscoverPair('萌系', 'mengxi'),
        DiscoverPair('恐怖', 'terror'),
        DiscoverPair('武侠', 'wuxia'),
        DiscoverPair('怀旧', 'classic'),
        DiscoverPair('资讯', 'news'),
        DiscoverPair('亲子', 'qinzi'),
      ]),
      DiscoverMap('地区', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('大陆', 'china'),
        DiscoverPair('日本', 'japan'),
        DiscoverPair('韩国', 'korea'),
        DiscoverPair('港台', 'hktaiwan'),
        DiscoverPair('欧美', 'europe'),
        DiscoverPair('其他', 'other'),
      ]),
      DiscoverMap("状态", <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('完结', 'end'),
        DiscoverPair('连载', 'update'),
      ]),
      DiscoverMap("受众", <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('女生', 'shaonv'),
        DiscoverPair('少年', 'child'),
        DiscoverPair('男生', 'shaonian'),
      ]),
      DiscoverMap('排序', <DiscoverPair>[
        DiscoverPair('人气', ''),
        DiscoverPair('更新', 'time'),
      ]),
    ];
  }
}
