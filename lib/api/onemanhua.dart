import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:eso/model/analyze_rule/analyze_by_html.dart';
import 'package:flutter_js/flutter_js.dart';
import 'api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';

import 'package:http/http.dart' as http;

class _Onemanhua {
  final discoverUrl = r'';
  final discoverList = r'.fed-list-info>li';
  final discoverCover = r'a[data-original]@data-original';
  final discoverName = r'.fed-list-title@text';
  final discoverAuthor = r'';
  final discoverChapter = r'.fed-list-remarks@text';
  final discoverDescription = r'';
  final discoverResultUrl = r'a@href';

  final searchUrl = r'';
  final searchList = r'dl.fed-deta-info';
  final searchCover = r'a[data-original]@data-original';
  final searchName = r'h1 a@text';
  final searchAuthor = r'.fed-col-xs6@text';
  final searchChapter = r'.fed-list-remarks@text';
  final searchDescription = r'.fed-part-esan@text';
  final searchResultUrl = r'a@href';

  final chapterList = r'.all_data_list a[title]';
  final chapterCover = r'';
  final chapterName = r'text';
  final chapterTime = r'';
  final chapterLock = r'';
  final chapterResultUrl = r'href';
  final content = r'@js:...';
}

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
    final rule = _Onemanhua();
    return AnalyzerByHtml(res.body).getElements(rule.discoverList).map((e) {
      final analyzer = AnalyzerByHtml(e);
      return SearchItem(
        cover: analyzer.getString(rule.discoverCover),
        name: analyzer.getString(rule.discoverName),
        author: analyzer.getString(rule.discoverAuthor),
        chapter: analyzer.getString(rule.discoverChapter),
        description: analyzer.getString(rule.discoverDescription),
        url: 'https://www.onemanhua.com' +
            analyzer.getString(rule.discoverResultUrl),
        api: this,
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http
        .get('https://www.onemanhua.com/search?searchString=$query&page=$page');
    final rule = _Onemanhua();
    return AnalyzerByHtml(res.body).getElements(rule.searchList).map((e) {
      final analyzer = AnalyzerByHtml(e);
      return SearchItem(
        cover: analyzer.getString(rule.searchCover),
        name: analyzer.getString(rule.searchName),
        author: analyzer.getString(rule.searchAuthor),
        chapter: analyzer.getString(rule.searchChapter),
        description: analyzer.getString(rule.searchDescription),
        url: 'https://www.onemanhua.com' +
            analyzer.getString(rule.searchResultUrl),
        api: this,
      );
    }).toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final rule = _Onemanhua();
    return AnalyzerByHtml(res.body).getElements(rule.chapterList).map((e) {
      final analyzer = AnalyzerByHtml(e);
      return ChapterItem(
        cover: analyzer.getString(rule.chapterCover),
        name: analyzer.getString(rule.chapterName),
        time: analyzer.getString(rule.chapterTime),
        url: 'https://www.onemanhua.com' +
            analyzer.getString(rule.chapterResultUrl),
      );
    }).toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get('$url');
    final cData = RegExp("C_DATA\\s*=\\s*'([^']*)").firstMatch(res.body)[1];
    final key = 'JRUIFMVJDIWE569j';
    final imagesString =
        Encrypter(AES(Key.fromUtf8(key), mode: AESMode.ecb, padding: 'PKCS7'))
            .decrypt(Encrypted.fromBase64(utf8.decode(base64.decode(cData))));

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
