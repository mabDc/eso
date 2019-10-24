import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'api.dart';

class Mankezhan implements API {
  @override
  String get origin => "漫客栈";

  @override
  String get originTag => "Mankezhan";

  @override
  RuleContentType get ruleContentType => RuleContentType.MANGA;

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http.get("https://comic.mkzhan.com/search/keyword/?keyword=$query&page_num=$page&page_size=$pageSize");
    final json = jsonDecode(res.body);
    return (json["data"]["list"] as List).map((item) => SearchItem(
      api: this,
      cover: item["cover"] == null ? null : '${item["cover"]}!cover-400',
      name: '${item["title"]}',
      author: '${item["author_title"]}',
      chapter: '${item["chapter_title"]}',
      description: '${item["feature"]}',
      url:'${item["comic_id"]}',
    )).toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final comicId = url;
    final res = await http.get('https://comic.mkzhan.com/chapter/?comic_id=$comicId');
    final json = jsonDecode(res.body);
    final List list = json["data"];
    final chapters = new List<ChapterItem>(list.length);
    for(int i = 0; i <list.length; i++){
      final chapter = list[i];
      final time = DateTime.fromMillisecondsSinceEpoch(int.parse(chapter["start_time"]) * 1000);
      chapters[i] =  ChapterItem(
        cover: chapter["cover"] == null ? null : '${chapter["cover"]}!cover-400',
        name: '${chapter["title"]}',
        time: '$time'.trim().substring(0, 16),
        url:'https://comic.mkzhan.com/chapter/content/?chapter_id=${chapter["chapter_id"]}&comic_id=$comicId',
        chapterNum: i+1,
      );
    }
    return chapters;
  }

  @override
  Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(res.body);
    return (json["data"] as List).map((d) => '${d["image"]}!page-1200').toList();
  }
}