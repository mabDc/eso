import 'dart:convert';

import 'package:eso/database/chapter_item.dart';

import '../database/search_item.dart';
import 'package:http/http.dart' as http;

class Mankezhan{
  static Future<List<SearchItem>> search(String query,[int page = 1, int pageSize = 20]) async {
    final res = await http.get("https://comic.mkzhan.com/search/keyword/?keyword=$query&page_num=$page&page_size=$pageSize");
    final json = jsonDecode(res.body);
    return (json["data"]["list"] as List).map((item) => SearchItem(
      cover: item["cover"] == null ? null : '${item["cover"]}!cover-400',
      title: '${item["title"]}',
      origin: "漫客栈💰",
      author: '${item["author_title"]}',
      chapter: '${item["chapter_title"]}',
      description: '${item["feature"]}',
      url:'${item["comic_id"]}',
    )).toList();
  }

  static Future<List<ChapterItem>> chapter(String url) async {
    final comicId = url;
    final res = await http.get('https://comic.mkzhan.com/chapter/?comic_id=$comicId');
    final json = jsonDecode(res.body);
    return (json["data"] as List).map((chapter){
      final time = DateTime.fromMillisecondsSinceEpoch(int.parse(chapter["start_time"]) * 1000);
      return ChapterItem(
          cover: chapter["cover"] == null ? null : '${chapter["cover"]}!cover-400',
          title: '${chapter["title"]}',
          time: '$time'.trim().substring(0, 16),
          url:'https://comic.mkzhan.com/chapter/content/?chapter_id=${chapter["chapter_id"]}&comic_id=$comicId'
      );
    }).toList();
  }

  static Future<List<String>> content(String url) async {
    final res = await http.get(url);
    final json = jsonDecode(res.body);
    return (json["data"] as List).map((d) => '${d["image"]}!page-1200').toList();
  }
}