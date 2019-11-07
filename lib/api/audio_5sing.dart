import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';
import 'package:html/parser.dart' show parse;

class Audio5sing implements API {
  @override
  String get origin => '5sing';

  @override
  String get originTag => 'Audio5sing';

  @override
  int get ruleContentType => API.AUDIO;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    String url = 'http://5sing.kugou.com/${params["作品"].value}/list?';
    String query = params.entries
        .where((entry) => entry.value.value != '' && entry.key != '作品')
        .map((entry) => entry.value.value)
        .join('&');
    final res = await http.get("$url$query&p=$page");
    final dom = parse(utf8.decode(res.bodyBytes));
    return dom
        .querySelectorAll('.lists>dl')
        .map((item) => SearchItem(
              api: this,
              cover: '${item.querySelector('img').attributes["src"]}',
              name: '${item.querySelector('h3').text}'.trim(),
              author: '${item.querySelector('.m_z').text}'.trim(),
              chapter: '',
              description:
                  '时间 ${item.querySelector('.l_time').text} · 人气 ${item.querySelector('.l_rq').text}',
              url:
                  'http://5sing.kugou.com${item.querySelector('h3 a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http.get(
        'http://search.5sing.kugou.com/home/json?keyword=$query&sort=1&page=$page&filter=0&type=0');
    final json = jsonDecode(res.body);
    final reg = RegExp('<\/?em.*?>');
    return (json["list"] as List)
        .map((item) => SearchItem(
              api: this,
              cover: null,
              name: '${item["songName"]}'.replaceAll(reg, ''),
              author: '${item["singer"]}',
              chapter: '',
              description: '${item["typeName"]} ${item["style"]}',
              url: '${item["songurl"]}',
            ))
        .toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final dom = parse(res.body);
    final matcher = RegExp('(yc|fc)/(\\d+)').firstMatch(url);
    final img = dom.querySelector('.lrc_box img');
    return <ChapterItem>[
      ChapterItem(
        cover: img == null ? null : '${img.attributes["src"] ?? ''}',
        time: '${dom.querySelector('.view_box a').text}'.trim(),
        name: '${dom.querySelector('h1').text}'.trim(),
        url:
            'http://service.5sing.kugou.com/song/getSongUrl?version=6.6.70&songid=${matcher[2]}&songtype=${matcher[1]}',
      ),
    ];
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final data = jsonDecode(res.body)["data"];
    return <String>[
      '${clearString(data["squrl"]) ?? clearString(data["hqurl"]) ?? clearString(data["lqurl"])}'
    ];
  }

  String clearString(String s) => s == '' ? null : s;

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap("作品", <DiscoverPair>[
        DiscoverPair('原创', 'yc'),
        DiscoverPair('翻唱', 'fc'),
      ]),
      DiscoverMap("排序", <DiscoverPair>[
        DiscoverPair('最新上传', 't=-1'),
        DiscoverPair('网站推荐', 't=1'),
        DiscoverPair('候选推荐', 't=2'),
      ]),
      DiscoverMap("语种", <DiscoverPair>[
        DiscoverPair('全部', 'l='),
        DiscoverPair('华语', 'l=华语'),
        DiscoverPair('欧美', 'l=欧美'),
        DiscoverPair('日语', 'l=日语'),
        DiscoverPair('韩语', 'l=韩语'),
        DiscoverPair('俄语', 'l=俄语'),
        DiscoverPair('法语', 'l=法语'),
        DiscoverPair('德语', 'l=德语'),
        DiscoverPair('粤语', 'l=粤语'),
        DiscoverPair('闽南语', 'l=闽南语'),
        DiscoverPair('方言', 'l=方言'),
        DiscoverPair('西班牙语', 'l=西班牙语'),
        DiscoverPair('其它', 'l=其它'),
      ]),
      DiscoverMap("曲风", <DiscoverPair>[
        DiscoverPair('全部', 's='),
        DiscoverPair('古风', 's=古风'),
        DiscoverPair('流行', 's=流行'),
        DiscoverPair('民谣', 's=民谣'),
        DiscoverPair('摇滚', 's=摇滚'),
        DiscoverPair('RAP/说唱', 's=RAP/说唱'),
        DiscoverPair('动漫/游戏', 's=动漫/游戏'),
        DiscoverPair('民族', 's=民族'),
        DiscoverPair('美声', 's=美声'),
        DiscoverPair('R&B', 's=R&B'),
        DiscoverPair('广播剧', 's=广播剧'),
        DiscoverPair('搞笑/另类', 's=搞笑/另类'),
        DiscoverPair('爵士', 's=爵士'),
        DiscoverPair('电子', 's=电子'),
        DiscoverPair('HIP-HOP', 's=HIP-HOP'),
        DiscoverPair('DJ/舞曲', 's=DJ/舞曲'),
        DiscoverPair('影视', 's=影视'),
        DiscoverPair('对唱/合唱', 's=对唱/合唱'),
        DiscoverPair('儿歌', 's=儿歌'),
        DiscoverPair('红歌', 's=红歌'),
        DiscoverPair('古典', 's=古典'),
        DiscoverPair('纯音乐', 's=纯音乐'),
        DiscoverPair('新世纪', 's=新世纪'),
        DiscoverPair('戏曲/曲艺', 's=戏曲/曲艺'),
        DiscoverPair('填词', 's=填词'),
        DiscoverPair('朗诵', 's=朗诵'),
        DiscoverPair('R & B', 's=R & B'),
        DiscoverPair('影视', 's=影视'),
        DiscoverPair('戏曲/曲艺', 's=戏曲/曲艺'),
      ]),
    ];
  }
}
