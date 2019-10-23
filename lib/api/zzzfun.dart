import '../database/chapter_item.dart';
import '../database/search_item.dart';
import '../global.dart';
import 'api.dart';

class ZZZFun implements API {
  @override
  Future<List<ChapterItem>> chapter(String url) {
    // TODO: implement chapter
    return null;
  }

  @override
  Future<List<String>> content(String url) {
    // TODO: implement content
    return null;
  }

  @override
  // TODO: implement origin
  String get origin => null;

  @override
  // TODO: implement originTag
  String get originTag => null;

  @override
  // TODO: implement ruleContentType
  RuleContentType get ruleContentType => null;

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) {
    // TODO: implement search
    return null;
  }

  @override
  Future<List<String>> mangaContent(String url) {
    // TODO: implement mangaContent
    return null;
  }

  @override
  Future<List<String>> novelContent(String url) {
    // TODO: implement novelContent
    return null;
  }

  @override
  Future<String> videoContent(String url) {
    // TODO: implement videoContent
    return null;
  }

}