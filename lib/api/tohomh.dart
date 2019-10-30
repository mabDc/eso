import 'dart:convert';

import 'api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Tohomh implements API {
  @override
  String get origin => "土豪漫画";

  @override
  String get originTag => 'Tohomh';

  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    return parse(res.body).querySelectorAll('div.mh-item').map((item) {
      final style = item.querySelector('p.mh-cover').attributes["style"];
      return SearchItem(
        api: this,
        cover: '${style.substring(style.indexOf('(') + 1, style.indexOf(')'))}',
        name: '${item.querySelector('h2 a').text}',
        author: '',
        chapter: '${item.querySelector('.chapter a').text}',
        description:
            '评分 ${item.querySelector('.zl .mh-star-line').attributes["class"].split(' ').last}',
        url:
            'https://www.tohomh123.com${item.querySelector('h2 a').attributes["href"]}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return commonParse(
        'https://www.tohomh123.com/f-1-${params["题材"].value}-${params["地区"].value}---${params["字母"].value}-${params["排序"].value}-${params["进度"].value}-$page.html');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        'https://www.tohomh123.com/action/Search?keyword=$query&page=$page');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('#detail-list-select-2 a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}',
              url: 'https://www.tohomh123.com${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get('$url');
    final body = res.body;

/*
var imgDomain = 'https://mh1.zhengdongwuye.cn';
var did=33705;
var sid=10;
var iid = 2;//1;
var pcount = 95;
var finished = true;
var nextPlayDataUrl = '';
var bq = 0;
var pl = 'https://mh3.zhengdongwuye.cn/upload/yulezhishang/8064529/0000.jpg';
var bqimg = '/pic/banquan.png';
*/
    final did = RegExp('var did\\s*=\\s*(\\d+)').firstMatch(body)[1];
    final sid = RegExp('var sid\\s*=\\s*(\\d+)').firstMatch(body)[1];
    final iid = int.parse(RegExp('var iid\\s*=\\s*(\\d+)').firstMatch(body)[1]);
    final pcount =
        int.parse(RegExp('var pcount\\s*=\\s*(\\d+)').firstMatch(body)[1]);
    final urls = List<String>(pcount);
    for (var i = 0; i < pcount; i++) {
      urls[i] =
          "https://www.tohomh123.com/action/play/read?did=$did&sid=$sid&iid=${iid + i}";
    }
    return Future.wait(urls.map((u) async {
      final r = await http.get('$u');
      return jsonDecode(r.body)["Code"];
    }));
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap('排序', <DiscoverPair>[
        DiscoverPair('更新时间', 'updatetime'),
        DiscoverPair('热门人气', 'hits'),
        DiscoverPair('新品上架', 'addtime'),
      ]),
      DiscoverMap("地区", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("国漫", "国漫"),
        DiscoverPair("日本", "日本"),
        DiscoverPair("欧美", "欧美"),
      ]),
      DiscoverMap('进度', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('连载', '1'),
        DiscoverPair('完结', '0'),
      ]),
      DiscoverMap("字母", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("A", "A"),
        DiscoverPair("B", "B"),
        DiscoverPair("C", "C"),
        DiscoverPair("D", "D"),
        DiscoverPair("E", "E"),
        DiscoverPair("F", "F"),
        DiscoverPair("G", "G"),
        DiscoverPair("H", "H"),
        DiscoverPair("I", "I"),
        DiscoverPair("J", "J"),
        DiscoverPair("K", "K"),
        DiscoverPair("L", "L"),
        DiscoverPair("M", "M"),
        DiscoverPair("N", "N"),
        DiscoverPair("O", "O"),
        DiscoverPair("P", "P"),
        DiscoverPair("Q", "Q"),
        DiscoverPair("R", "R"),
        DiscoverPair("S", "S"),
        DiscoverPair("T", "T"),
        DiscoverPair("U", "U"),
        DiscoverPair("V", "V"),
        DiscoverPair("W", "W"),
        DiscoverPair("X", "X"),
        DiscoverPair("Y", "Y"),
        DiscoverPair("Z", "Z"),
      ]),
      DiscoverMap('题材', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('热血', '1'),
        DiscoverPair('恋爱', '2'),
        DiscoverPair('校园', '3'),
        DiscoverPair('百合', '4'),
        DiscoverPair('彩虹', '5'),
        DiscoverPair('冒险', '6'),
        DiscoverPair('后宫', '7'),
        DiscoverPair('仙侠', '8'),
        DiscoverPair('武侠', '9'),
        DiscoverPair('悬疑', '10'),
        DiscoverPair('推理', '11'),
        DiscoverPair('搞笑', '12'),
        DiscoverPair('奇幻', '13'),
        DiscoverPair('猎奇', '14'),
        DiscoverPair('玄幻', '15'),
        DiscoverPair('古风', '16'),
        DiscoverPair('萌系', '17'),
        DiscoverPair('日常', '18'),
        DiscoverPair('治愈', '19'),
        DiscoverPair('烧脑', '20'),
        DiscoverPair('穿越', '21'),
        DiscoverPair('都市', '22'),
        DiscoverPair('腹黑', '23'),
      ]),
    ];
  }
}
