import 'package:eso/model/analyze_rule/analyze_by_html.dart';
import 'package:eso/model/analyze_rule/analyze_by_jsonpath.dart';

class AnalyzeRule {
  dynamic _content;
  dynamic get content => _content;
  String _baseUrl;
  String get baseUrl => _baseUrl;
  AnalyzeRule(
    this._content,
    this._baseUrl,
  );

  List<String> getStringList(String rule) {
    final result = <String>[];
    if (null == rule || rule.isEmpty) return result;
    final ruleList = splitSourceRule(rule);
    SourceRule js;
    if (ruleList.last.mode == Mode.JS) {
      js = ruleList.removeLast();
    }
    final re = <List<dynamic>>[];
    int count = -1;
    for (var r in ruleList) {
      List<String> temp;
      switch (r.mode) {
        case Mode.String:
          temp = <String>[r.rule];
          break;
        case Mode.CSS:
          temp = AnalyzerByHtml(_content).getStringList(r.rule);
          break;
        case Mode.Json:
          temp = AnalyzeByJSonPath(_content).getStringList(r.rule);
          break;
        default:
          temp = <String>[];
      }
      if (count == -1) {
        count = temp.length;
      } else if (temp.length < count) {
        count = temp.length;
      }
      re.add(temp);
    }
    for (var i = 0; i < count; i++) {
      String s = "";
      for (var r in re) {
        if (r.length == 1) {
          s += r[0];
        } else {
          s += r[i];
        }
      }
      result.add(s);
    }
    if (null != js) {
      if (result.isEmpty) {
        
      } else {}
    }
    return result;
  }

  String getString(String rule) {}

  List<SourceRule> splitSourceRule(String rule) {
    final ruleList = <SourceRule>[];
    // 规则示例
    '''https:{{@css:img@data-original##webp!0##webp!1##}}@js:baseUrl+"?source="+encodeURI(result)''';
    // 提取 js 规则, 只支持尾部出现一次
    var js = "";
    if (rule.contains("@js:")) {
      final rules = rule.split("@js:");
      rule = rules[0].trim();
      js = rules[1].trim();
    }

    if (rule.contains("{{") && rule.contains("}}")) {
      // 提取 {{}} 规则, 可能有多个, 内部可以包含##规则
      rule.splitMapJoin(
        RegExp(r"\{\{(.+?)\}\}"),
        onMatch: (match) {
          ruleList.add(SourceRule.gen(match.group(1)));
          return "";
        },
        onNonMatch: (nonMatch) {
          ruleList.add(SourceRule(
            mode: Mode.String,
            rule: nonMatch,
          ));
          return "";
        },
      );
    } else if (rule.isNotEmpty) {
      // 不存在 {{}} , 只需要考虑替换规则
      ruleList.add(SourceRule.gen(rule));
    }
    // 最后处理 js 规则
    if (js.isNotEmpty) {
      ruleList.add(SourceRule(
        mode: Mode.JS,
        rule: js,
      ));
    }
    return ruleList;
  }
}

class SourceRule {
  final Mode mode;
  final String rule;
  final String replaceRegex;
  final String replacement;
  final bool replaceFirst;
  SourceRule({
    this.mode,
    this.rule,
    this.replaceRegex = "",
    this.replacement = "",
    this.replaceFirst = false,
  });
  static SourceRule gen(String rule) {
    // 分离替换规则
    final rules = rule.split("##");
    var replaceRegex = "";
    var replacement = "";
    var replaceFirst = false;
    if (rules.length > 1) {
      replaceRegex = rules[1];
    }
    if (rules.length > 2) {
      replacement = rules[2];
    }
    if (rules.length > 3) {
      replaceFirst = true;
    }
    rule = rules[0];
    // 确定 rule 和 mode
    var mode = Mode.CSS;
    if (rule.substring(0, 5).toLowerCase() == "@css:") {
      rule = rule.substring(5);
      mode = Mode.CSS;
    } else if (rule.substring(0, 6).toLowerCase() == "@json:") {
      rule = rule.substring(6);
      mode = Mode.Json;
    }
    return SourceRule(
      mode: mode,
      rule: rule,
      replaceRegex: replaceRegex,
      replacement: replacement,
      replaceFirst: replaceFirst,
    );
  }
}

enum Mode {
  JS,
  CSS,
  Json,
  String,
  // XPath,
  // Default,
  // Regex,
}
