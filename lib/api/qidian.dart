import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/api.dart';
import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'package:html/parser.dart' show parse;

class Qidian implements API{
  @override
  String get origin => '起点';

  @override
  String get originTag => 'Qidian';

  @override
  RuleContentType get ruleContentType => RuleContentType.NOVEL;

  Future<List<SearchItem>> commonParse(String url)async{
    final res = await http.get(url);
    return parse(res.body).querySelectorAll('.all-img-list li').map((item) => SearchItem(
      api: this,
      cover: 'https:${item.querySelector('.book-img-box img').attributes["src"]}',
      name: '${item.querySelector('h4 a').text}',
      author: '${item.querySelector('.author a').text}',
      chapter: '${item.querySelector('.update').text}',
      description: '${item.querySelector('.intro').text}',
      url: '${item.querySelector('h4 a').attributes["data-bid"]}',
    )).toList();
  }

  @override
  Future<List<SearchItem>> discover(String query, int page, int pageSize) async {
    return commonParse("https://www.qidian.com/all?page=$page");
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return commonParse("https://www.qidian.com/search?kw=$query&page=$page");
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final bookId = url;
    final res = await http.get('https://druid.if.qidian.com/argus/api/v1/chapterlist/chapterlist?bookId=$bookId');
    final json = jsonDecode(res.body);
    return (json["Data"]["Chapters"] as List).skip(1).map((chapter){
      final time = DateTime.fromMillisecondsSinceEpoch(chapter["T"]);
      return  ChapterItem(
        cover: null,
        name: '${chapter["V"] == 1 ? "🔒":""}${chapter["N"]}',
        time: '$time'.trim().substring(0, 16),
        url:'https://vipreader.qidian.com/chapter/$bookId/${chapter["C"]}',
      );
    }).toList();
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    return parse(res.body).querySelectorAll('.read-content p').map((p) => p.text).toList();
  }

}