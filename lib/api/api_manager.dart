import 'package:eso/api/iqiwx.dart';
import 'package:flutter/foundation.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';
import 'api.dart';
import 'mankezhan.dart';
import 'qidian.dart';

class APIManager{
  static API chooseAPI(String originTag){
    for(API api in allAPI){
      if(api.originTag == originTag){
        return api;
      }
    }
    throw('can not get api when chooseAPI');
  }

  static List<API> get allAPI => <API>[
    Qidian(),
    Iqiwx(),
    Mankezhan(),
  ];

  static Future<List<SearchItem>> dicover(String originTag, String query,[int page = 1, int pageSize = 20]){
    return chooseAPI(originTag).discover(query, page, pageSize);
  }

  static Future<List<SearchItem>> search(String originTag, String query,[int page = 1, int pageSize = 20]){
    return chooseAPI(originTag).search(query, page, pageSize);
  }

  static Future<List<ChapterItem>> getChapter(String originTag,String url){
    return chooseAPI(originTag).chapter(url);
  }

  static Future<List<String>> getContent(String originTag,String url){
    return chooseAPI(originTag).content(url);
  }

}