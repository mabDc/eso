import 'dart:convert';

import 'api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Huba implements API {
  @override
  String get origin => "胡巴影视";

  @override
  String get originTag => 'Huba';

  @override
  int get ruleContentType => API.VIDEO;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    return parse(res.body).querySelectorAll('.mlist li').map((item) {
      return SearchItem(
        tags: <String>[],
        api: this,
        cover: '${item.querySelector('img').attributes['src']}',
        name: '${item.querySelector('h2').text}'.trim(),
        author: '${item.querySelector('.info p').text}',
        chapter: '',
        description: '${item.querySelector('.info').text}',
        url: 'http://www.17185.cc${item.querySelector('a').attributes['href']}',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) async {
    return commonParse(
        'http://www.17185.cc/index.php/vod/search/page/$page/wd/东西.html');
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse(
        'http://www.17185.cc/index.php/vod/search/page/$page/wd/$query.html');
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final chapters = <ChapterItem>[];
    parse(res.body).querySelectorAll('.video_list').forEach((slide) {
      final slideName = '${slide.parent.querySelector('h2').text}';
      slide.querySelectorAll('a').forEach((item) => chapters.add(ChapterItem(
            cover: null,
            time: null,
            name: '$slideName · ${item.text}',
            url: 'http://www.17185.cc${item.attributes["href"]}',
          )));
    });
    return chapters;
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get('$url');
    final json = res.body.split('player_data=')[1].split('</script>')[0];
    return <String>[
      Uri.decodeComponent(utf8.decode(base64.decode(jsonDecode(json)["url"])))
    ];
  }

  @override
  List<DiscoverMap> discoverMap() {
    return <DiscoverMap>[];
  }
}
