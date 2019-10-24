import 'package:eso/api/api.dart';

import '../global.dart';
import '../model/chapter_page_controller.dart';

class SearchItem {
  String itemId;
  String chapterId;
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

  SearchItem({
    this.itemId,
    this.chapterId,
    this.cover,
    this.name,
    this.author,
    this.chapter,
    this.description,
    this.url,
    this.chapterListStyle,
    this.durChapter,
    this.durChapterIndex,
    this.durContentIndex,
    API api,
  }){
    if(api!=null){
        origin = api.origin;
        originTag = api.originTag;
        ruleContentType = api.ruleContentType;
    }
  }

  Map<String, dynamic> toJson() => {
    "itemId":itemId,
    "chapterId":chapterId,
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
  };

  SearchItem.fromJson(Map<String, dynamic> json){
    itemId=json["itemId"];
    chapterId=json["chapterId"];
    origin=json["origin"];
    originTag=json["originTag"];
    cover=json["cover"];
    name=json["name"];
    author=json["author"];
    chapter=json["chapter"];
    description=json["description"];
    url=json["url"];
    ruleContentType= RuleContentType.values[json["ruleContentType"]];
    chapterListStyle= ChapterListStyle.values[json["chapterListStyle"]];
    durChapter=json["durChapter"];
    durChapterIndex=json["durChapterIndex"];
    durContentIndex=json["durContentIndex"];
  }
}
