import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_js/flutter_js.dart';

import 'api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Onemanhua implements API {
  @override
  String get origin => "one漫画";

  @override
  String get originTag => 'Onemanhua';

  @override
  int get ruleContentType => API.MANGA;

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    final res = await http.get(
        'https://www.onemanhua.com/show?orderBy=${params["类型"].value}&page=$page');
    return parse(res.body).querySelectorAll('.fed-list-info>li').map((item) {
      return SearchItem(
        api: this,
        cover:
            '${item.querySelector('a[data-original]').attributes['data-original']}',
        name: '${item.querySelector('.fed-list-title').text}'.trim(),
        author: '',
        chapter: '${item.querySelector('.fed-list-remarks').text}',
        description: '',
        url:
            'https://www.onemanhua.com${item.querySelector('a').attributes['href']}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http
        .get('https://www.onemanhua.com/search?searchString=$query&page=$page');
    return parse(res.body).querySelectorAll('dl.fed-deta-info').map((item) {
      return SearchItem(
        api: this,
        cover:
            '${item.querySelector('a[data-original]').attributes['data-original']}',
        name: '${item.querySelector('h1 a').text}'.trim(),
        author: '${item.querySelector('.fed-col-xs6').text}'.trim(),
        chapter: '${item.querySelector('.fed-col-xs12').text}',
        description: '${item.querySelector('.fed-part-esan').text}',
        url:
            'https://www.onemanhua.com${item.querySelector('a').attributes['href']}',
      );
    }).toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('.all_data_list a[title]')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}'.trim(),
              url: 'https://www.onemanhua.com${item.attributes["href"]}',
            ))
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get('$url');
    final c_data = RegExp("C_DATA\\s*=\\s*'([^']*)").firstMatch(res.body)[1];
    final key = 'JRUIFMVJDIWE569j';
    final imagesString =
        Encrypter(AES(Key.fromUtf8(key), mode: AESMode.ecb, padding: 'PKCS7'))
            .decrypt(Encrypted.fromBase64(utf8.decode(base64.decode(c_data))));

    final _idJsEngine = await FlutterJs.initEngine();
    final info = await FlutterJs.getMap("""
        $imagesString;
        var info = {mh:mh_info,image: image_info};
        info
        """, _idJsEngine);
    var d = info['image']['urls__direct'];
    if (d == '') {
      final images = <String>[];
      for (var i = 0; i < info['mh']['totalimg']; i++) {
        var ii = (i + 1).toString();
        images.add(
            'http://img.mljzmm.com/comic/${info['mh']['imgpath']}${'0' * (4 - ii.length)}$ii.jpg');
      }
      return images;
    }
    return utf8.decode(base64.decode(d)).split("|SEPARATER|").toList();
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[
      DiscoverMap('类型', <DiscoverPair>[
        DiscoverPair('更新', 'update'),
      ]),
    ];
  }
}
