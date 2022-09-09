import 'package:equatable/equatable.dart';

import '../database/chapter_item.dart';
import '../database/search_item.dart';

abstract class API {
  static String chapterUrl;
  static String contentUrl;

  static const MANGA = 0;
  static const NOVEL = 1;
  static const VIDEO = 2;
  static const AUDIO = 3;
  static const RSS = 4;
  static const NOVELMORE = 5;

  static String getRuleContentTypeName(int ruleContentType) {
    switch (ruleContentType) {
      case MANGA:
        return "图片";
      case NOVEL:
        return "文字";
      case VIDEO:
        return "视频";
      case AUDIO:
        return "音频";
      case RSS:
        return "RSS";
      case NOVELMORE:
        return "图文";
      default:
        return "图片";
    }
  }

  static int getRuleContentType(String ruleContentName) {
    switch (ruleContentName) {
      case "图片":
        return MANGA;
      case "文字":
        return NOVEL;
      case "视频":
        return VIDEO;
      case "音频":
        return AUDIO;
      case "RSS":
        return RSS;
      case "图文":
        return NOVELMORE;
      default:
        return -1;
    }
  }

  String get origin;

  String get originTag;

  int get ruleContentType;

  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize);

  Future<List<SearchItem>> search(String query, int page, int pageSize);

  Future<List<ChapterItem>> chapter(String url);

  Future<List<String>> content(String url);

  Future<List<DiscoverMap>> discoverMap();
}

class BaseAPI implements API {
  String _origin;
  String _originTag;
  int _ruleContentType;

  BaseAPI({String origin, String originTag, int ruleContentType}) {
    _origin = origin;
    _originTag = originTag;
    _ruleContentType = ruleContentType;
  }

  String get origin => _origin;

  String get originTag => _originTag;

  int get ruleContentType => _ruleContentType;

  Future<List<SearchItem>> discover(
      Map<String, DiscoverPair> params, int page, int pageSize) {
    return null;
  }

  Future<List<SearchItem>> search(String query, int page, int pageSize) {
    return null;
  }

  Future<List<ChapterItem>> chapter(String url) {
    return null;
  }

  Future<List<String>> content(String url) {
    return null;
  }

  Future<List<DiscoverMap>> discoverMap() {
    return null;
  }
}

class DiscoverMap {
  final String name;
  final List<DiscoverPair> pairs;
  const DiscoverMap(this.name, this.pairs);
}

class DiscoverPair extends Equatable {
  final String name;
  final String value;
  const DiscoverPair(this.name, this.value);

  @override
  List<Object> get props => [
        name,
        value,
      ];
}
