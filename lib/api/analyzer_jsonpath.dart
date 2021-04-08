import 'dart:convert';

import 'analyzer.dart';
// import 'package:jsonpath/json_path.dart';
import 'package:json_path/json_path.dart';

class AnalyzerJSonPath implements Analyzer {
  final _jsonRulePattern = RegExp(r"\{(\$\.[^\}]+)\}");
  dynamic _ctx;

  @override
  AnalyzerJSonPath parse(content) {
    if (content is List || content is Map) {
      _ctx = content;
    } else {
      try {
        _ctx = jsonDecode("$content".replaceAll(RegExp(r",\s*(?=\]|\})"), ""));
      } catch (e) {
        _ctx = ["$content"];
      }
    }
    return this;
  }

  @override
  dynamic getElements(String rule) {
    final list = JsonPath(rule).readValues(_ctx).toList();
    if (list == null || list.isEmpty) return <String>[];
    if (list.length == 1) {
      return list[0];
    }
    return list;
  }

  @override
  String getString(String rule) {
    if (rule.contains("{\$.")) {
      return rule.splitMapJoin(
        _jsonRulePattern,
        onMatch: (match) => getString(match.group(1)),
        onNonMatch: (nonMatch) => nonMatch,
      );
    }
    return JsonPath(rule).readValues(_ctx).join("  ");
  }

  @override
  dynamic getStringList(String rule) {
    return getElements(rule);
  }
}
