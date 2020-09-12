import 'dart:convert';

import 'package:eso/api/analyze_url.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/utils/decode_body.dart';

import 'analyzer.dart';

class AnalyzerHttp implements Analyzer {
  String _content;
  Rule _rule;

  AnalyzerHttp(Rule rule) {
    _rule = rule;
  }

  @override
  AnalyzerHttp parse(content) {
    if (content is List && content.length > 0) {
      _content = '${content.first}';
    } else if (content is Map) {
      _content = jsonEncode(content);
    } else {
      _content = '$content';
    }
    return this;
  }

  @override
  Future<String> getElements(String rule) {
    return getString(rule);
  }

  @override
  Future<String> getString(String rule) async {
    rule = rule.trim().isNotEmpty ? rule : _content;
    final res = await AnalyzeUrl.urlRuleParser(rule, _rule, result: _content);
    return DecodeBody().decode(res.bodyBytes, res.headers["content-type"]);
  }

  @override
  Future<String> getStringList(String rule) {
    return getString(rule);
  }
}
