import 'package:eso/api/api.dart';
import 'package:uuid/uuid.dart';
import 'package:floor/floor.dart';

@entity
class Rule {
  // 基本信息
  @primaryKey
  String id = Uuid().v4();
  int createTime = DateTime.now().microsecondsSinceEpoch;
  int modifiedTime = DateTime.now().microsecondsSinceEpoch;
  String author = '';
  String name = '';
  String host = '';
  int contentType = API.MANGA;

  // bool useCheerio = false;
  bool useCryptoJS = false;
  String loadJs = '';
  String userAgent = '';

  // 发现规则
  bool enableDiscover = false;
  String discoverUrl = '';
  String discoverItems = '';

  String discoverList = '';
  String discoverTags = '';
  String discoverName = '';
  String discoverCover = '';
  String discoverAuthor = '';
  String discoverChapter = '';
  String discoverDescription = '';
  String discoverResult = '';

  // 搜索规则
  bool enableSearch = true;
  String searchUrl = '';
  String searchItems = '';

  String searchList = '';
  String searchTags = '';
  String searchName = '';
  String searchCover = '';
  String searchAuthor = '';
  String searchChapter = '';
  String searchDescription = '';
  String searchResult = '';

  // 章节规则
  bool enableMultiRoads = false;
  String chapterRoads = '';
  String chapterRoadName = '';
  String chapterUrl = '';
  String chapterItems = '';

  String chapterName = '';
  String chapterCover = '';
  String chapterLock = '';
  String chapterTime = '';
  String chapterResult = '';

  // 正文规则
  String contentUrl = '';
  String contentItems = '';

  Rule.newRule() {
    id = Uuid().v4();
    createTime = DateTime.now().microsecondsSinceEpoch;
    modifiedTime = DateTime.now().microsecondsSinceEpoch;
    author = '';
    name = '';
    host = '';
    contentType = API.MANGA;
    // bool useCheerio = false;
    useCryptoJS = false;
    loadJs = '';
    userAgent = '';

    // 发现规则
    enableDiscover = false;
    discoverUrl = '';
    discoverItems = '';

    discoverList = '';
    discoverTags = '';
    discoverName = '';
    discoverCover = '';
    discoverAuthor = '';
    discoverChapter = '';
    discoverDescription = '';
    discoverResult = '';

    // 搜索规则
    enableSearch = true;
    searchUrl = '';
    searchItems = '';

    searchList = '';
    searchTags = '';
    searchName = '';
    searchCover = '';
    searchAuthor = '';
    searchChapter = '';
    searchDescription = '';
    searchResult = '';

    // 章节规则
    enableMultiRoads = false;
    chapterUrl = '';
    chapterRoads = '';
    chapterRoadName = '';
    chapterItems = '';

    chapterName = '';
    chapterCover = '';
    chapterLock = '';
    chapterTime = '';
    chapterResult = '';

    // 正文规则
    contentUrl = '';
    contentItems = '';
  }

  Rule(
    this.id,
    this.createTime,
    this.modifiedTime,
    this.author,
    this.name,
    this.host,
    this.contentType,
    this.useCryptoJS,
    this.loadJs,
    this.userAgent,
    this.enableDiscover,
    this.discoverUrl,
    this.discoverItems,
    this.discoverList,
    this.discoverTags,
    this.discoverName,
    this.discoverCover,
    this.discoverAuthor,
    this.discoverChapter,
    this.discoverDescription,
    this.discoverResult,
    this.enableSearch,
    this.searchUrl,
    this.searchItems,
    this.searchList,
    this.searchTags,
    this.searchName,
    this.searchCover,
    this.searchAuthor,
    this.searchChapter,
    this.searchDescription,
    this.searchResult,
    this.enableMultiRoads,
    this.chapterUrl,
    this.chapterRoads,
    this.chapterRoadName,
    this.chapterItems,
    this.chapterName,
    this.chapterCover,
    this.chapterLock,
    this.chapterTime,
    this.chapterResult,
    this.contentUrl,
    this.contentItems,
  );

  // Todo: 补全fromJson
  Rule.fromJson(Map<String, dynamic> json) {
    final defaultRule = Rule.newRule();
    id = json['id'] ?? defaultRule.id;
    createTime = json['createTime'] ?? defaultRule.createTime;
    modifiedTime = json['modifiedTime'] ?? defaultRule.modifiedTime;
    author = json['author'] ?? defaultRule.author;
    name = json['name'] ?? defaultRule.name;
    host = json['host'] ?? defaultRule.host;
    contentType = json['contentType'] ?? defaultRule.contentType;
    useCryptoJS = json['useCryptoJS'] ?? defaultRule.useCryptoJS;
    loadJs = json['loadJs'] ?? defaultRule.loadJs;
    userAgent = json['userAgent'] ?? defaultRule.userAgent;
    enableDiscover = json['enableDiscover'] ?? defaultRule.enableDiscover;
    discoverUrl = json['discoverUrl'] ?? defaultRule.discoverUrl;
    discoverItems = json['discoverItems'] ?? defaultRule.discoverItems;
    discoverList = json['discoverList'] ?? defaultRule.discoverList;
    discoverTags = json['discoverTags'] ?? defaultRule.discoverTags;
    discoverName = json['discoverName'] ?? defaultRule.discoverName;
    discoverCover = json['discoverCover'] ?? defaultRule.discoverCover;
    discoverAuthor = json['discoverAuthor'] ?? defaultRule.discoverAuthor;
    discoverChapter = json['discoverChapter'] ?? defaultRule.discoverChapter;
    discoverDescription =
        json['discoverDescription'] ?? defaultRule.discoverDescription;
    discoverResult = json['discoverResult'] ?? defaultRule.discoverResult;
    enableSearch = json['enableSearch'] ?? defaultRule.enableSearch;
    searchUrl = json['searchUrl'] ?? defaultRule.searchUrl;
    searchItems = json['searchItems'] ?? defaultRule.searchItems;
    searchList = json['searchList'] ?? defaultRule.searchList;
    searchTags = json['searchTags'] ?? defaultRule.searchTags;
    searchName = json['searchName'] ?? defaultRule.searchName;
    searchCover = json['searchCover'] ?? defaultRule.searchCover;
    searchAuthor = json['searchAuthor'] ?? defaultRule.searchAuthor;
    searchChapter = json['searchChapter'] ?? defaultRule.searchChapter;
    searchDescription =
        json['searchDescription'] ?? defaultRule.searchDescription;
    searchResult = json['searchResult'] ?? defaultRule.searchResult;
    enableMultiRoads = json['enableMultiRoads'] ?? defaultRule.enableMultiRoads;
    chapterRoads = json['chapterRoads'] ?? defaultRule.chapterRoads;
    chapterRoadName = json['chapterRoadName'] ?? defaultRule.chapterRoadName;
    chapterUrl = json['chapterUrl'] ?? defaultRule.chapterUrl;
    chapterItems = json['chapterItems'] ?? defaultRule.chapterItems;
    chapterName = json['chapterName'] ?? defaultRule.chapterName;
    chapterCover = json['chapterCover'] ?? defaultRule.chapterCover;
    chapterLock = json['chapterLock'] ?? defaultRule.chapterLock;
    chapterTime = json['chapterTime'] ?? defaultRule.chapterTime;
    chapterResult = json['chapterResult'] ?? defaultRule.chapterResult;
    contentUrl = json['contentUrl'] ?? defaultRule.contentUrl;
    contentItems = json['contentItems'] ?? defaultRule.contentItems;
  }

  // Todo: 补全toJson
  Map<String, dynamic> toJson() => {
        'id': id,
        'createTime': createTime,
        'modifiedTime': modifiedTime,
        'author': author,
        'name': name,
        'host': host,
        'contentType': contentType,
        'useCryptoJS': useCryptoJS,
        'loadJs': loadJs,
        'userAgent': userAgent,
        'enableDiscover': enableDiscover,
        'discoverUrl': discoverUrl,
        'discoverItems': discoverItems,
        'discoverList': discoverList,
        'discoverTags': discoverTags,
        'discoverName': discoverName,
        'discoverCover': discoverCover,
        'discoverAuthor': discoverAuthor,
        'discoverChapter': discoverChapter,
        'discoverDescription': discoverDescription,
        'discoverResult': discoverResult,
        'enableSearch': enableSearch,
        'searchUrl': searchUrl,
        'searchItems': searchItems,
        'searchList': searchList,
        'searchTags': searchTags,
        'searchName': searchName,
        'searchCover': searchCover,
        'searchAuthor': searchAuthor,
        'searchChapter': searchChapter,
        'searchDescription': searchDescription,
        'searchResult': searchResult,
        'enableMultiRoads': enableMultiRoads,
        'chapterRoads': chapterRoads,
        'chapterRoadName': chapterRoadName,
        'chapterUrl': chapterUrl,
        'chapterItems': chapterItems,
        'chapterName': chapterName,
        'chapterCover': chapterCover,
        'chapterLock': chapterLock,
        'chapterTime': chapterTime,
        'chapterResult': chapterResult,
        'contentUrl': contentUrl,
        'contentItems': contentItems,
      };
}
