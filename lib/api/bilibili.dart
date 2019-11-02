import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';

class Bilibili implements API {
  @override
  String get origin => '哔哩哔哩';

  @override
  String get originTag => 'Bilibili';

  @override
  int get ruleContentType => API.VIDEO;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    if (params['分类'].name == '推荐') {
      final res = await http.get(
          'https://app.bilibili.com/x/feed/index?appkey=1d8b6e7d45233436&build=508000&login_event=0&mobi_app=android');
      final json = jsonDecode(res.body);
      return (json["data"] as List)
          .map((item) => SearchItem(
                api: this,
                cover: item["cover"] == null ? null : '${item["cover"]}',
                name: '${item["title"]}',
                author: '',
                chapter: '',
                description: '${item["desc"] ?? ''}',
                url: "${item["param"]}",
              ))
          .toList();
    }
    return <SearchItem>[];
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http.get(
        'https://app.bilibili.com/x/v2/search?appkey=1d8b6e7d45233436&build=5370000&pn=$page&ps=$pageSize&keyword=$query&order=default');
    final json = jsonDecode(res.body);
    return (json["data"]["item"] as List)
        .map((item) => SearchItem(
              api: this,
              cover: item["cover"] == null ? null : 'https:${item["cover"]}',
              name: '${item["title"]}',
              author: '${item["author"] ?? item["label"] ?? ''}',
              chapter: '',
              description: '${item["desc"] ?? item["style"] ?? ''}',
              url: "${item["param"]}",
            ))
        .toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    String appserct = "560c52ccd288fed045859ed18bffd973";
    String path = "https://app.bilibili.com/x/v2/view";
    String data =
        "aid=$url&appkey=1d8b6e7d45233436&build=5480400&ts=${DateTime.now().millisecondsSinceEpoch}";
    String sign = md5.convert(utf8.encode(data + appserct)).toString();
    final res = await http.get("$path?$data&sign=$sign");
    final json = jsonDecode(res.body);
    final d = json["data"];
    return (d["pages"] as List)
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item["part"]}',
              url: '${d["aid"]}&${item["cid"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final aid = url.split('&')[0];
    final cid = url.split('&')[1];
    String appserct = "aHRmhWMLkdeMuILqORnYZocwMBpMEOdt";
    String path = "https://app.bilibili.com/x/playurl";
    int ts = DateTime.now().millisecondsSinceEpoch;
    String data =
        "actionkey=appkey&aid=$aid&appkey=iVGUTjsxvpLeuDCf&build=5490400&buvid=XZF9F55FE566C57599024A397F5F160E74DBE&cid=$cid&device=android&expire=0&fnval=16&fnver=0&force_host=0&fourk=0&from_spmid=tm.recommend.0.0&mid=0&mobi_app=android&otype=json&platform=android&qn=64&spmid=main.ugc-video-detail.0.0&ts=$ts";
    String sign = md5.convert(utf8.encode(data + appserct)).toString();
    final res = await http.get("$path?$data&sign=$sign",
        headers: {"content-type": "application/json"});
    final json = jsonDecode(res.body);
    final dash = json["data"]["dash"];
    if (dash != null) {
      List<String> urls = <String>[];
      urls.add('${dash["video"][0]["base_url"]}');
      urls.add('audio${dash["audio"][0]["base_url"]}');
      return urls;
    }
    final durl = json["data"]["durl"];
    if (durl != null) {
      return (durl as List).map((item) => '${item["url"]}').toList();
    }
    return <String>[];
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap("分类", <DiscoverPair>[
        DiscoverPair('推荐', ''),
      ]),
    ];
  }
}
