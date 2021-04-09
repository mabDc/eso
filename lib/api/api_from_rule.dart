import 'package:eso/database/chapter_item.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/database/search_item.dart';

import 'api.dart';

class APIFromRUle implements API {
  final Rule rule;
  String _origin;
  String _originTag;
  int _ruleContentType;
  int _engineId;
  String _host;

  static clearNextUrl() {}

  @override
  String get origin => _origin;

  @override
  String get host => _host;

  @override
  String get originTag => _originTag;

  @override
  int get ruleContentType => _ruleContentType;

  APIFromRUle(this.rule, [int engineId]) {
    _engineId = engineId;
    _origin = rule.name;
    _originTag = rule.id;
    _ruleContentType = rule.contentType;
    _host = rule.host;
  }

  @override
  Future<List<SearchItem>> discover(Map<String, DiscoverPair> params, int page, int pageSize) async {
    return null;
  }

  @override
  Future<List<SearchItem>> search(String query, int page, int pageSize) async {
    return null;
  }

  @override
  Future<List<ChapterItem>> chapter(final String url) async {
    return null;
  }

  @override
  Future<List<String>> content(final String url) async {
    return null;
  }

  @override
  Future<List<DiscoverMap>> discoverMap() async {
    return null;
  }
}
