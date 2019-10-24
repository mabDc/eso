import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:flutter/cupertino.dart';

import '../global.dart';
import '../model/chapter_page_controller.dart';

class SearchItem {
  int id;
  String origin;
  String originTag;
  String cover;
  String name;
  String author;
  String chapter;
  String description;
  String url;
  RuleContentType ruleContentType;
  ChapterListStyle chapterListStyle;
  String durChapter;
  int durChapterIndex;
  int durContentIndex;
  int chaptersCount;
  List<ChapterItem> chapters;

  SearchItem({
    @required
    this.cover,
    @required
    this.name,
    @required
    this.author,
    @required
    this.chapter,
    @required
    this.description,
    @required
    this.url,
    @required
    API api,
    this.chaptersCount,
  }){
    if(chaptersCount == null){
      chaptersCount = 0;
    }
    if(api!=null){
      origin = api.origin;
      originTag = api.originTag;
      ruleContentType = api.ruleContentType;
    }
    id = DateTime.now().millisecondsSinceEpoch;
    chapterListStyle = ChapterListStyle.values.first;
    durChapter = "";
    durChapterIndex = 0;
    durContentIndex = 1;
    chapters = null;
  }

//  void copyFrom(SearchItem other){
//    if(isLocal != other.isLocal){
//      isLocal = other.isLocal;
//    }
//    if(chapterListStyle != other.chapterListStyle){
//      chapterListStyle = other.chapterListStyle;
//    }
//    if(durChapter != other.durChapter){
//      durChapter = other.durChapter;
//    }
//    if(durChapterIndex != other.durChapterIndex){
//      durChapterIndex = other.durChapterIndex;
//    }
//    if(durContentIndex != other.durContentIndex){
//      durContentIndex = other.durContentIndex;
//    }
//  }

  Map<String, dynamic> toJson() => {
    "id":id,
    "origin":origin,
    "originTag":originTag,
    "cover":cover,
    "name":name,
    "author":author,
    "chapter":chapter,
    "description":description,
    "url":url,
    "ruleContentType":ruleContentType.index,
    "chapterListStyle":chapterListStyle.index,
    "durChapter":durChapter,
    "durChapterIndex":durChapterIndex,
    "durContentIndex":durContentIndex,
    "chaptersCount":chaptersCount,
  };

  SearchItem.fromJson(Map<String, dynamic> json){
    id=json["id"];
    origin=json["origin"];
    originTag=json["originTag"];
    cover=json["cover"];
    name=json["name"];
    author=json["author"];
    chapter=json["chapter"];
    description=json["description"];
    url=json["url"];
    ruleContentType= RuleContentType.values[json["ruleContentType"]??0];
    chapterListStyle= ChapterListStyle.values[json["chapterListStyle"]??0];
    durChapter=json["durChapter"];
    durChapterIndex=json["durChapterIndex"];
    durContentIndex=json["durContentIndex"];
    chaptersCount=json["chaptersCount"];
    chapters = <ChapterItem>[];
  }
}
