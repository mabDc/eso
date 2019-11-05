import 'dart:convert';

import 'package:http/http.dart' as http;

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';
import 'package:html/parser.dart' show parse;

class Music163 implements API {
  @override
  String get origin => '网易云';

  @override
  String get originTag => 'Music163';

  @override
  int get ruleContentType => API.AUDIO;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    String url =
        'https://music.163.com/#/discover/playlist/?order=hot&cat=${params["分类"].value}&limit=$pageSize&offset=${(page - 1) * pageSize}';
    final res = await http.get(url);
    return parse(utf8.decode(res.bodyBytes))
        .querySelectorAll('#m-pl-container>li')
        .map((item) => SearchItem(
              api: this,
              cover: '${item.querySelector('img').attributes["src"]}',
              name: '${item.querySelector('.dec').text}'.trim(),
              author: '${item.querySelector('.nm').text}'.trim(),
              chapter: '',
              description: '播放 ${item.querySelector('.nb').text}',
              url:
                  'https://music.163.com/m${item.querySelector('a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http.get('https://music.163.com/discover/playlist');
    return parse(utf8.decode(res.bodyBytes))
        .querySelectorAll('#m-pl-container>li')
        .map((item) => SearchItem(
              api: this,
              cover: '${item.querySelector('img').attributes["src"]}',
              name: '${item.querySelector('.dec').text}'.trim(),
              author: '${item.querySelector('.nm').text}'.trim(),
              chapter: '',
              description: '播放 ${item.querySelector('.nb').text}',
              url:
                  'https://music.163.com/m${item.querySelector('a').attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url', headers: {
      "User-Agent":
          "Mozilla/5.0 (Linux; Android 8.0.0; MIX 2 Build/OPR1.170623.027) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 YaBrowser/18.9.1.2199.00 Mobile Safari/537.36"
    });
    final json = res.body
        .split(RegExp('REDUX_STATE\\s*=\\s*'))[1]
        .split(RegExp(';\\s*<'))[0];
    return (jsonDecode(json)["Playlist"]["data"] as List)
        .map((item) => ChapterItem(
              cover: null,
              time: '${item["singerName"]}',
              name: '${item["songName"]}',
              url: 'http://music.163.com/song/media/outer/url?id=${item["id"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final id =
        url.substring('http://music.163.com/song/media/outer/url?id='.length);
    final res = await http.get('https://music.163.com/song?id=$id');
    final src = parse(utf8.decode(res.bodyBytes))
        .querySelector('.u-cover img')
        .attributes["data-src"];
    return <String>['$url', 'cover$src'];
  }

  String clearString(String s) => s == '' ? null : s;

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap("分类", <DiscoverPair>[
        DiscoverPair('全部', '全部'),
        DiscoverPair('华语', '华语'),
        DiscoverPair('欧美', '欧美'),
        DiscoverPair('日语', '日语'),
        DiscoverPair('韩语', '韩语'),
        DiscoverPair('粤语', '粤语'),
        DiscoverPair('小语种', '小语种'),
        DiscoverPair('流行', '流行'),
        DiscoverPair('摇滚', '摇滚'),
        DiscoverPair('民谣', '民谣'),
        DiscoverPair('电子', '电子'),
        DiscoverPair('舞曲', '舞曲'),
        DiscoverPair('说唱', '说唱'),
        DiscoverPair('轻音乐', '轻音乐'),
        DiscoverPair('爵士', '爵士'),
        DiscoverPair('乡村', '乡村'),
        DiscoverPair('R&B/Soul', 'R%26B%2FSoul'),
        DiscoverPair('古典', '古典'),
        DiscoverPair('民族', '民族'),
        DiscoverPair('英伦', '英伦'),
        DiscoverPair('金属', '金属'),
        DiscoverPair('朋克', '朋克'),
        DiscoverPair('蓝调', '蓝调'),
        DiscoverPair('雷鬼', '雷鬼'),
        DiscoverPair('世界音乐', '世界音乐'),
        DiscoverPair('拉丁', '拉丁'),
        DiscoverPair('另类/独立', '另类%2F独立'),
        DiscoverPair('New Age', 'New Age'),
        DiscoverPair('古风', '古风'),
        DiscoverPair('后摇', '后摇'),
        DiscoverPair('Bossa Nova', 'Bossa Nova'),
        DiscoverPair('清晨', '清晨'),
        DiscoverPair('夜晚', '夜晚'),
        DiscoverPair('学习', '学习'),
        DiscoverPair('工作', '工作'),
        DiscoverPair('午休', '午休'),
        DiscoverPair('下午茶', '下午茶'),
        DiscoverPair('地铁', '地铁'),
        DiscoverPair('驾车', '驾车'),
        DiscoverPair('运动', '运动'),
        DiscoverPair('旅行', '旅行'),
        DiscoverPair('散步', '散步'),
        DiscoverPair('酒吧', '酒吧'),
        DiscoverPair('怀旧', '怀旧'),
        DiscoverPair('清新', '清新'),
        DiscoverPair('浪漫', '浪漫'),
        DiscoverPair('性感', '性感'),
        DiscoverPair('伤感', '伤感'),
        DiscoverPair('治愈', '治愈'),
        DiscoverPair('放松', '放松'),
        DiscoverPair('孤独', '孤独'),
        DiscoverPair('感动', '感动'),
        DiscoverPair('兴奋', '兴奋'),
        DiscoverPair('快乐', '快乐'),
        DiscoverPair('安静', '安静'),
        DiscoverPair('思念', '思念'),
        DiscoverPair('影视原声', '影视原声'),
        DiscoverPair('ACG', 'ACG'),
        DiscoverPair('儿童', '儿童'),
        DiscoverPair('校园', '校园'),
        DiscoverPair('游戏', '游戏'),
        DiscoverPair('70后', '70后'),
        DiscoverPair('80后', '80后'),
        DiscoverPair('90后', '90后'),
        DiscoverPair('网络歌曲', '网络歌曲'),
        DiscoverPair('KTV', 'KTV'),
        DiscoverPair('经典', '经典'),
        DiscoverPair('翻唱', '翻唱'),
        DiscoverPair('吉他', '吉他'),
        DiscoverPair('钢琴', '钢琴'),
        DiscoverPair('器乐', '器乐'),
        DiscoverPair('榜单', '榜单'),
        DiscoverPair('00后', '00后'),
      ]),
    ];
  }
}
