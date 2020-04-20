import 'dart:convert';
import 'package:encrypt/encrypt.dart';

import 'api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Manhuadui implements API {
  @override
  String get origin => "one漫画";

  @override
  String get originTag => 'OneManhua';

  @override
  int get ruleContentType => API.MANGA;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    return parse(res.body).querySelectorAll('.itemBox,.list-comic').map((item) {
      return SearchItem(
        api: this,
        cover: '${item.querySelector('img').attributes['src']}',
        name: '${item.querySelector('.title').text}'.trim(),
        author: '${item.querySelector('.txtItme').text}',
        chapter: '${item.querySelector('.coll')?.text}',
        description: '${item.querySelector('.pd,.date').text}',
        url: '${item.querySelector('.title').attributes['href']}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return commonParse('https://m.manhuadui.com/${params["类型"].value}/$page/');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        'https://m.manhuadui.com/search/?keywords=$query&page=$page');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('#chapter-list-1 a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}'.trim(),
              url: 'https://m.manhuadui.com${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get('$url');
    final chapterImages =
        RegExp('chapterImages\\s*=\\s*"([^"]*)').firstMatch(res.body)[1];
    final chapterPath =
        RegExp('chapterPath\\s*=\\s*"([^"]*)').firstMatch(res.body)[1];

    // flutter 加密解密库当前最完整为pointycastle，教程见
    // https://github.com/PointyCastle/pointycastle#tutorials
    // 这里使用Encrypter，这个库更新较快，使用最简便
    final key = '123456781234567G';
    final iv = 'ABCDEF1G34123412';
    final imagesString =
        Encrypter(AES(Key.fromUtf8(key), mode: AESMode.cbc, padding: 'PKCS7'))
            .decrypt(Encrypted.fromBase64(chapterImages), iv: IV.fromUtf8(iv));

    final images = jsonDecode(imagesString) as List;
    var host = "https://img01.eshanyao.com";
    if (images.length == 0) return <String>['$host/images/default/common.png'];
    return images.map((filename) {
      if (filename == null || filename == '')
        return '$host/images/default/common.png';
      if (filename.contains(RegExp(
          '^https?://(images.dmzj.com|imgsmall.dmzj.com)',
          caseSensitive: false)))
        return 'https://img01.eshanyao.com/showImage.php?url=${Uri.encodeComponent(filename)}';
      if (filename.contains(RegExp('^[a-z]/', caseSensitive: false)))
        return 'https://img01.eshanyao.com/showImage.php?url=${Uri.encodeComponent("https://images.dmzj.com/" + filename)}';
      if (filename
          .contains(RegExp('^(http:|https:|ftp:)?//', caseSensitive: false)))
        return '$filename';
      return "$host/${chapterPath.replaceAll(RegExp('^/|/\$'), '')}/${filename.replaceAll(RegExp('^/'), '')}";
    }).toList();

    // final C_DATA = RegExp("C_DATA\\s*=\\s*'([^']*)").firstMatch(res.body)[1];
    // final key = 'JRUIFMVJDIWE569j';
    // final aes =
    //     Encrypter(AES(Key.fromUtf8(key), mode: AESMode.ecb, padding: 'PKCS7'))
    //         .decrypt(Encrypted(Uint8List.fromList(C_DATA.codeUnits)));
    // final info = parse(res.body).querySelector('.BarTit').text;
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap('类型', <DiscoverPair>[
        DiscoverPair('更新', 'update'),
        DiscoverPair('排行', 'rank'),
      ]),
    ];
  }
}
