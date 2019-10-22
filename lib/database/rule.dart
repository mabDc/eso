import '../global.dart';
import 'package:floor/floor.dart';

@entity
class Rule {
  @primaryKey
  int id = DateTime.now().microsecondsSinceEpoch;

  bool enable = true;
  String name = '';
  String host = '';
  RuleContentType contentType = RuleContentType.values.first;
  bool useCheerio = false;
  bool useCryptoJS = false;
  bool useMultiRoads = false;
  String discoverUrl = '';
  String discoverItems = '';
  String searchUrl = '';
  String searchItems = '';
  String detailUrl = '';
  String detailItems = '';
  String chapterUrl = '';
  String chapterItems = '';
  String contentUrl = '';
  String contentItems = '';

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
    id = DateTime.now().microsecondsSinceEpoch;
    enable = true;
    name = '';
    host = '';
    contentType = RuleContentType.values.first;
    useCheerio = false;
    useCryptoJS = false;
    useMultiRoads = false;
    discoverUrl = '';
    discoverItems = '';
    searchUrl = '';
    searchItems = '';
    detailUrl = '';
    detailItems = '';
    chapterUrl = '';
    chapterItems = '';
    contentUrl = '';
    contentItems = '';
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
