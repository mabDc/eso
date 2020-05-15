import 'dart:convert';

import 'package:eso/model/analyze_rule/analyze_by_html.dart';
import 'package:eso/model/analyze_rule/analyze_by_jsonpath.dart';
import 'package:eso/model/analyze_rule/analyze_by_regexp.dart';
import 'package:eso/model/analyze_rule/analyze_by_xpath.dart';
import 'package:flutter_js/flutter_js.dart';

class AnalyzeRule {
  final dynamic _content;
  final int _idJsEngine;

  AnalyzeRule(this._content, this._idJsEngine);

  /// from https://github.com/dart-lang/sdk/issues/2336
  String Function(Match) _replacement(String pattern) => (Match match) =>
      pattern.replaceAllMapped(RegExp(r'\$(\d+)'), (m) => match[int.parse(m[1])]);

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
          return (String s) => s.replaceFirstMapped(match, _replacement(pattern));
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

  Future<List<dynamic>> getElements(String rule) async {
    var result = <dynamic>[];
    if (null == rule) return result;
    rule = rule.trimLeft();
    if (rule.isEmpty) return result;

    for (final r in splitRuleReversed(rule).reversed) {
      final re = result.isNotEmpty ? result : _content;
      switch (r.mode) {
        case Mode.CSS:
          result = AnalyzerByHtml(re).getElements(r.rule);
          break;
        case Mode.Json:
          result = AnalyzeByJSonPath(re).getList(r.rule);
          break;
        case Mode.XPath:
          result = AnalyzeByXPath(re).getElements(r.rule);
          break;
        case Mode.Regex:
          result = AnalyzerByRegexp(re).getList(r.rule);
          break;
        case Mode.JS:
          await FlutterJs.evaluate("result = ${jsonEncode(re)}", _idJsEngine);
          result = await FlutterJs.getList(r.rule, _idJsEngine);
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

    for (final r in splitRuleReversed(rule).reversed) {
      final replace = replaceListSmart(r.replace);
      final re = result.isNotEmpty ? result : _content;
      switch (r.mode) {
        case Mode.CSS:
          result = replace(AnalyzerByHtml(re).getStringList(r.rule));
          break;
        case Mode.Json:
          result = replace(AnalyzeByJSonPath(re).getStringList(r.rule));
          break;
        case Mode.XPath:
          result = replace(AnalyzeByXPath(re).getStringList(r.rule));
          break;
        case Mode.Regex:
          result = replace(AnalyzerByRegexp(re).getStringList(r.rule));
          break;
        case Mode.JS:
          await FlutterJs.evaluate("result = ${jsonEncode(re)}", _idJsEngine);
          result = await FlutterJs.getStringList(r.rule, _idJsEngine);
          break;
        default:
      }
    }
    return result;
  }

  String _getStringCustom(String rule, Mode mode, dynamic content) {
    if (rule.contains("&&")) {
      return rule.splitMapJoin(
        "&&",
        onMatch: (match) => "",
        onNonMatch: (r) => _getStringCustom(r, mode, content)?.trim() ?? "",
      );
    } else if (rule.contains('||')) {
      for (final r in rule.split('||')) {
        final temp = _getStringCustom(r, mode, content);
        if (temp.isNotEmpty) return temp;
      }
    } else {
      switch (mode) {
        case Mode.CSS:
          return AnalyzerByHtml(content).getString(rule).trim();
        case Mode.Json:
          return AnalyzeByJSonPath(content).getString(rule).trim();
        case Mode.XPath:
          return AnalyzeByXPath(content).getString(rule).trim();
        case Mode.Regex:
          return AnalyzerByRegexp(content).getString(rule).trim();
        default:
      }
    }
    return "";
  }

  final expressionPattern = RegExp(r"\{\{(.*?)\}\}", dotAll: true);
  final otherRulePattern = RegExp(r"@css:|@json:|@js:|@xpath:", caseSensitive: false);

  Future<String> getString(String rule) async {
    var result = "";
    if (null == rule) return result;
    rule = rule.trimLeft();
    if (rule.isEmpty) return result;

    // 在第一个 js 规则的前面检测 {{}} 规则
    final pFirstJS = rule.indexOf("@js:");
    final pLeft =
        pFirstJS == -1 ? rule.lastIndexOf("{{") : rule.lastIndexOf("{{", pFirstJS);
    final pRight =
        pFirstJS == -1 ? rule.lastIndexOf("}}") : rule.lastIndexOf("}}", pFirstJS);
    if (-1 < pLeft && pLeft < pRight) {
      final pOtherRule = rule.substring(pRight + 2).indexOf(otherRulePattern);
      result = (pOtherRule == -1 ? rule : rule.substring(0, pRight + 2 + pOtherRule))
          .splitMapJoin(
        expressionPattern,
        onMatch: (onMatch) {
          result = "";
          for (final r in splitRuleReversed(onMatch.group(1)).reversed) {
            result = replaceSmart(r.replace)(
                _getStringCustom(r.rule, r.mode, result.isNotEmpty ? result : _content));
          }
          return result;
        },
        onNonMatch: (nonMatch) => nonMatch,
      );
      if (pOtherRule == -1) return result;
      rule = rule.substring(pRight + 2 + pOtherRule);
    }

    for (final r in splitRuleReversed(rule).reversed) {
      if (r.mode == Mode.JS) {
        await FlutterJs.evaluate(
            "result = ${jsonEncode(result.isNotEmpty ? result : _content)}", _idJsEngine);
        result = await FlutterJs.getString(r.rule, _idJsEngine);
      } else {
        result = replaceSmart(r.replace)(
            _getStringCustom(r.rule, r.mode, result.isNotEmpty ? result : _content));
      }
    }
    return result;
  }

  final ruleTypePattern = RegExp(r"@css:|@json:|@js:|@xpath:|^", caseSensitive: false);

  /// 形如 `rule##replaceRegex##replacement##replaceFirst`
  ///
  /// 其中 `rule` 可以是 `js` 或 `css` 或 `jsonpath` , 形式如下:
  ///
  ///`@js:js code`
  ///
  ///`@json:$.name` 或 `$.name`
  ///
  ///`@css:li` 或 `li`
  ///
  ///`@xpath://li` 或 `//li`
  ///
  ///`:regex`
  ///
  /// 规则从后往前解析
  List<SingleRule> splitRuleReversed(String rule) {
    final ruleList = <SingleRule>[];
    var lastStart = rule.length;
    for (var m in ruleTypePattern.allMatches(rule).toList().reversed) {
      var r = rule.substring(m.start, lastStart).trimLeft();
      if (r.isEmpty) {
        lastStart = m.start;
        continue;
      }
      var mode = Mode.CSS;
      switch (r[0]) {
        case r"$":
          mode = Mode.Json;
          break;
        case "@":
          if (r.startsWith(RegExp(r"@js:", caseSensitive: false))) {
            r = r.substring(4);
            mode = Mode.JS;
          } else if (r.startsWith(RegExp(r"@css:", caseSensitive: false))) {
            r = r.substring(5);
            mode = Mode.CSS;
          } else if (r.startsWith(RegExp(r"@json:", caseSensitive: false))) {
            r = r.substring(6);
            mode = Mode.Json;
          } else if (r.startsWith(RegExp(r"@xpath:", caseSensitive: false))) {
            r = r.substring(7);
            mode = Mode.XPath;
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
      }

      final position = r.indexOf("##");
      if (mode != Mode.JS && position > -1) {
        ruleList
            .add(SingleRule(mode, r.substring(0, position), r.substring(position + 2)));
      } else {
        ruleList.add(SingleRule(mode, r, ""));
      }
      lastStart = m.start;
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
