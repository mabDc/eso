import 'dart:convert';

import 'package:http/http.dart' as http;

class Mankezhan{
  static Future<List> search(String query,[int page = 1, int pageSize = 20]) async {
    final res = await http.get("https://comic.mkzhan.com/search/keyword/?keyword=$query&page_num=$page&page_size=$pageSize");
    final json = jsonDecode(res.body);
    return json["data"]["list"];
  }

  static Future<List> chapter(String comicId) async {
    final res = await http.get("https://comic.mkzhan.com/chapter/?comic_id=$comicId");
    final json = jsonDecode(res.body);
    return json["data"];
  }

  static Future<List> content(String comicId, String chapterId) async {
    final res = await http.get("https://comic.mkzhan.com/chapter/content/?chapter_id=$chapterId&comic_id=$comicId");
    final json = jsonDecode(res.body);
    return json["data"];
  }
}