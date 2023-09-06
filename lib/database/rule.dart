import 'dart:convert';

import 'package:eso/api/api.dart';
import 'package:eso/database/rule_dao.dart';
import 'package:text_composition/text_composition.dart';
import 'package:uuid/uuid.dart';
import 'package:floor/floor.dart';

import '../global.dart';
import '../utils/rule_comparess.dart';

@entity
class Rule {
  // 基本信息
  @primaryKey
  String id = Uuid().v4();
  int createTime = DateTime.now().microsecondsSinceEpoch; //创建时间
  int modifiedTime = DateTime.now().microsecondsSinceEpoch; //修改时间
  bool enableUpload;
  String author = ''; //源作者
  String postScript = '';
  String name = ''; //站点名
  String host = ''; //主机
  String icon = ''; //icon
  int contentType = API.MANGA; //站点类型
  String group = ''; //分组名
  int sort = 0; //排序值
  // 显示样式
  int viewStyle = 0;

  // bool useCheerio = false;
  bool useCryptoJS = false;
  String loadJs = '';
  String userAgent = '';

  //登录规则
  String loginUrl = "";
  String cookies = "";

  // 发现规则
  bool enableDiscover = true;
  String discoverUrl = '';
  String discoverNextUrl = '';
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
  String searchNextUrl = '';
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
  String chapterUrl = '';
  String chapterNextUrl = '';
  String chapterRoads = '';
  String chapterRoadName = '';
  String chapterItems = '';

  String chapterList = '';
  String chapterName = '';
  String chapterCover = '';
  String chapterLock = '';
  String chapterTime = '';
  String chapterResult = '';

  // 正文规则
  String contentUrl = '';
  String contentNextUrl = '';
  String contentItems = '';

  get ruleTypeName => API.getRuleContentTypeName(contentType);

  Rule.newRule() {
    id = Uuid().v4();
    createTime = DateTime.now().microsecondsSinceEpoch;
    modifiedTime = DateTime.now().microsecondsSinceEpoch;
    enableUpload = true;
    author = '';
    name = '';
    host = '';
    icon = '';
    group = '';
    postScript = '';
    contentType = API.MANGA;
    sort = 0;
    viewStyle = 0;
    // bool useCheerio = false;
    useCryptoJS = false;
    loadJs = '';
    userAgent = '';
    //登录规则
    loginUrl = "";
    cookies = "";
    // 发现规则
    enableDiscover = true;
    discoverUrl = '';
    discoverNextUrl = '';
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
    searchNextUrl = '';
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
    chapterNextUrl = '';
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
    contentNextUrl = '';
    contentItems = '';
  }

  Rule(
    this.id,
    this.createTime,
    this.modifiedTime,
    this.enableUpload,
    this.author,
    this.name,
    this.host,
    this.icon,
    this.group,
    this.postScript,
    this.contentType,
    this.sort,
    this.viewStyle,
    this.useCryptoJS,
    this.loadJs,
    this.userAgent,
    this.loginUrl,
    this.cookies,
    this.enableDiscover,
    this.discoverUrl,
    this.discoverNextUrl,
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
    this.searchNextUrl,
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
    this.chapterNextUrl,
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
    this.contentNextUrl,
    this.contentItems,
  );

  Rule replica() {
    return Rule(
      Uuid().v4(),
      createTime,
      modifiedTime,
      enableUpload,
      author,
      name + "_copy",
      host,
      icon,
      group,
      postScript,
      contentType,
      sort,
      viewStyle,
      useCryptoJS,
      loadJs,
      userAgent,
      loginUrl,
      cookies,
      enableDiscover,
      discoverUrl,
      discoverNextUrl,
      discoverItems,
      discoverList,
      discoverTags,
      discoverName,
      discoverCover,
      discoverAuthor,
      discoverChapter,
      discoverDescription,
      discoverResult,
      enableSearch,
      searchUrl,
      searchNextUrl,
      searchItems,
      searchList,
      searchTags,
      searchName,
      searchCover,
      searchAuthor,
      searchChapter,
      searchDescription,
      searchResult,
      enableMultiRoads,
      chapterUrl,
      chapterNextUrl,
      chapterRoads,
      chapterRoadName,
      chapterItems,
      chapterList,
      chapterName,
      chapterCover,
      chapterLock,
      chapterTime,
      chapterResult,
      contentUrl,
      contentNextUrl,
      contentItems,
    );
  }

  static Future<String> backupRules([List<Rule> rules]) async {
    await RuleDao.gaixieguizheng();
    if (rules == null) {
      rules = await Global.ruleDao.findAllRules();
    }
    return json.encode(rules.map((e) => e.toJson()).toList());
  }

  static Future<bool> restore(List<dynamic> rules, bool reset) async {
    // if (reset) await Global.ruleDao.clearAllRules();
    if (rules != null) {
      for (var item in rules) {
        var _rule = Rule.fromJson(item);
        await Global.ruleDao.insertOrUpdateRule(_rule);
      }
    }
    return true;
  }

  Map<String, dynamic> jsonZYPlayer(key, name, api) => {
        "id": cast(key, Uuid().v4()),
        "createTime": DateTime.now().microsecondsSinceEpoch,
        "modifiedTime": DateTime.now().microsecondsSinceEpoch,
        "enableUpload": true,
        "author": "ZY-Player",
        "postScript": "https://github.com/cuiocean/ZY-Player",
        "name": cast(name, "麻花"),
        "host": cast(api, ""),
        "icon": "",
        "group": "ZY-Player",
        "contentType": 2,
        "sort": 0,
        "useCryptoJS": false,
        "loadJs": "",
        "userAgent": "",
        "enableDiscover": true,
        "discoverUrl":
            "@js:\r\n(async () => {\r\n  var html = await http('');\r\n  var id = await xpath(html, '//class/*/@id');\r\n  var name = await xpath(html, '//class/*/text()');\r\n  var list = [\"全部::?ac=videolist&pg=\$page\"]\r\n  for (var i = 0; i < id.length; i++) {\r\n    list.push(`分类::\${name[i]}::?ac=videolist&t=\${id[i]}&pg=\$page`)\r\n  }\r\n  return list;\r\n})();",
        "discoverNextUrl": "",
        "discoverItems": "",
        "discoverList": "//video",
        "discoverTags": "//type/text()",
        "discoverName": "//name##.*\\[|\\].*",
        "discoverCover": "//pic/text()",
        "discoverAuthor": "演员:{{//actor##.*\\[|\\].*}},导演:{{//director##.*\\[|\\].*}}",
        "discoverChapter": "//last/text()",
        "discoverDescription": "//des##.*\\[|\\].*",
        "discoverResult": "//id/text()",
        "enableSearch": true,
        "searchUrl": "?wd=\$keyword&pg=\$page",
        "searchNextUrl": "",
        "searchItems": "",
        "searchList": "//video",
        "searchTags": "//type/text()",
        "searchName": "//name##.*\\[|\\].*",
        "searchCover": "//pic/text()",
        "searchAuthor": "演员:{{//actor##.*\\[|\\].*}},导演:{{//director##.*\\[|\\].*}}",
        "searchChapter": "//last/text()",
        "searchDescription": "//des##.*\\[|\\].*",
        "searchResult": "//id/text()",
        "enableMultiRoads": true,
        "chapterRoads": "//dd",
        "chapterRoadName": "@js:result.match(/flag=\"(.*?)\"/)[1]",
        "chapterUrl": "?ac=videolist&ids=\$result",
        "chapterNextUrl": "",
        "chapterItems": "",
        "chapterList": "@js:result.replace(/.*\\[|\\].*/g,\"\").split(\"#\")",
        "chapterName": "@js:result.split(\"\$\")[0]",
        "chapterCover": "",
        "chapterLock": "",
        "chapterTime": "",
        "chapterResult": "@js:result.split(\"\$\")[1]||result.split(\"\$\")[0]",
        "contentUrl": "null",
        "contentNextUrl": "",
        "contentItems": "@js:lastResult",
        "loginUrl": "",
        "cookies": "",
        "viewStyle": 0
      };

  // Rule.fromJson(Map<String, dynamic> json, [Rule rule]) {
  Rule.fromJson(dynamic jsonD, [Rule rule]) {
    Map<String, dynamic> json;
    if (jsonD is Map) {
      json = jsonD;
    } else if (jsonD is String) {
      if (jsonD.startsWith("eso")) {
        json = jsonDecode(RuleCompress.decompassString(jsonD));
      } else if (jsonD.startsWith("{")) {
        json = jsonDecode(jsonD);
      }
    }
    if (json == null || json.isEmpty) {
      name = "";
      host = "";
      return;
    }
    final defaultRule = rule ?? Rule.newRule();
    if (json["api"] != null && json["name"] != null) {
      json = jsonZYPlayer(json["key"], json["name"], json["api"]);
    }

    var discoverUrl2 = "${json['discoverUrl'] ?? defaultRule.discoverUrl}";
    var group2 = json['group'] ?? defaultRule.group;
    if (json['discoverMoreKeys'] != null) {
      group2 = "discoverMoreKeys;$group2";
      final more = '${json['discoverMoreKeys']}';
      if (more.contains('"isWrap": true') || more.contains('"isWrap":true')) {
        discoverUrl2 = '''测试新发现瀑布流$discoverUrl2;
;
@@DiscoverRule:${more.replaceFirst('"list"', '"rules"').replaceAll('"title"', '"option"').replaceAll('"requestFilters"', '"options"')}
        ''';
      } else {
        discoverUrl2 = """@js:
var discoverMoreKeys = $more;
;;
var r = [];
var tabIndex = 0;
var pageIndex = page;
for(var list of discoverMoreKeys.list){
  var filter = list.requestFilters[0];
  for(var item of filter.items){
    var params = {
      tabIndex,
      pageIndex,
      filters: {tabIndex, pageIndex, [filter.key]: item.value}
    };
    var url = ${discoverUrl2.replaceFirst("@js:", "")};

    r.push(`\${list.title}::\${item.title}::\${typeof(url) == 'string' ? url : JSON.stringify(url)}`)
  }
  tabIndex++;
}
r;
""";
      }
    }

    id = json['id'] ?? defaultRule.id;
    createTime = json['createTime'] ?? defaultRule.createTime;
    modifiedTime = json['modifiedTime'] ?? defaultRule.modifiedTime;
    enableUpload = json['upload'] ?? defaultRule.enableUpload;
    author = json['author'] ?? defaultRule.author;
    postScript = json['postScript'] ?? defaultRule.postScript;
    name = json['name'] ?? defaultRule.name;
    host = json['host'] ?? defaultRule.host;
    icon = json['icon'] ?? defaultRule.icon;
    group = group2;
    contentType = json['contentType'] ?? defaultRule.contentType;
    sort = json['sort'] ?? defaultRule.sort;
    viewStyle = json['viewStyle'] ?? 0;
    useCryptoJS = json['useCryptoJS'] ?? defaultRule.useCryptoJS;
    loadJs = json['loadJs'] ?? defaultRule.loadJs;
    userAgent = json['userAgent'] ?? json['httpHeaders'] ?? defaultRule.userAgent;
    enableDiscover = json['enableDiscover'] ?? defaultRule.enableDiscover;
    discoverUrl = discoverUrl2;
    discoverNextUrl = json['discoverNextUrl'] ?? defaultRule.discoverNextUrl;
    discoverItems = json['discoverItems'] ?? defaultRule.discoverItems;
    discoverList = json['discoverList'] ?? defaultRule.discoverList;
    discoverTags = json['discoverTags'] ?? defaultRule.discoverTags;
    discoverName = json['discoverName'] ?? defaultRule.discoverName;
    discoverCover = json['discoverCover'] ?? defaultRule.discoverCover;
    discoverAuthor = json['discoverAuthor'] ?? defaultRule.discoverAuthor;
    discoverChapter = json['discoverChapter'] ?? defaultRule.discoverChapter;
    discoverDescription = json['discoverDescription'] ?? defaultRule.discoverDescription;
    discoverResult = json['discoverResult'] ?? defaultRule.discoverResult;
    enableSearch = json['enableSearch'] ?? defaultRule.enableSearch;
    searchUrl = json['searchUrl'] ?? defaultRule.searchUrl;
    searchNextUrl = json['searchNextUrl'] ?? defaultRule.searchNextUrl;
    searchItems = json['searchItems'] ?? defaultRule.searchItems;
    searchList = json['searchList'] ?? defaultRule.searchList;
    searchTags = json['searchTags'] ?? defaultRule.searchTags;
    searchName = json['searchName'] ?? defaultRule.searchName;
    searchCover = json['searchCover'] ?? defaultRule.searchCover;
    searchAuthor = json['searchAuthor'] ?? defaultRule.searchAuthor;
    searchChapter = json['searchChapter'] ?? defaultRule.searchChapter;
    searchDescription = json['searchDescription'] ?? defaultRule.searchDescription;
    searchResult = json['searchResult'] ?? defaultRule.searchResult;
    enableMultiRoads = json['enableMultiRoads'] ?? defaultRule.enableMultiRoads;
    chapterRoads = json['chapterRoads'] ?? defaultRule.chapterRoads;
    chapterRoadName = json['chapterRoadName'] ?? defaultRule.chapterRoadName;
    chapterUrl = json['chapterUrl'] ?? defaultRule.chapterUrl;
    chapterNextUrl = json['chapterNextUrl'] ?? defaultRule.chapterNextUrl;
    chapterItems = json['chapterItems'] ?? defaultRule.chapterItems;
    chapterList = json['chapterList'] ?? defaultRule.chapterList;
    chapterName = json['chapterName'] ?? defaultRule.chapterName;
    chapterCover = json['chapterCover'] ?? defaultRule.chapterCover;
    chapterLock = json['chapterLock'] ?? defaultRule.chapterLock;
    chapterTime = json['chapterTime'] ?? defaultRule.chapterTime;
    chapterResult = json['chapterResult'] ?? defaultRule.chapterResult;
    contentUrl = json['contentUrl'] ?? defaultRule.contentUrl;
    contentNextUrl = json['contentNextUrl'] ?? defaultRule.contentNextUrl;
    contentItems = json['contentItems'] ?? defaultRule.contentItems;
    loginUrl = json['loginUrl'] ?? defaultRule.loginUrl;
    cookies = json['cookies'] ?? defaultRule.cookies;
  }

  Rule.fromYiCiYuan(Map<String, dynamic> json, [Rule rule]) {
    final defaultRule = rule ?? Rule.newRule();
    for (final key in json.keys) {
      var s = '${json[key]}';
      if (s.startsWith("\$") ||
          s.startsWith("http") ||
          s.startsWith(":") ||
          s.startsWith("@") ||
          s.startsWith("/")) continue;
      final flag = s.startsWith("-");
      if (flag) {
        s = s.substring(1);
      }
      if (s.startsWith("tag") || s.startsWith("class") || s.startsWith("id")) {
        s = s
            .replaceAll(RegExp(r"(?<!\|)\|(?!\|)"), "||")
            .replaceAll(RegExp(r"(?<!&)&(?!&)"), "&&")
            .replaceAll(RegExp(r"(?<!#)#(?!#)"), "##")
            .replaceAll("@tag.", " ")
            .replaceAll("@class.", " .")
            .replaceAll("@id.", " #")
            .replaceAll("@children", ">*")
            .replaceAll("tag.", "")
            .replaceAll("class.", ".")
            .replaceAll("id.", "#");
        // .replaceAllMapped(RegExp(r"\.(\d+)"), (Match m) => ":nth-of-type(${int.parse(m[1]) + 1})");
        // ":nth-of-type(${int.parse(m[1]) + 1})" 和 ":nth-child(${m[1]})" 都不好用，先去掉
        json[key] = (flag ? "-" : "") + s.trim();
      }
    }

    id = json['id'] ?? defaultRule.id;
    createTime = json['createTime'] ?? defaultRule.createTime;
    modifiedTime = json['modifiedTime'] ?? defaultRule.modifiedTime;
    enableUpload = json['upload'] ?? defaultRule.enableUpload;
    author = json['author'] ?? defaultRule.author;
    postScript = json['sourceRemark'] ?? defaultRule.postScript;
    group = json['bookSourceGroup'] ?? defaultRule.group;
    name = json['bookSourceName'] ?? defaultRule.name;
    host = json['bookSourceUrl'] ?? defaultRule.host;
    icon = json['icon'] ?? defaultRule.icon;
    contentType = json['contentType'] ?? json['bookSourceType'] == 'CARTOON'
        ? API.MANGA
        : json['bookSourceType'] == ''
            ? API.NOVEL
            : defaultRule.contentType;
    sort = json['serialNumber'] ?? defaultRule.sort;
    viewStyle = 0;
    useCryptoJS = json['useCryptoJS'] ?? defaultRule.useCryptoJS;
    loadJs = json['loadJs'] ?? defaultRule.loadJs;
    userAgent = json['httpUserAgent'] ?? defaultRule.userAgent;
    enableDiscover = json['enableDiscover'] ?? defaultRule.enableDiscover;
    discoverUrl = json['ruleFindUrl'] ?? defaultRule.discoverUrl;
    discoverNextUrl = json['discoverNextUrl'] ?? defaultRule.discoverNextUrl;
    discoverItems = json['discoverItems'] ?? defaultRule.discoverItems;
    discoverList =
        json["ruleFindList"] ?? json['ruleSearchList'] ?? defaultRule.discoverList;
    discoverTags =
        json['ruleFindKind'] ?? json['ruleSearchKind'] ?? defaultRule.discoverTags;
    discoverName =
        json['ruleFindName'] ?? json['ruleSearchName'] ?? defaultRule.discoverName;
    discoverCover = json['ruleFindCoverUrl'] ??
        json['ruleSearchCoverUrl'] ??
        defaultRule.discoverCover;
    discoverAuthor =
        json['ruleFindAuthor'] ?? json['ruleSearchAuthor'] ?? defaultRule.discoverAuthor;
    discoverChapter = json['ruleFindLastChapter'] ??
        json['ruleSearchLastChapter'] ??
        defaultRule.discoverChapter;
    discoverDescription = json['ruleFindIntroduce'] ??
        json['ruleSearchIntroduce'] ??
        defaultRule.discoverDescription;
    discoverResult = json['ruleFindNoteUrl'] ??
        json['ruleSearchNoteUrl'] ??
        defaultRule.discoverResult;
    enableSearch = json['enableSearch'] ?? defaultRule.enableSearch;
    searchUrl = json['ruleSearchUrl'] ?? defaultRule.searchUrl;
    searchNextUrl = json['searchNextUrl'] ?? defaultRule.searchNextUrl;
    searchItems = json['searchItems'] ?? defaultRule.searchItems;
    searchList = json['ruleSearchList'] ?? defaultRule.searchList;
    searchTags = json['ruleSearchKind'] ?? defaultRule.searchTags;
    searchName = json['ruleSearchName'] ?? defaultRule.searchName;
    searchCover = json['ruleSearchCoverUrl'] ?? defaultRule.searchCover;
    searchAuthor = json['ruleSearchAuthor'] ?? defaultRule.searchAuthor;
    searchChapter = json['ruleSearchLastChapter'] ?? defaultRule.searchChapter;
    searchDescription = json['ruleSearchIntroduce'] ?? defaultRule.searchDescription;
    searchResult = json['ruleSearchNoteUrl'] ?? defaultRule.searchResult;
    enableMultiRoads = json['enableMultiRoads'] ?? defaultRule.enableMultiRoads;
    chapterRoads = json['chapterRoads'] ?? defaultRule.chapterRoads;
    chapterRoadName = json['chapterRoadName'] ?? defaultRule.chapterRoadName;
    chapterUrl = json['ruleChapterUrl'] ?? defaultRule.chapterUrl;
    chapterNextUrl = json['chapterNextUrl'] ?? defaultRule.chapterNextUrl;
    chapterItems = json['chapterItems'] ?? defaultRule.chapterItems;
    chapterList = json['ruleChapterList'] ?? defaultRule.chapterList;
    chapterName = json['ruleChapterName'] ?? defaultRule.chapterName;
    chapterCover = json['chapterCover'] ?? defaultRule.chapterCover;
    chapterLock = json['chapterLock'] ?? defaultRule.chapterLock;
    chapterTime = json['chapterTime'] ?? defaultRule.chapterTime;
    chapterResult = json['ruleContentUrl'] ?? defaultRule.chapterResult;
    contentUrl = json['contentUrl'] ?? defaultRule.contentUrl;
    contentNextUrl = json['contentNextUrl'] ?? defaultRule.contentNextUrl;
    contentItems = json['ruleBookContent'] ?? defaultRule.contentItems;
    loginUrl = json['loginUrl'] ?? defaultRule.loginUrl;
    cookies = json['cookies'] ?? defaultRule.cookies;
  }

  Map<String, dynamic> toJson([bool withCookies = false]) => {
        'id': id,
        'createTime': createTime,
        'modifiedTime': modifiedTime,
        'enableUpload': enableUpload,
        'author': author,
        'postScript': postScript,
        'name': name,
        'host': host,
        'icon': icon,
        'group': group,
        'contentType': contentType,
        'sort': sort,
        'useCryptoJS': useCryptoJS,
        'loadJs': loadJs,
        'userAgent': userAgent,
        'enableDiscover': enableDiscover,
        'discoverUrl': discoverUrl,
        'discoverNextUrl': discoverNextUrl,
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
        'searchNextUrl': searchNextUrl,
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
        'chapterNextUrl': chapterNextUrl,
        'chapterItems': chapterItems,
        'chapterList': chapterList,
        'chapterName': chapterName,
        'chapterCover': chapterCover,
        'chapterLock': chapterLock,
        'chapterTime': chapterTime,
        'chapterResult': chapterResult,
        'contentUrl': contentUrl,
        'contentNextUrl': contentNextUrl,
        'contentItems': contentItems,
        'loginUrl': loginUrl,
        'cookies': withCookies == true ? cookies : "",
        'viewStyle': viewStyle ?? 0,
      }..removeWhere((key, value) => value == null || value == "");
}
