import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';

abstract class API {
  String get origin;
  String get originTag;
  RuleContentType get ruleContentType;

  Future<List<SearchItem>> search(String query,int page, int pageSize);

  Future<List<ChapterItem>> chapter(String url);

  Future<List<String>> content(String url);

}