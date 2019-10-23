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

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http.get("https://www.qidian.com/search?kw=$query&page=$page");
    final dom = parse(res.body);
    return dom.querySelectorAll('#result-list .res-book-item').map((item) => SearchItem(
      origin: origin,
      originTag: originTag,
      ruleContentType: ruleContentType,
      cover: 'https:${item.querySelector('.book-img-box img').attributes["src"]}',
      name: '${item.querySelector('h4 a').text}',
      author: '${item.querySelector('.author a').text}',
      chapter: '${item.querySelector('.update').text}',
      description: '${item.querySelector('.intro').text}',
      url: '${item.querySelector('h4 a').attributes["data-bid"]}',
    )).toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final bookId = url;
    final res = await http.get('https://druid.if.qidian.com/argus/api/v1/chapterlist/chapterlist?bookId=$bookId');
    final json = jsonDecode(res.body);
    final List list = json["Data"]["Chapters"];
    final chapters = new List<ChapterItem>(list.length - 1);
    for(int i = 0; i < list.length - 1; i++){
      final chapter = list[i+1];
      final time = DateTime.fromMillisecondsSinceEpoch(chapter["T"]);
      chapters[i] =  ChapterItem(
        cover: null,
        name: '${chapter["V"] == 1 ? "🔒":""}${chapter["N"]}',
        time: '$time'.trim().substring(0, 16),
        url:'https://vipreader.qidian.com/chapter/$bookId/${chapter["C"]}',
        chapterNum: i+1,
      );
    }
    return chapters;
  }

  @override
  Future<List<String>> novelContent(String url) async {
    final res = await http.get(url);
    return parse(res.body).querySelectorAll('.read-content p').map((p) => p.text).toList();
  }

  @override
  Future<List<String>> mangaContent(String url) {
    throw("Qidian is not manga");
  }

  @override
  Future<String> videoContent(String url) {
    throw("Qidian is not video");
  }
}