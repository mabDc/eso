import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class Ymoxuan implements API {
  @override
  String get origin => '衍墨轩';

  @override
  String get originTag => 'Ymoxuan';

  @override
  RuleContentType get ruleContentType => RuleContentType.NOVEL;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final dom = parse(res.body).querySelectorAll('.left li');
    final reg = RegExp("\\d+\\.html");
    return dom.skip(1).take(dom.length-2)
        .map((item) => SearchItem(
      api: this,
      cover: null,
      name: '${item.querySelector('.n2').text}',
      author: '${item.querySelector('.a2').text}',
      chapter: '${item.querySelector('.c2').text}',
      description: '${item.querySelector('.t').text}',
      url: 'https:${item.querySelector('.c2 a').attributes["href"].replaceFirst(reg, "")}',
    ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(String query, int page, int pageSize) {
    return commonParse("https://www.ymoxuan.com/xuanhuan/$page.htm");
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse("https://www.ymoxuan.com/search.htm?keyword=$query&pn=$page");
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(res.body)
        .querySelectorAll('.mulu a')
        .skip(9)
        .map((item) => ChapterItem(
      cover: null,
      time: null,
      name: '${item.text}'.trim(),
      url: 'https:${item.attributes["href"]}',
    ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    return parse(res.body).querySelector('.content,.text').innerHtml.replaceFirst('''<script type="text/javascript">applyChapterSetting();</script>''', "").split('<br>');
  }
}
