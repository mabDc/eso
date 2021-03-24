import 'dart:convert';

import 'analyzer.dart';
// import 'package:jsonpath/json_path.dart';
import 'package:json_path/json_path.dart';

class AnalyzerJSonPath implements Analyzer {
  final _jsonRulePattern = RegExp(r"\{(\$\.[^\}]+)\}");
  // json object
  dynamic _ctx;
  // [?(@.price)]
  final filterAttrPattern = RegExp(r"\[\?\(@\.(\w+)\)\]");

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
    final m = filterAttrPattern.firstMatch(rule);
    var list = [];
    if (m != null) {
      // 允许一次
      final attr = m[1];
      list = JsonPath(rule.replaceFirst(m.group(0), "[?$attr]"), filter: {
        attr: (e) => e is Map && e[attr] != null,
      }).read(_ctx).map((e) => e.value).toList();
    } else {
      list = JsonPath(rule).read(_ctx).map((e) => e.value).toList();
    }
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
    // return JPath.compile(rule).search(_ctx);

    final m = filterAttrPattern.firstMatch(rule);
    if (m != null) {
      // 允许一次
      final attr = m[1];
      return JsonPath(rule.replaceFirst(m.group(0), "[?$attr]"), filter: {
        attr: (e) => e is Map && e[attr] != null,
      }).read(_ctx).map((e) => e.value).join("  ");
    }
    return JsonPath(rule).read(_ctx).map((e) => e.value).join("  ");
  }

  @override
  dynamic getStringList(String rule) {
    return getElements(rule);
  }
}
