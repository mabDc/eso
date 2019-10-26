import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class Duyidu implements API {
  @override
  String get origin => '读一读';

  @override
  String get originTag => 'Duyidu';

  @override
  RuleContentType get ruleContentType => RuleContentType.NOVEL;

  Future<List<SearchItem>> commonParse(String url) async {
    final res = await http.get(url);
    final items =
        parse(gbk.decode(res.bodyBytes)).querySelectorAll('#novel-list li');
    return items
        .skip(1)
        .map((item) => SearchItem(
              api: this,
              cover: 'http://duyidu.net/images/logo.png',
              name: '${item.querySelector('.col-xs-3').text}',
              author: '${item.querySelector('.col-xs-2').text}',
              chapter: '${item.querySelector('.col-xs-4').text}',
              description: '${item.querySelector('.col-xs-1,.time').text}',
              url:
                  'http://duyidu.net${item.querySelector('.col-xs-3 a').attributes["href"]}mulu.htm',
            ))
        .toList();
  }

  @override
  Future<List<SearchItem>> discover(String query, int page, int pageSize) {
    return commonParse("http://duyidu.net/shuku.htm");
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse("http://duyidu.net/search.htm?keyword=$query&pn=$page");
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    return parse(gbk.decode(res.bodyBytes))
        .querySelectorAll('#chapters-list a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}'.trim(),
              url: 'http://duyidu.net${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    return parse(gbk.decode(res.bodyBytes))
        .querySelector('#txtContent')
        .innerHtml
        .replaceFirst(
            '''<script type="text/javascript">try {applySetting();} catch(ex){}</script>''',
            "").split('<br>');
  }
}
