import 'api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class ZZZFun implements API {
  @override
  String get origin => "ZZZFun";

  @override
  String get originTag => 'ZZZFun';

  @override
  int get ruleContentType => API.VIDEO;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    final query = params.values
        .where((pair) => pair.value != '')
        .map((pair) => pair.value)
        .join('-');
    final res =
        await http.get('http://www.zzzfun.com/vod-show-$query-page-$page');
    return parse(res.body).querySelectorAll('.search-result>a').map((item) {
      return SearchItem(
        tags: <String>[],
        api: this,
        cover: '${item.querySelector('img').attributes['src']}',
        name: '${item.querySelector('.title-big').text}',
        author: '${item.querySelectorAll('.title-sub span')[2]?.text}',
        chapter: '${item.querySelectorAll('.title-sub span')[0]?.text}',
        description: '${item.querySelector('.d-descr').text}',
        url: 'http://www.zzzfun.com${item.attributes['href']}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http
        .get('http://www.zzzfun.com/vod-search-page-$page-wd-$query.html');
    return parse(res.body).querySelectorAll('#list-focus li').map((li) {
      Map<String, String> info = Map();
      li.querySelectorAll('dl').forEach((dl) {
        if (dl.querySelector('dt') != null) {
          info.addAll({
            dl.querySelector('dt').text.replaceAll('：', ''):
                dl.querySelector('dd').text
          });
        }
      });
      return SearchItem(
        tags: <String>[],
        api: this,
        cover: '${li.querySelector('img').attributes['src']}',
        name: '${li.querySelector('h2').text}',
        author: '$info',
        chapter: '',
        description: '${li.querySelector('.juqing').text}',
        url: 'http://www.zzzfun.com${li.querySelector('a').attributes['href']}',
      );
    }).toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final chapters = <ChapterItem>[];
    int i = 1;
    parse(res.body).querySelectorAll('.episode-wrap ul').forEach((episode) {
      final episodeName = '线路${i++}';
      episode.querySelectorAll('a').forEach((item) => chapters.add(ChapterItem(
            cover: null,
            time: null,
            name: '$episodeName · ${item.text}',
            url: '${item.attributes["href"]}',
          )));
    });
    return chapters;
  }

  @override
  Future<List<String>> content(String url) async {
    //url = '/vod-play-id-513-sid-2-nid-1.html';
    RegExpMatch regExpMatch = RegExp(
            '/vod-play-id-(?<vid>\\d+)-sid-(?<sid>\\d+)-nid-(?<nid>\\d+)\\.html')
        .firstMatch(url);
    String sid = regExpMatch.namedGroup('sid');
    if (sid == '1') {
      sid = '';
    }
    return <String>[
      'http://111.230.89.165:8089/zapi/play$sid.php?url=${regExpMatch.namedGroup('vid')}-${regExpMatch.namedGroup('nid')}'
    ];
  }

  @override
  List<DiscoverMap> discoverMap() {
    // vod-show-class-搞笑-id-3-lang-日语-letter-A-year-2019.html
    return <DiscoverMap>[
      DiscoverMap('剧情', <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("搞笑", "class-搞笑"),
        DiscoverPair("热血", "class-热血"),
        DiscoverPair("催泪", "class-催泪"),
        DiscoverPair("后宫", "class-后宫"),
        DiscoverPair("机战", "class-机战"),
        DiscoverPair("致郁", "class-致郁"),
        DiscoverPair("百合", "class-百合"),
        DiscoverPair("推理", "class-推理"),
        DiscoverPair("校园", "class-校园"),
        DiscoverPair("音乐", "class-音乐"),
        DiscoverPair("社团", "class-社团"),
        DiscoverPair("装逼", "class-装逼"),
        DiscoverPair("战斗", "class-战斗"),
        DiscoverPair("日常", "class-日常"),
        DiscoverPair("恋爱", "class-恋爱"),
        DiscoverPair("冒险", "class-冒险"),
        DiscoverPair("魔幻", "class-魔幻"),
        DiscoverPair("历史", "class-历史"),
      ]),
      DiscoverMap('类型', <DiscoverPair>[
        DiscoverPair("日本动漫", "id-1"),
        DiscoverPair("春季番", "id-32"),
        DiscoverPair("夏季番", "id-33"),
        DiscoverPair("秋季番", "id-34"),
        DiscoverPair("冬季番", "id-35"),
        DiscoverPair("剧场版", "id-3"),
        DiscoverPair("ova", "id-36"),
        DiscoverPair("国产动漫", "id-2"),
        DiscoverPair("电影版", "id-37"),
      ]),
      DiscoverMap("语言", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("日语", "lang-日语"),
        DiscoverPair("国语", "lang-国语"),
        DiscoverPair("英语", "lang-英语"),
        DiscoverPair("其他", "lang-其他"),
      ]),
      DiscoverMap("字母", <DiscoverPair>[
        DiscoverPair("全部", ""),
        DiscoverPair("A", "letter-A"),
        DiscoverPair("B", "letter-B"),
        DiscoverPair("C", "letter-C"),
        DiscoverPair("D", "letter-D"),
        DiscoverPair("E", "letter-E"),
        DiscoverPair("F", "letter-F"),
        DiscoverPair("G", "letter-G"),
        DiscoverPair("H", "letter-H"),
        DiscoverPair("I", "letter-I"),
        DiscoverPair("J", "letter-J"),
        DiscoverPair("K", "letter-K"),
        DiscoverPair("L", "letter-L"),
        DiscoverPair("M", "letter-M"),
        DiscoverPair("N", "letter-N"),
        DiscoverPair("O", "letter-O"),
        DiscoverPair("P", "letter-P"),
        DiscoverPair("Q", "letter-Q"),
        DiscoverPair("R", "letter-R"),
        DiscoverPair("S", "letter-S"),
        DiscoverPair("T", "letter-T"),
        DiscoverPair("U", "letter-U"),
        DiscoverPair("V", "letter-V"),
        DiscoverPair("W", "letter-W"),
        DiscoverPair("X", "letter-X"),
        DiscoverPair("Y", "letter-Y"),
        DiscoverPair("Z", "letter-Z"),
      ]),
      DiscoverMap('时间', <DiscoverPair>[
        DiscoverPair('全部', ''),
        DiscoverPair('2019', 'year-2019'),
        DiscoverPair('2018', 'year-2018'),
        DiscoverPair('2017', 'year-2017'),
        DiscoverPair('2016', 'year-2016'),
        DiscoverPair('2015', 'year-2015'),
        DiscoverPair('2014', 'year-2014'),
        DiscoverPair('2013', 'year-2013'),
        DiscoverPair('2012', 'year-2012'),
        DiscoverPair('2011', 'year-2011'),
        DiscoverPair('2010', 'year-2010'),
      ]),
    ];
  }
}
