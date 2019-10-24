import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:fast_gbk/fast_gbk.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'api.dart';

class Iqiwx implements API {
  @override
  String get origin => '爱奇文学';

  @override
  String get originTag => 'Iqiwx';

  @override
  RuleContentType get ruleContentType => RuleContentType.NOVEL;

  @override
  Future<List<SearchItem>> discover(
      String query, int page, int pageSize) async {
    final res = await http.get('http://www.iqiwx.com/');
    final body = gbk.decode(res.bodyBytes);
    return parse(body)
        .querySelectorAll('.recomclass>dl,.recombook>dl')
        .map((item) {
      final href = item.querySelector('a').attributes["href"];
      final src = item.querySelector('img').attributes["src"];
      return SearchItem(
        api: this,
        cover: '$src',
        name: '${item.querySelector('dd a').text}',
        author: '${item.querySelector('.tit').text}',
        chapter: '',
        description: '${item.querySelector('.name').text}',
        url:
            'http://www.iqiwx.com/book/${src.substring(41, src.indexOf('/', 41))}/${href.substring(26, href.length - 5)}/',
      );
    }).toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    String gbkCodes = gbk
        .encode(query)
        .map((code) => '${urlEncode(code.toRadixString(16).toUpperCase())}')
        .join();
    final res = await http.get(
        'http://www.iqiwx.com/modules/article/search.php?searchkey=$gbkCodes&searchtype=articlename&page=$page');
    final body = gbk.decode(res.bodyBytes);
    return parse(body).querySelectorAll('#nr').map((item) {
      final td = item.querySelectorAll('td').map((td) => td.text).toList();
      final url = item.querySelector('.even a').attributes["href"];
      return SearchItem(
        api: this,
        cover: null,
        name: '${td[0]}',
        chapter: '${td[1]}',
        author: '${td[2]}',
        description: '字数 ${td[3]}  ${td[4]} · ${td[5]}',
        url: 'http://www.iqiwx.com${url.substring(0, url.lastIndexOf('/'))}/',
      );
    }).toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final body = gbk.decode(res.bodyBytes);
    return parse(body)
        .querySelectorAll('#readerlist>ul>li>a')
        .map((item) => ChapterItem(
              cover: null,
              time: null,
              name: '${item.text}',
              url: '$url${item.attributes["href"]}',
            ))
        .toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get('$url');
    final body = gbk.decode(res.bodyBytes);
    return parse(body)
        .querySelector('#content')
        .innerHtml
        .replaceAll('&nbsp;&nbsp;&nbsp;&nbsp;', '　　')
        .split('<br><br>');
  }

  String urlEncode(String s) {
    if (s.length % 2 == 1) {
      s = '0$s';
    }
    final sb = StringBuffer();
    for (int i = 0; i < s.length; i += 2) {
      sb.write('%${s[i]}${s[i + 1]}');
    }
    return sb.toString();
  }
}
