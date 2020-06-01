import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../database/chapter_item.dart';
import '../../database/search_item.dart';
import '../api.dart';

class BilibiliManga implements API {
  @override
  String get origin => 'BiliBili Manga';

  @override
  String get originTag => 'BilibiliManga';

  @override
  int get ruleContentType => API.MANGA;

  String get baseUrl => "https://manga.bilibili.com";
  Map<String, String> get headers => {
        "Content-Type": "application/json; charset=utf-8",
        "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36",
      };

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    final query = params.values.map((pair) => pair.value).join(', ');
    final res = await http.post(
        "$baseUrl/twirp/comic.v1.Comic/ClassPage?device=pc&platform=web",
        body: "{$query,\"page_num\":$page,\"page_size\":18}",
        headers: headers);
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    return (json["data"] as List)
        .map((item) => SearchItem(
              tags: <String>[],
              api: this,
              cover: '${item["vertical_cover"]}',
              name: '${item["title"]}',
              author: '',
              chapter: '',
              description: '发布时间 ${item["release_time"]}',
              url: '${item["season_id"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http.post(
        '$baseUrl/twirp/comic.v1.Comic/Search?device=pc&platform=web',
        body:
            "{\"key_word\":\"$query\",\"page_num\":$page,\"page_size\":$pageSize}",
        headers: headers);
    final reg = RegExp('<\/?em.*?>');

    final json = jsonDecode(utf8.decode(res.bodyBytes));
    return (json["data"]["list"] as List)
        .map((item) => SearchItem(
              tags: <String>[],
              api: this,
              cover: '${item["vertical_cover"]}',
              name: '${item["title"]}'.replaceAll(reg, ''),
              author:
                  (item["author_name"] as List).join(', ').replaceAll(reg, ''),
              chapter: '',
              description:
                  (item["styles"] as List).join(', ').replaceAll(reg, ''),
              url: '${item["id"]}',
            ))
        .toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.post(
        '$baseUrl/twirp/comic.v2.Comic/ComicDetail?device=pc&platform=web',
        body: "{\"comic_id\":$url}",
        headers: headers);
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    return (json["data"]["ep_list"] as List)
        .map((chapter) {
          final isLocked = chapter["is_locked"];
          return ChapterItem(
            cover: '${chapter["cover"]}',
            name: '${isLocked ? "🔒" : ""}${chapter["short_title"]}',
            time: '${chapter["pub_time"]}'.substring(0, 16),
            url: '${chapter["id"]}',
          );
        })
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.post(
        "$baseUrl/twirp/comic.v1.Comic/GetImageIndex?device=pc&platform=web",
        body: "{\"ep_id\":$url}",
        headers: headers);
    final json = jsonDecode(res.body);

    if (json["msg"] != null && '${json["msg"]}' != '') {
      return <String>[
        "https://i0.hdslb.com/bfs/activity-plat/cover/20171017/496nrnmz9x.png"
      ];
    }

    final data = json["data"];
    final path = data["path"];
    String host = "https://i0.hdslb.com";
    if (data["host"] != null && '${data["host"]}' != '') {
      host = data["host"];
    }
    final res2 = await http.get('$host$path');
    final bytes = res2.bodyBytes.sublist(9);

    final m = RegExp("^\/bfs\/manga\/(\\d+)/(\\d+)").firstMatch(path);
    final cid = int.parse(m[1]);
    final epid = int.parse(m[2]);
    final key = Uint8List(8);
    key[0] = epid;
    key[1] = epid >> 8;
    key[2] = epid >> 16;
    key[3] = epid >> 24;
    key[4] = cid;
    key[5] = cid >> 8;
    key[6] = cid >> 16;
    key[7] = cid >> 24;
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = bytes[i] ^ key[i % 8];
    }
    return [];
    //final archive = ZipDecoder().decodeBytes(bytes);
    // final indexData = utf8.decode(archive.first.content);
    // final res3 = await http.post(
    //     "$baseUrl/twirp/comic.v1.Comic/ImageToken?device=pc&platform=web",
    //     body: jsonEncode({"urls": jsonEncode(jsonDecode(indexData)["pics"])}),
    //     headers: headers);
    // return (jsonDecode(res3.body)["data"] as List)
    //     .map((token) => '${token["url"]}?token=${token["token"]}')
    //     .toList();
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap("题材", <DiscoverPair>[
        DiscoverPair("全部", "\"style_id\":-1"),
        DiscoverPair("冒险", "\"style_id\":1013"),
        DiscoverPair("热血", "\"style_id\":999"),
        DiscoverPair("搞笑", "\"style_id\":994"),
        DiscoverPair("恋爱", "\"style_id\":995"),
        DiscoverPair("少女", "\"style_id\":1026"),
        DiscoverPair("日常", "\"style_id\":1020"),
        DiscoverPair("校园", "\"style_id\":1001"),
        DiscoverPair("运动", "\"style_id\":1010"),
        DiscoverPair("正能量", "\"style_id\":1028"),
        DiscoverPair("治愈", "\"style_id\":1007"),
        DiscoverPair("古风", "\"style_id\":997"),
        DiscoverPair("玄幻", "\"style_id\":1016"),
        DiscoverPair("奇幻", "\"style_id\":998"),
        DiscoverPair("惊奇", "\"style_id\":996"),
        DiscoverPair("悬疑", "\"style_id\":1023"),
        DiscoverPair("都市", "\"style_id\":1002"),
        DiscoverPair("总裁", "\"style_id\":1004")
      ]),
      DiscoverMap("地区", <DiscoverPair>[
        DiscoverPair("全部", "\"area_id\":-1"),
        DiscoverPair("大陆", "\"area_id\":1"),
        DiscoverPair("日本", "\"area_id\":2"),
        DiscoverPair("其他", "\"area_id\":5")
      ]),
      DiscoverMap("进度", <DiscoverPair>[
        DiscoverPair("全部", "\"is_finish\":-1"),
        DiscoverPair("连载", "\"is_finish\":0"),
        DiscoverPair("完结", "\"is_finish\":1"),
        DiscoverPair("新上架", "\"is_finish\":2")
      ]),
      DiscoverMap("收费", <DiscoverPair>[
        DiscoverPair("全部", "\"is_free\":-1"),
        DiscoverPair("免费", "\"is_free\":1"),
        DiscoverPair("付费", "\"is_free\":2")
      ]),
      DiscoverMap("排序", <DiscoverPair>[
        DiscoverPair("人气推荐", "\"order\":0"),
        DiscoverPair("更新时间", "\"order\":1"),
        DiscoverPair("追漫人数", "\"order\":2")
      ]),
    ];
  }
}
