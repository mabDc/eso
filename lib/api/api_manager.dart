import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';
import 'mankezhan.dart';
import 'qidian.dart';

class APIManager{
  static Future<List<SearchItem>> searchManga(String query,[int page = 1, int pageSize = 20]){
    return Mankezhan().search(query, page, pageSize);
  }

  static Future<List<SearchItem>> searchNovel(String query,[int page = 1, int pageSize = 20]){
    return Qidian().search(query, page, pageSize);
  }

  static API chooseAPI(String originTag){
    switch(originTag){
      case "Mankezhan":
        return Mankezhan();
      case "Qidian":
        return Qidian();
      default:
        return Mankezhan();
    }
  }

  static Future<List<ChapterItem>> getChapter(String originTag,String url){
    return chooseAPI(originTag).chapter(url);
  }

  static Future<List<String>> getMangaContent(String originTag,String url){
    return chooseAPI(originTag).mangaContent(url);
  }

  static Future<List<String>> getNovelContent(String originTag, String url){
    return chooseAPI(originTag).novelContent(url);
  }
}