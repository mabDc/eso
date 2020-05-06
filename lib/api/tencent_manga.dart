import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class TencentManga implements API {
  @override
  String get origin => '腾讯漫画';

  @override
  String get originTag => 'TencentManga';

  @override
  int get ruleContentType => API.MANGA;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    final query = params.values
        .where((pair) => pair.value != '')
        .map((pair) => pair.value)
        .join('/');
    final res = await http.get("https://ac.qq.com/Comic/all/page/$page/$query");
    final dom = parse(res.body);
    return dom
        .querySelectorAll('.ret-search-list li')
        .map((item) => SearchItem(
              api: this,
              cover: '${item.querySelector('img').attributes["data-original"]}',
              name: '${item.querySelector('h3 a').text}',
              author: '${item.querySelector('.ret-works-author').text}',
              chapter: '${item.querySelector('.mod-cover-list-text').text}',
              description: '${item.querySelector('.ret-works-decs').text}',
              url:
                  'https://ac.qq.com${item.querySelector('a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http
        .get("https://ac.qq.com/Comic/searchList?search=$query&page=$page");
    final dom = parse(res.body);
    return dom
        .querySelectorAll('.mod_book_list li')
        .map((item) => SearchItem(
              api: this,
              cover: '${item.querySelector('img').attributes["data-original"]}',
              name: '${item.querySelector('h4').text}',
              author: '',
              chapter: '${item.querySelector('.mod_book_update').text}',
              description: '',
              url:
                  'https://ac.qq.com${item.querySelector('a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('.chapter-page-all span')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name:
                  '${item.querySelector('i').className == "ui-icon-pay" ? "🔒" : ""}${item.text?.trim()}',
              url:
                  'https://ac.qq.com${item.querySelector('a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final s = RegExp("DATA        = '([^']*)").firstMatch(res.body)[1];
    final pic = base64Decode(s.substring(s.length % 4));
    final json = RegExp("\"picture\":([^\\]]*\\])")
        .firstMatch(String.fromCharCodes(pic))[1];
    return (jsonDecode(json) as List).map((s) => '${s["url"]}').toList();
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap('排序', <DiscoverPair>[
        DiscoverPair('更新时间', 'search/time'),
        DiscoverPair('热门人气', 'search/hot'),
      ]),
      DiscoverMap('属性', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('付费', 'vip/2'),
        DiscoverPair('免费', 'vip/1'),
        DiscoverPair('VIP免费', 'vip/3'),
      ]),
      DiscoverMap('进度', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('连载', 'finish/1'),
        DiscoverPair('完结', 'finish/2'),
      ]),
      DiscoverMap('标签', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('爆笑', 'theme/1'),
        DiscoverPair('热血', 'theme/2'),
        DiscoverPair('冒险', 'theme/3'),
        DiscoverPair('科幻', 'theme/5'),
        DiscoverPair('魔幻', 'theme/6'),
        DiscoverPair('玄幻', 'theme/7'),
        DiscoverPair('校园', 'theme/8'),
        DiscoverPair('推理', 'theme/10'),
        DiscoverPair('萌系', 'theme/11'),
        DiscoverPair('穿越', 'theme/12'),
        DiscoverPair('后宫', 'theme/13'),
        DiscoverPair('都市', 'theme/14'),
        DiscoverPair('恋爱', 'theme/15'),
        DiscoverPair('武侠', 'theme/16'),
        DiscoverPair('格斗', 'theme/17'),
        DiscoverPair('战争', 'theme/18'),
        DiscoverPair('历史', 'theme/19'),
        DiscoverPair('同人', 'theme/21'),
        DiscoverPair('竞技', 'theme/22'),
        DiscoverPair('励志', 'theme/23'),
        DiscoverPair('治愈', 'theme/25'),
        DiscoverPair('机甲', 'theme/26'),
        DiscoverPair('纯爱', 'theme/27'),
        DiscoverPair('美食', 'theme/28'),
        DiscoverPair('血腥', 'theme/29'),
        DiscoverPair('僵尸', 'theme/30'),
        DiscoverPair('恶搞', 'theme/31'),
        DiscoverPair('虐心', 'theme/32'),
        DiscoverPair('生活', 'theme/33'),
        DiscoverPair('动作', 'theme/34'),
        DiscoverPair('惊险', 'theme/35'),
        DiscoverPair('唯美', 'theme/36'),
        DiscoverPair('震撼', 'theme/37'),
        DiscoverPair('复仇', 'theme/38'),
        DiscoverPair('侦探', 'theme/39'),
        DiscoverPair('其它', 'theme/40'),
        DiscoverPair('脑洞', 'theme/41'),
        DiscoverPair('奇幻', 'theme/42'),
        DiscoverPair('宫斗', 'theme/43'),
        DiscoverPair('爆笑', 'theme/44'),
        DiscoverPair('运动', 'theme/45'),
        DiscoverPair('青春', 'theme/46'),
        DiscoverPair('穿越', 'theme/47'),
        DiscoverPair('灵异', 'theme/48'),
        DiscoverPair('古风', 'theme/49'),
        DiscoverPair('权谋', 'theme/50'),
        DiscoverPair('节操', 'theme/51'),
        DiscoverPair('明星', 'theme/52'),
        DiscoverPair('暗黑', 'theme/53'),
        DiscoverPair('社会', 'theme/54'),
        DiscoverPair('浪漫', 'theme/55'),
        DiscoverPair('栏目', 'theme/56'),
      ]),
      DiscoverMap('受众', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('少年', 'audience/1'),
        DiscoverPair('少女', 'audience/2'),
        DiscoverPair('青年', 'audience/3'),
        DiscoverPair('少儿', 'audience/4'),
      ]),
      DiscoverMap('品质', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('签约', 'state/right'),
        DiscoverPair('精品', 'state/pink'),
        DiscoverPair('热门', 'state/pop'),
        DiscoverPair('新手', 'state/rookie'),
      ]),
      DiscoverMap('类型', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('故事漫画', 'type/3'),
        DiscoverPair('轻小说', 'type/8'),
        DiscoverPair('四格', 'type/2'),
        DiscoverPair('绘本', 'type/4'),
        DiscoverPair('单幅', 'type/1'),
        DiscoverPair('同人', 'type/5'),
      ]),
      DiscoverMap('地区', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('内地', 'nation/1'),
        DiscoverPair('港台', 'nation/2'),
        DiscoverPair('韩国', 'nation/3'),
        DiscoverPair('日本', 'nation/4'),
      ]),
      DiscoverMap('版权', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('首发', 'copyright/first'),
        DiscoverPair('独家', 'copyright/sole'),
      ]),
      DiscoverMap('字母', <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("A", "mark/A"),
        DiscoverPair("B", "mark/B"),
        DiscoverPair("C", "mark/C"),
        DiscoverPair("D", "mark/D"),
        DiscoverPair("E", "mark/E"),
        DiscoverPair("F", "mark/F"),
        DiscoverPair("G", "mark/G"),
        DiscoverPair("H", "mark/H"),
        DiscoverPair("I", "mark/I"),
        DiscoverPair("J", "mark/J"),
        DiscoverPair("K", "mark/K"),
        DiscoverPair("L", "mark/L"),
        DiscoverPair("M", "mark/M"),
        DiscoverPair("N", "mark/N"),
        DiscoverPair("O", "mark/O"),
        DiscoverPair("P", "mark/P"),
        DiscoverPair("Q", "mark/Q"),
        DiscoverPair("R", "mark/R"),
        DiscoverPair("S", "mark/S"),
        DiscoverPair("T", "mark/T"),
        DiscoverPair("U", "mark/U"),
        DiscoverPair("V", "mark/V"),
        DiscoverPair("W", "mark/W"),
        DiscoverPair("X", "mark/X"),
        DiscoverPair("Y", "mark/Y"),
        DiscoverPair("Z", "mark/Z"),
        DiscoverPair("其他", "mark/9"),
      ]),
    ];
  }
}
