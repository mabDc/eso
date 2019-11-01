import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';

class U17 implements API {
  @override
  String get origin => '有妖气';

  @override
  String get originTag => 'U17';

  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(res.body);
    return (json["data"]["returnData"]["comics"] as List)
        .map((item) => SearchItem(
              api: this,
              cover: '${item["cover"]}',
              name: '${item["name"]}',
              author: '${item["author"]}',
              chapter: '',
              description:
                  '${item["description"] ?? (item["tags"] as List).join(" ")}',
              url: 'http://app.u17.com/v3/appV3_3/android/phone/comic/detail_static_new?comicid=${item["comicId"] ?? item["comic_id"]}',
            ))
        .toList();
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
    final res = await http.get('$url');
    final json = jsonDecode(res.body);
    return (json["data"]["returnData"]["chapter_list"] as List).map((chapter) {
      final passTime = chapter["pass_time"];
      final time = DateTime.fromMillisecondsSinceEpoch(
          ((passTime is int) ? passTime : int.parse(passTime)) * 1000);
      final type = chapter["type"];
      return ChapterItem(
        cover: null,
        name: '${type == 2 ? "🔒" : type == 3 ? "🔓" : ""}${chapter["name"]}',
        time: '$time'.trim().substring(0, 16),
        url:
            'http://app.u17.com/v3/appV3_3/android/phone/comic/chapterNew?chapter_id=${chapter["chapter_id"]}',
      );
    }).toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(res.body);
    final data = json["data"]["returnData"];
    List<String> images = <String>[];
    (data["image_list"] as List)
        ?.forEach((image) => images.add(image["location"]));
    (data["free_image_list"] as List)
        ?.forEach((image) => images.add(image["location"]));
    return images;
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
