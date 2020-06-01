import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../database/chapter_item.dart';
import '../../database/search_item.dart';

import '../api.dart';

class Mankezhan implements API {
  @override
  String get origin => "漫客栈";

  @override
  String get originTag => "Mankezhan";

  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(res.body);
    return (json["data"]["list"] as List)
        .map((item) => SearchItem(
              tags: <String>[],
              api: this,
              cover:
                  item["cover"] == null ? null : '${item["cover"]}!cover-400',
              name: '${item["title"]}',
              author: '${item["author_title"]}',
              chapter: '${item["chapter_title"]}',
              description: '${item["feature"]}',
              url:
                  'https://comic.mkzhan.com/chapter/?comic_id=${item["comic_id"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    final query = params.values
        .where((pair) => pair.value != '')
        .map((pair) => pair.value)
        .join('&');
    return commonParse(
        "https://comic.mkzhan.com/search/filter/?$query&page_num=$page&page_size=$pageSize");
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        "https://comic.mkzhan.com/search/keyword/?keyword=$query&page_num=$page&page_size=$pageSize");
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final json = jsonDecode(res.body);
    final comicId =
        url.substring('https://comic.mkzhan.com/chapter/?comic_id='.length);
    return (json["data"] as List).map((chapter) {
      final time = DateTime.fromMillisecondsSinceEpoch(
          int.parse(chapter["start_time"]) * 1000);
      return ChapterItem(
        cover:
            chapter["cover"] == null ? null : '${chapter["cover"]}!cover-400',
        name: '${chapter["title"]}',
        time: '$time'.trim().substring(0, 16),
        url:
            'https://comic.mkzhan.com/chapter/content/?chapter_id=${chapter["chapter_id"]}&comic_id=$comicId',
      );
    }).toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(res.body);
    return (json["data"] as List)
        .map((d) => '${d["image"]}!page-1200')
        .toList();
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap('排序', <DiscoverPair>[
        DiscoverPair('热门人气', 'order=1'),
        DiscoverPair('更新时间', 'order=2'),
      ]),
      DiscoverMap('状态', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('连载', 'finish=1'),
        DiscoverPair('完结', 'finish=2'),
      ]),
      DiscoverMap('版权', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('独家', 'copyright=1'),
        DiscoverPair('合作', 'copyright=2'),
      ]),
      DiscoverMap('收费', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('免费', 'is_free=1'),
        DiscoverPair('付费', 'is_free=0'),
      ]),
      DiscoverMap('受众', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('少年', 'audience=1'),
        DiscoverPair('少女', 'audience=2'),
        DiscoverPair('青年', 'audience=3'),
        DiscoverPair('少儿', 'audience=4'),
      ]),
      DiscoverMap('题材', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('霸总', 'theme_id=1'),
        DiscoverPair('修真', 'theme_id=2'),
        DiscoverPair('恋爱', 'theme_id=3'),
        DiscoverPair('校园', 'theme_id=4'),
        DiscoverPair('冒险', 'theme_id=5'),
        DiscoverPair('搞笑', 'theme_id=6'),
        DiscoverPair('生活', 'theme_id=7'),
        DiscoverPair('热血', 'theme_id=8'),
        DiscoverPair('架空', 'theme_id=9'),
        DiscoverPair('后宫', 'theme_id=10'),
        DiscoverPair('耽美', 'theme_id=11'),
        DiscoverPair('玄幻', 'theme_id=12'),
        DiscoverPair('悬疑', 'theme_id=13'),
        DiscoverPair('恐怖', 'theme_id=14'),
        DiscoverPair('灵异', 'theme_id=15'),
        DiscoverPair('动作', 'theme_id=16'),
        DiscoverPair('科幻', 'theme_id=17'),
        DiscoverPair('战争', 'theme_id=18'),
        DiscoverPair('古风', 'theme_id=19'),
        DiscoverPair('穿越', 'theme_id=20'),
        DiscoverPair('竞技', 'theme_id=21'),
        DiscoverPair('百合', 'theme_id=22'),
        DiscoverPair('励志', 'theme_id=23'),
        DiscoverPair('同人', 'theme_id=24'),
        DiscoverPair('真人', 'theme_id=26'),
      ]),
    ];
  }
}
