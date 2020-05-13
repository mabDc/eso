import 'dart:convert';

import 'package:eso/model/analyze_rule/analyze_by_html.dart';
import 'package:eso/model/analyze_rule/analyze_by_jsonpath.dart';
import 'package:flutter_js/flutter_js.dart';

class AnalyzeRule {
  final dynamic _content;
  final int _idJsEngine;

  AnalyzeRule(this._content, this._idJsEngine);

  /// from https://github.com/dart-lang/sdk/issues/2336
  String Function(Match) _replacement(String pattern) =>
      (Match match) => pattern.replaceAllMapped(
          RegExp(r'\$(\d+)'), (m) => match[int.parse(m[1])]);

  String Function(String) replaceSmart(String replace) {
    if (null == replace || replace.isEmpty) return (String s) => s;
    final r = replace.split("##");
    final match = RegExp(r[0]);
    if (r.length == 1) {
      return (String s) => s.replaceAll(match, "");
    } else {
      final pattern = r[1];
      if (pattern.contains("\$")) {
        if (r.length == 2) {
          return (String s) => s.replaceAllMapped(match, _replacement(pattern));
        } else {
          return (String s) =>
              s.replaceFirstMapped(match, _replacement(pattern));
        }
      } else {
        if (r.length == 2) {
          return (String s) => s.replaceAll(match, pattern);
        } else {
          return (String s) => s.replaceFirst(match, pattern);
        }
      }
    }
  }

  List<String> Function(List<String>) replaceListSmart(String replace) {
    if (null == replace || replace.isEmpty) return (List<String> s) => s;
    final _replaceSmart = replaceSmart(replace);
    return (List<String> ls) => ls.map((s) => _replaceSmart(s)).toList();
  }

  List<dynamic> _getElementsSync(String rule) {
    var result = <dynamic>[];
    for (var r in splitRuleReversed(rule).reversed) {
      switch (r.mode) {
        case Mode.CSS:
          result = AnalyzerByHtml(result.isNotEmpty ? result : _content)
              .getElements(r.rule);
          break;
        case Mode.Json:
          result = AnalyzeByJSonPath(result.isNotEmpty ? result : _content)
              .getList(r.rule);
          break;
        default:
      }
    }
    return result;
  }

  Future<List<dynamic>> getElements(String rule) async {
    var result = <dynamic>[];
    if (null == rule) return result;
    rule = rule.trimLeft();
    if (rule.isEmpty) return result;

    var position = rule.indexOf("@js:");
    if (position == -1) {
      return _getElementsSync(rule);
    }
    if (position > 0) {
      result = _getElementsSync(rule.substring(0, position));
    }
    if (position > -1) {
      await FlutterJs.evaluate(
          "result = ${jsonEncode(result.isNotEmpty ? result : _content)}",
          _idJsEngine);
      return FlutterJs.getList(rule.substring(position + 4), _idJsEngine);
    }
    return result;
  }

  List<String> _getStringListSync(String rule) {
    var result = <String>[];
    for (var r in splitRuleReversed(rule).reversed) {
      final replace = replaceListSmart(r.replace);
      final re = result.isNotEmpty ? result : _content;
      switch (r.mode) {
        case Mode.CSS:
          result = replace(AnalyzerByHtml(re).getStringList(r.rule));
          break;
        case Mode.Json:
          result = replace(AnalyzeByJSonPath(re).getStringList(r.rule));
          break;
        default:
      }
    }
    return result;
  }

  Future<List<String>> getStringList(String rule) async {
    var result = <String>[];
    if (null == rule) return result;
    rule = rule.trimLeft();
    if (rule.isEmpty) return result;

    var position = rule.indexOf("@js:");
    if (position == -1) {
      return _getStringListSync(rule);
    }
    if (position > 0) {
      result = _getStringListSync(rule.substring(0, position));
    }
    if (position > -1) {
      await FlutterJs.evaluate(
          "result = ${jsonEncode(result.isNotEmpty ? result : _content)}",
          _idJsEngine);
      return FlutterJs.getStringList(rule.substring(position + 4), _idJsEngine);
    }
    return result;
  }

  final expressionPattern = RegExp(r"\{\{.*?\}\}", dotAll: true);

  String _getStringSync(String rule) {
    if (rule.contains("{{") && rule.contains("}}")) {
      return rule.splitMapJoin(
        expressionPattern,
        onMatch: (onMatch) => _getStringSync(onMatch.group(1)),
        onNonMatch: (nonMatch) => nonMatch,
      );
    } else {
      var result = "";
      for (var r in splitRuleReversed(rule).reversed) {
        final replace = replaceSmart(r.replace);
        final re = result.isNotEmpty ? result : _content;
        switch (r.mode) {
          case Mode.CSS:
            result = replace(AnalyzerByHtml(re).getString(r.rule));
            break;
          case Mode.Json:
            result = replace(AnalyzeByJSonPath(re).getString(r.rule));
            break;
          default:
        }
      }
      return result;
    }
  }

  Future<String> getString(String rule) async {
    var result = "";
    if (null == rule) return result;
    rule = rule.trimLeft();
    if (rule.isEmpty) return result;

    var position = rule.indexOf("@js:");
    if (position == -1) {
      return _getStringSync(rule);
    }
    if (position > 0) {
      result = _getStringSync(rule.substring(0, position));
    }
    if (position > -1) {
      await FlutterJs.evaluate(
          "result = ${jsonEncode(result.isNotEmpty ? result : _content)}",
          _idJsEngine);
      return FlutterJs.getString(rule.substring(position + 4), _idJsEngine);
    }
    return result;
  }

  final ruleTypePattern = RegExp(r"@css:|@json:|^", caseSensitive: false);

  /// 形如 rule##replaceRegex##replacement##replaceFirst
  ///
  /// 其中 [rule] 可以是 css 或 jsonpath , 形式如下:
  ///
  ///     @json:$.name
  ///     $.name
  ///     @css:li
  ///     li
  ///     :regex
  ///
  /// 规则从后往前解析
  List<SingleRule> splitRuleReversed(String rule) {
    final ruleList = <SingleRule>[];
    var lastEnd = rule.length;
    for (var end in ruleTypePattern
        .allMatches(rule)
        .map((m) => m.end)
        .toList()
        .reversed) {
      var r = rule.substring(end, lastEnd).trimLeft();
      if (r.isEmpty) {
        lastEnd = end;
        continue;
      }
      Mode mode;
      switch (r[0]) {
        case r"$":
          mode = Mode.Json;
          break;
        case "@":
          if (r.startsWith(RegExp(r"@json:", caseSensitive: false))) {
            r = r.substring(6);
            mode = Mode.Json;
          } else if (r.startsWith(RegExp(r"@css:", caseSensitive: false))) {
            r = r.substring(5);
            mode = Mode.CSS;
          }
          break;
        case ":":
          r = r.substring(1);
          mode = Mode.Regex;
          break;
        case "/":
          mode = Mode.XPath;
          break;
        default:
          mode = Mode.CSS;
      }
      final position = r.indexOf("##");
      if (position > -1) {
        ruleList.add(SingleRule(
            mode, r.substring(0, position), r.substring(position + 2)));
      } else {
        ruleList.add(SingleRule(mode, r, ""));
      }
      lastEnd = end;
    }
    return ruleList;
  }
}

class SingleRule {
  final Mode mode;
  final String rule;
  final String replace;
  SingleRule(this.mode, this.rule, this.replace);
}

enum Mode {
  JS,
  CSS,
  Json,
  Regex,
  XPath,
  String,
  // Default,
}
