import 'package:eso/api/api.dart';
import 'package:eso/database/chapter_item.dart';
import 'package:eso/model/chapter_page_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SearchItem extends HiveObject{
  String searchUrl;
  String chapterUrl;

  bool operator ==(Object other) =>
      other is SearchItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id;

  int id;

  /// 源名
  String origin;

  /// 源id
  String originTag;

  /// 封面
  String cover;

  /// 名称
  String name;

  /// 作者
  String author;

  /// 最新章节
  String chapter;

  /// 简介
  String description;

  /// 分类
  List<String> tags;

  /// 搜索结果
  String url;
  // Future<String> get absoloteUrl async => (await Global.ruleDao.findRuleById(originTag));
  int ruleContentType;
  int chapterListStyle;
  String durChapter;
  int durChapterIndex;
  int durContentIndex;
  int chaptersCount;
  bool reverseChapter;
  List<ChapterItem> chapters;

  /// 收藏时间
  int createTime;

  /// 更新时间
  int updateTime;

  /// 最后阅读时间
  int lastReadTime;

  SearchItem({
    this.searchUrl,
    this.chapterUrl,
    @required this.cover,
    @required this.name,
    @required this.author,
    @required this.chapter,
    @required this.description,
    @required this.url,
    @required API api,
    this.chaptersCount,
    this.reverseChapter,
    this.chapters,
    @required this.tags,
  }) {
    if (chaptersCount == null) {
      chaptersCount = 0;
    }
    if (reverseChapter == null) {
      reverseChapter = false;
    }
    if (api != null) {
      origin = api.origin;
      originTag = api.originTag;
      ruleContentType = api.ruleContentType;
    }
    id = DateTime.now().microsecondsSinceEpoch;
    chapterListStyle = ChapterPageProvider.BigList;
    durChapter = "";
    durChapterIndex = 0;
    durContentIndex = 1;
    chapters = null;
    createTime ??= DateTime.now().microsecondsSinceEpoch;
    updateTime ??= DateTime.now().microsecondsSinceEpoch;
    lastReadTime ??= DateTime.now().microsecondsSinceEpoch;
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
        "searchUrl": searchUrl,
        "chapterUrl": chapterUrl,
        "id": id,
        "origin": origin,
        "originTag": originTag,
        "cover": cover,
        "name": name,
        "author": author,
        "chapter": chapter,
        "description": description,
        "url": url,
        "ruleContentType": ruleContentType,
        "chapterListStyle": chapterListStyle,
        "durChapter": durChapter,
        "durChapterIndex": durChapterIndex,
        "durContentIndex": durContentIndex,
        "chaptersCount": chaptersCount,
        "reverseChapter": reverseChapter,
        "tags": tags != null ? tags.join(", ") : null,
        "createTime": createTime,
        "updateTime": updateTime,
        "lastReadTime": lastReadTime,
      };

  SearchItem.fromAdapter(
    this.searchUrl,
    this.chapterUrl,
    this.id,
    this.origin,
    this.originTag,
    this.cover,
    this.name,
    this.author,
    this.chapter,
    this.description,
    this.url,
    this.ruleContentType,
    this.chapterListStyle,
    this.durChapter,
    this.durChapterIndex,
    this.durContentIndex,
    this.chaptersCount,
    this.reverseChapter,
    this.tags,
    //增加时间
    this.createTime,
    this.updateTime,
    this.lastReadTime,
    this.chapters,
  );

  SearchItem.fromJson(Map<String, dynamic> json) {
    searchUrl = json["searchUrl"];
    chapterUrl = json["chapterUrl"];
    id = json["id"];
    origin = json["origin"];
    originTag = json["originTag"];
    cover = json["cover"];
    name = json["name"];
    author = json["author"];
    chapter = json["chapter"];
    description = json["description"];
    url = json["url"];
    ruleContentType = json["ruleContentType"];
    chapterListStyle = json["chapterListStyle"];
    durChapter = json["durChapter"];
    durChapterIndex = json["durChapterIndex"];
    durContentIndex = json["durContentIndex"];
    chaptersCount = json["chaptersCount"];
    reverseChapter = json["reverseChapter"] ?? false;
    //增加时间
    createTime = json['createTime'] ?? DateTime.now().microsecondsSinceEpoch;
    updateTime = json['updateTime'] ?? DateTime.now().microsecondsSinceEpoch;
    lastReadTime = json['lastReadTime'] ?? DateTime.now().microsecondsSinceEpoch;

    tags = json["tags"]?.split(", ") ?? <String>[];
    chapters = <ChapterItem>[];
  }

  changeTo(SearchItem searchItem) {
    searchUrl = searchItem.searchUrl;
    chapterUrl = searchItem.chapterUrl;
    origin = searchItem.origin;
    originTag = searchItem.originTag;
    cover = searchItem.cover;
    name = searchItem.name;
    author = searchItem.author;
    chapter = searchItem.chapter;
    description = searchItem.description;
    url = searchItem.url;
    tags = searchItem.tags;
    chapters = <ChapterItem>[];
    durChapter = "";
    durChapterIndex = 0;
    durContentIndex = 1;
  }

  localAddInfo(SearchItem searchItem) {
    if (searchItem.author.isNotEmpty) author = searchItem.author;
    if (searchItem.cover.isNotEmpty) cover = searchItem.cover;
    if (searchItem.tags.isNotEmpty) tags = searchItem.tags;
    if (searchItem.description.isNotEmpty) description = searchItem.description;
  }
}
