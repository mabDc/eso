import 'package:eso/api/api.dart';
import 'package:uuid/uuid.dart';

class Rule {
  String id = Uuid().v4();
  int createTime = DateTime.now().microsecondsSinceEpoch;
  int modifiedTime = DateTime.now().microsecondsSinceEpoch;
  bool enable = true;
  String name = '';
  String host = '';
  ContentType contentType = ContentType.MANGA;
  bool useCheerio = false;
  bool useCryptoJS = false;
  bool useMultiRoads = false;

  // 发现规则
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

  String searchUrl = '';
  String searchItems = '';

  // 搜索规则
  String searchList = '';
  String searchTags = '';
  String searchName = '';
  String searchCover = '';
  String searchAuthor = '';
  String searchChapter = '';
  String searchDescription = '';
  String searchResult = '';

  String detailUrl = '';
  String detailItems = '';
  String chapterUrl = '';
  String chapterItems = '';
  String contentUrl = '';
  String contentItems = '';

  String road; //List<dynamic>
  String roadName;
  String roadElement; // chapterList
  String chapterName;
  String chapterResult;

  Rule(
    this.id,
    this.enable,
    this.name,
    this.host,
    this.contentType,
    this.useCheerio,
    this.useCryptoJS,
    this.useMultiRoads,
    this.discoverUrl,
    this.discoverItems,
    this.searchUrl,
    this.searchItems,
    this.detailUrl,
    this.detailItems,
    this.chapterUrl,
    this.chapterItems,
    this.contentUrl,
    this.contentItems,
  );

  Rule.newRule() {
    id = Uuid().v4();
    createTime = DateTime.now().microsecondsSinceEpoch;
    modifiedTime = DateTime.now().microsecondsSinceEpoch;
    enable = true;
    name = '';
    host = '';
    contentType = ContentType.MANGA;
    useCheerio = false;
    useCryptoJS = false;
    useMultiRoads = false;

    // 发现规则
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

    searchUrl = '';
    searchItems = '';

    // 搜索规则
    searchList = '';
    searchTags = '';
    searchName = '';
    searchCover = '';
    searchAuthor = '';
    searchChapter = '';
    searchDescription = '';
    searchResult = '';

    detailUrl = '';
    detailItems = '';
    chapterUrl = '';
    chapterItems = '';
    contentUrl = '';
    contentItems = '';

    road = ''; //List<dynamic>
    roadName = '';
    roadElement = ''; // chapterList
    chapterName = '';
    chapterResult = '';
  }

  Rule.fromJson(Map<dynamic, dynamic> json) {
    final defaultRule = Rule.newRule();
    id = json['id'] ?? defaultRule.id;
    enable = json['enable'] ?? defaultRule.enable;
    name = json['name'] ?? defaultRule.name;
    host = json['host'] ?? defaultRule.host;
    contentType = json['contentType'] ?? defaultRule.contentType;
    useCheerio = json['useCheerio'] ?? defaultRule.useCheerio;
    useCryptoJS = json['useCryptoJS'] ?? defaultRule.useCryptoJS;
    useMultiRoads = json['useMultiRoads'] ?? defaultRule.useMultiRoads;
    discoverUrl = json['discoverUrl'] ?? defaultRule.discoverUrl;
    discoverItems = json['discoverItems'] ?? defaultRule.discoverItems;
    searchUrl = json['searchUrl'] ?? defaultRule.searchUrl;
    searchItems = json['searchItems'] ?? defaultRule.searchItems;
    detailUrl = json['detailUrl'] ?? defaultRule.detailUrl;
    detailItems = json['detailItems'] ?? defaultRule.detailItems;
    chapterUrl = json['chapterUrl'] ?? defaultRule.chapterUrl;
    chapterItems = json['chapterItems'] ?? defaultRule.chapterItems;
    contentUrl = json['contentUrl'] ?? defaultRule.contentUrl;
    contentItems = json['contentItems'] ?? defaultRule.contentItems;
  }

  Map<dynamic, dynamic> toJson() => {
        'id': id,
        'enable': enable,
        'name': name,
        'host': host,
        'contentType': contentType,
        'useCheerio': useCheerio,
        'useCryptoJS': useCryptoJS,
        'useMultiRoads': useMultiRoads,
        'discoverUrl': discoverUrl,
        'discoverItems': discoverItems,
        'searchUrl': searchUrl,
        'searchItems': searchItems,
        'detailUrl': detailUrl,
        'detailItems': detailItems,
        'chapterUrl': chapterUrl,
        'chapterItems': chapterItems,
        'contentUrl': contentUrl,
        'contentItems': contentItems,
      };
}
