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
  String postScript = '';
  String name = '';
  String host = '';
  int contentType = API.MANGA;
  int sort = 0;

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

  String chapterList = '';
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
    postScript = '';
    contentType = API.MANGA;
    sort = 0;
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

    chapterList = '';
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
    this.postScript,
    this.contentType,
    this.sort,
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
    this.chapterList,
    this.chapterName,
    this.chapterCover,
    this.chapterLock,
    this.chapterTime,
    this.chapterResult,
    this.contentUrl,
    this.contentItems,
  );

  Rule.fromJson(Map<String, dynamic> json, [Rule rule]) {
    final defaultRule = rule ?? Rule.newRule();
    id = json['id'] ?? defaultRule.id;
    createTime = json['createTime'] ?? defaultRule.createTime;
    modifiedTime = json['modifiedTime'] ?? defaultRule.modifiedTime;
    author = json['author'] ?? defaultRule.author;
    postScript = json['postScript'] ?? defaultRule.postScript;
    name = json['name'] ?? defaultRule.name;
    host = json['host'] ?? defaultRule.host;
    contentType = json['contentType'] ?? defaultRule.contentType;
    sort = json['sort'] ?? defaultRule.sort;
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
    chapterList = json['chapterList'] ?? defaultRule.chapterList;
    chapterName = json['chapterName'] ?? defaultRule.chapterName;
    chapterCover = json['chapterCover'] ?? defaultRule.chapterCover;
    chapterLock = json['chapterLock'] ?? defaultRule.chapterLock;
    chapterTime = json['chapterTime'] ?? defaultRule.chapterTime;
    chapterResult = json['chapterResult'] ?? defaultRule.chapterResult;
    contentUrl = json['contentUrl'] ?? defaultRule.contentUrl;
    contentItems = json['contentItems'] ?? defaultRule.contentItems;
  }

  Rule.fromYiCiYuan(Map<String, dynamic> json, [Rule rule]) {
    final defaultRule = rule ?? Rule.newRule();
    var flag = false;
    for (final key in json.keys) {
      var s = '${json[key]}';
      if (s.contains('@css:')) continue;
      if (s.startsWith("-")) {
        flag = true;
        s = s.substring(1);
      }
      if (s.contains(RegExp(r"img|text|href|tag\.|class\.|id\."))) {
        s = s
            .replaceAll("#", "##")
            .replaceAll("@tag.", " ")
            .replaceAll("@class.", " .")
            .replaceAll("@id.", " #")
            .replaceAll("@children", ">*")
            .replaceAll("tag.", "")
            .replaceAll("class.", ".")
            .replaceAll("id.", "#")
            .replaceAllMapped(RegExp(r"\.(\d+)"),
                (Match m) => ":nth-of-type(${int.parse(m[1]) + 1})");
        json[key] = (flag ? "-" : "") + "@css:" + s.trim();
      }
    }

    id = json['id'] ?? defaultRule.id;
    createTime = json['createTime'] ?? defaultRule.createTime;
    modifiedTime = json['modifiedTime'] ?? defaultRule.modifiedTime;
    author = json['author'] ?? defaultRule.author;
    postScript = (json['bookSourceGroup'] ?? '' + json['sourceRemark'] ?? '');
    name = json['bookSourceName'] ?? defaultRule.name;
    host = json['bookSourceUrl'] ?? defaultRule.host;
    contentType = json['contentType'] ?? defaultRule.contentType;
    sort = json['weight'] ?? defaultRule.sort;
    useCryptoJS = json['useCryptoJS'] ?? defaultRule.useCryptoJS;
    loadJs = json['loadJs'] ?? defaultRule.loadJs;
    userAgent = json['httpUserAgent'] ?? defaultRule.userAgent;
    enableDiscover = json['enableDiscover'] ?? defaultRule.enableDiscover;
    discoverUrl = json['discoverUrl'] ?? defaultRule.discoverUrl;
    discoverItems = json['discoverItems'] ?? defaultRule.discoverItems;
    discoverList = json['ruleSearchList'] ?? defaultRule.discoverList;
    discoverTags = json['ruleSearchKind'] ?? defaultRule.discoverTags;
    discoverName = json['ruleSearchName'] ?? defaultRule.discoverName;
    discoverCover = json['ruleSearchCoverUrl'] ?? defaultRule.discoverCover;
    discoverAuthor = json['ruleSearchAuthor'] ?? defaultRule.discoverAuthor;
    discoverChapter =
        json['ruleSearchLastChapter'] ?? defaultRule.discoverChapter;
    discoverDescription =
        json['discoverDescription'] ?? defaultRule.discoverDescription;
    discoverResult = json['ruleSearchNoteUrl'] ?? defaultRule.discoverResult;
    enableSearch = json['enableSearch'] ?? defaultRule.enableSearch;
    searchUrl = json['ruleSearchUrl'] ?? defaultRule.searchUrl;
    searchItems = json['searchItems'] ?? defaultRule.searchItems;
    searchList = json['ruleSearchList'] ?? defaultRule.searchList;
    searchTags = json['ruleSearchKind'] ?? defaultRule.searchTags;
    searchName = json['ruleSearchName'] ?? defaultRule.searchName;
    searchCover = json['ruleSearchCoverUrl'] ?? defaultRule.searchCover;
    searchAuthor = json['ruleSearchAuthor'] ?? defaultRule.searchAuthor;
    searchChapter = json['ruleSearchLastChapter'] ?? defaultRule.searchChapter;
    searchDescription =
        json['searchDescription'] ?? defaultRule.searchDescription;
    searchResult = json['ruleSearchNoteUrl'] ?? defaultRule.searchResult;
    enableMultiRoads = json['enableMultiRoads'] ?? defaultRule.enableMultiRoads;
    chapterRoads = json['chapterRoads'] ?? defaultRule.chapterRoads;
    chapterRoadName = json['chapterRoadName'] ?? defaultRule.chapterRoadName;
    chapterUrl = json['ruleChapterUrl'] ?? defaultRule.chapterUrl;
    chapterItems = json['chapterItems'] ?? defaultRule.chapterItems;
    chapterList = json['ruleChapterList'] ?? defaultRule.chapterList;
    chapterName = json['ruleChapterName'] ?? defaultRule.chapterName;
    chapterCover = json['chapterCover'] ?? defaultRule.chapterCover;
    chapterLock = json['chapterLock'] ?? defaultRule.chapterLock;
    chapterTime = json['chapterTime'] ?? defaultRule.chapterTime;
    chapterResult = json['ruleContentUrl'] ?? defaultRule.chapterResult;
    contentUrl = json['contentUrl'] ?? defaultRule.contentUrl;
    contentItems = json['ruleBookContent'] ?? defaultRule.contentItems;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createTime': createTime,
        'modifiedTime': modifiedTime,
        'author': author,
        'postScript': postScript,
        'name': name,
        'host': host,
        'contentType': contentType,
        'sort': sort,
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
        'chapterList': chapterList,
        'chapterName': chapterName,
        'chapterCover': chapterCover,
        'chapterLock': chapterLock,
        'chapterTime': chapterTime,
        'chapterResult': chapterResult,
        'contentUrl': contentUrl,
        'contentItems': contentItems,
      };
}
