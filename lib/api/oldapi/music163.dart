import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../database/chapter_item.dart';
import '../../database/search_item.dart';
import '../api.dart';
import 'package:html/parser.dart' show parse;
import 'package:encrypt/encrypt.dart';

class Music163 implements API {
  @override
  String get origin => '网易歌单';

  @override
  String get originTag => 'Music163';

  @override
  int get ruleContentType => API.AUDIO;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    String url =
        'https://music.163.com/discover/playlist/?order=hot&cat=${params["分类"].value}&limit=$pageSize&offset=${(page - 1) * pageSize}';
    final res = await http.get(url);
    return parse(utf8.decode(res.bodyBytes))
        .querySelectorAll('#m-pl-container>li')
        .map((item) => SearchItem(
              tags: <String>[],
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
    final res = await http
        .post('https://music.163.com/weapi/cloudsearch/get/web?csrf_token=',
            body: genParams(jsonEncode({
              "s": "$query",
              "type": "1000",
              "offset": "${pageSize * (page - 1)}",
              "total": "true",
              "limit": "$pageSize",
              "csrf_token": ""
            })),
            headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36',
          'Referer': 'https://music.163.com/search/',
          'Content-Type': 'application/x-www-form-urlencoded',
        });
    return (jsonDecode(res.body)["result"]["playlists"] as List)
        .map((item) => SearchItem(
              tags: <String>[],
              api: this,
              cover: '${item["coverImgUrl"]}',
              name: '${item["name"]}',
              author: '${item["creator"]["nickname"]}',
              chapter: '',
              description: '${item["description"]}',
              url: 'https://music.163.com/m/playlist?id=${item["id"]}',
            ))
        .toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res =
        await http.get('$url'.replaceFirst("music", 'y.music'), headers: {
      "User-Agent":
          "Mozilla/5.0 (Linux; Android 8.0.0; MIX 2 Build/OPR1.170623.027) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.106 YaBrowser/18.9.1.2199.00 Mobile Safari/537.36"
    });
    final a =
        parse(utf8.decode(res.bodyBytes)).querySelectorAll('.pylst_list a');
    return a
        .map((item) => ChapterItem(
              cover: null,
              time: '${item.querySelector('.sginfo').text}',
              name: '${item.querySelector('.sgtl').text}',
              url:
                  'http://music.163.com/song/media/outer/url?id=${item.attributes["href"].split("id=")[1]}',
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

  dynamic genParams(String query) {
    final nonce = '0CoJUm6Qyw8W8jud';
    final iv = '0102030405060708';
    final modulus =
        '00e0b509f6259df8642dbc35662901477df22677ec152b5ff68ace615bb7b725152b3ab17a876aea8a5aa76d2e417629ec4ee341f56135fccf695280104e0312ecbda92557c93870114af6c9d05c4f7f0c3685b7a46bee255932575cce10b424d813cfe4875d3e82047b97ddef52741d546b8e289dc6935b3ece0462db0a22b8e7';
    final pubKey = '010001';
    final genKey = randomKey(16);
    final aes = Encrypter(AES(Key.fromUtf8(nonce), mode: AESMode.cbc))
        .encrypt(query, iv: IV.fromUtf8(iv))
        .base64;
    final params = Encrypter(AES(Key.fromUtf8(genKey), mode: AESMode.cbc))
        .encrypt(aes, iv: IV.fromUtf8(iv))
        .base64;

    final text = genKey.split('').reversed.join();
    BigInt integer = BigInt.parse(
        utf8.encode(text).map((i) {
          String s = i.toRadixString(16);
          return '${'0' * (2 - s.length)}$s';
        }).join(),
        radix: 16);
    BigInt pubkeyInt = BigInt.parse(pubKey, radix: 16);
    BigInt modulusInt = BigInt.parse(modulus, radix: 16);
    String encSecKey = integer.modPow(pubkeyInt, modulusInt).toRadixString(16);
    encSecKey = '${"0" * (encSecKey.length - 256)}$encSecKey';
    return {
      "params": params,
      "encSecKey": encSecKey,
    };
  }

  String randomKey(int len) {
    String s = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    StringBuffer sb = StringBuffer();
    Random r = Random();
    for (int i = 0; i < len; i++) {
      sb.write(s[r.nextInt(s.length)]);
    }
    return sb.toString();
  }
}
