import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/search_item.dart';
import 'package:eso/global.dart';
import 'package:http/http.dart' as http;

class Manhuatai implements API {
  @override
  String get origin => '漫画台';

  @override
  String get originTag => 'Manhuatai';

  @override
  RuleContentType get ruleContentType => RuleContentType.MANGA;

  @override
  Future<List<SearchItem>> discover(
      String query, int page, int pageSize) async {
    final res = await http.get(
        'http://getcomicinfo-globalapi.yyhao.com/app_api/v5/getsortlist/?page=$page');
    final json = jsonDecode(res.body);
    return (json["data"] as List).map((item) {
      final id = item["comic_id"];

      return SearchItem(
          api: this,
          cover: 'http://image.mhxk.com/mh/$id.jpg',
          name: item["comic_name"],
          author: '',
          chapter: '',
          description:'${item["comic_type"]}'.replaceAll(RegExp('^\\w+,|\\|\\w+,'), ' '),
          url:
              'http://getcomicinfo-globalapi.yyhao.com/app_api/v5/getcomicinfo_body/?comic_id=$id');
    }).toList();
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    final res = await http.get(
        'http://getcomicinfo-globalapi.yyhao.com/app_api/v5/getsortlist/?search_key=$query&page=$page');
    final json = jsonDecode(res.body);
    return (json["data"] as List).map((item) {
      final id = item["comic_id"];
      return SearchItem(
          api: this,
          cover: 'http://image.mhxk.com/mh/$id.jpg',
          name: item["comic_name"],
          author: '',
          chapter: '',
          description: '${item["comic_type"]}'.replaceAll(RegExp('^\\w+,|\\|\\w+,'), ' '),
          url:
              'http://getcomicinfo-globalapi.yyhao.com/app_api/v5/getcomicinfo_body/?comic_id=$id');
    }).toList();
  }

  @override
  Future<List<ChapterItem>> chapter(String url) async {
    final res = await http.get('$url');
    final json = jsonDecode(res.body);
    final chapters = json["comic_chapter"] as List;
    final list = List<ChapterItem>(chapters.length);
    for (int i = 0; i < chapters.length; i++) {
      final chapter = chapters[chapters.length - i - 1];
      final time =
          DateTime.fromMillisecondsSinceEpoch(chapter["create_date"] * 1000);
      final chapterImage = chapter["chapter_image"];
      final rule =
          '${chapterImage["high"] ?? chapterImage["middle"] ?? chapterImage["low"]}'
              .split('\$\$');
      final domain = 'https://mhpic.${chapter["chapter_domain"]}';
      final startNum = '${chapter["start_num"]}';
      list[i] = ChapterItem(
        cover: '$domain${rule[0]}$startNum${rule[1]}',
        name:
            '${chapter["isbuy"] == 1 ? '💰' : ''}${chapter["islock"] == 1 ? '🔒' : ''}${chapter["chapter_name"]}',
        time: '$time'.trim().substring(0, 16),
        url: '$domain${rule[0]}?$startNum&${chapter["end_num"]}&${rule[1]}',
      );
    }
    return list;
  }

  @override
  Future<List<String>> content(String url) async {
    final urls = url.split('?');
    final query = urls[1].split('&');
    final startNum = int.parse(query[0]);
    final len = int.parse(query[1]) - startNum + 1;
    List<String> images = List<String>(len);
    for (int i = 0; i < len; i++) {
      images[i] = '${urls[0]}${i + 1}${query[2]}';
    }
    return images;
  }

}
