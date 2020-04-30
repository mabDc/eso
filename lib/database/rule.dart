import 'package:eso/api/api.dart';
import 'package:uuid/uuid.dart';

class Rule {
  // 基本信息
  String id = Uuid().v4();
  int createTime = DateTime.now().microsecondsSinceEpoch;
  int modifiedTime = DateTime.now().microsecondsSinceEpoch;
  String name = '';
  String host = '';
  ContentType contentType = ContentType.MANGA;
  // bool useCheerio = false;
  bool useCryptoJS = false;
  bool useMultiRoads = false;
  String loadJs = '';
  String userAgent = '';

  // 发现规则
  bool enableDiscover = true;
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
    name = '';
    host = '';
    contentType = ContentType.MANGA;
    // bool useCheerio = false;
    useCryptoJS = false;
    useMultiRoads = false;
    loadJs = '';
    userAgent = '';

    // 发现规则
    enableDiscover = true;
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
    chapterRoads = '';
    chapterRoadName = '';
    chapterUrl = '';
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

  // Todo: 自动生成Rule构造方法
  Rule(
      //,
      );

  // Todo: 补全fromJson
  Rule.fromJson(Map<dynamic, dynamic> json) {
    final defaultRule = Rule.newRule();
    id = json['id'] ?? defaultRule.id;
  }
  // Todo: 补全toJson
  Map<dynamic, dynamic> toJson() => {
        'id': id,
      };
}
