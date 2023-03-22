import 'package:eso/api/analyze_hetu.dart';
import 'package:eso/api/analyzer.dart';
import 'package:eso/api/analyzer_html.dart';
import 'package:eso/api/analyzer_js.dart';
import 'package:eso/api/analyzer_jsonpath.dart';
import 'package:eso/api/analyzer_regexp.dart';
import 'package:eso/api/analyzer_xpath.dart';
import 'package:eso/api/anaylyzer_webview.dart';
import 'analyzer_filter.dart';
import 'analyzer_match.dart';
import 'analyzer_replace.dart';

class AnalyzerManager {
  final ruleTypePattern = RegExp(
      r"@js:" // @js: code
      "|"
      "@hetu:" // @hetu: code
      "|"
      "@web:" // @web:[(baseUrl|result)@@]script0[\n\s*@@\s*\nscript1]
      "|"
      "@webview:" // @webview:[(baseUrl|result)@@]script0[\n\s*@@\s*\nscript1]
      "|"
      "@css:" // @css:a, @css:a@href, @css:a@text
      "|"
      "@json:" // @json:$.books.*, @json:$.name
      "|"
      "@http:" // @http:, @http:/api/$result
      "|"
      "@xpath:" // @xpath://a, @xpath:/a/@href, @xpath: /a/text()
      "|"
      "@match:" // @match:http.*?jpg， @match:url\("?(.*?jpg)@@1
      "|"
      "@regex:" // @regexp:h3[\s\S]*?h3
      "|"
      "@regexp:" // @regexp:h3[\s\S]*?h3
      "|"
      "@filter:" // @filter:lrc, @filter:m3u8, @filter:mp3
      "|"
      "@replace:" // @replace:</?em>, @replace:(?=\d+)@@播放量
      "|"
      "@encode:" // @encode:utf8|gbk|md5|base64|hmac|sha|sha256|aes
      "|"
      "@decode:" // @decode:utf8|gbk|base64|hmac|sha|sha256|aes
      "|"
      "^", // 首规则用如下符号开头 $(jsonpath), /(xpath), :(正则)
      caseSensitive: false);
  final expressionPattern = RegExp(r"\{\{(.*?)\}\}", dotAll: true);

  final dynamic _content;

  AnalyzerManager(this._content);

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

  Future<dynamic> _getElements(SingleRule r, [String rule]) async {
    if (null == rule) {
      rule = r.rule;
    }
    if (r.analyzer is AnalyzerJS) {
      return r.analyzer.getElements(rule);
    }
    if (rule.contains("&&")) {
      var result = <dynamic>[];
      for (final rSimple in rule.split("&&")) {
        final temp = await _getElements(r, rSimple);
        if (temp.isNotEmpty) result.addAll(temp);
      }
      return result;
    } else if (rule.contains("||")) {
      for (final rSimple in rule.split("||")) {
        final temp = await _getElements(r, rSimple);
        if (temp.isNotEmpty) return temp;
      }
    } else {
      return r.analyzer.getElements(rule);
    }
    return null;
  }

  Future<List<dynamic>> getElements(String rule) async {
    var result = <dynamic>[];
    if (null == rule) return result;
    rule = rule.trimLeft();
    if (rule.isEmpty) return result;
    dynamic temp = result.isNotEmpty ? result : _content;
    for (final r in splitRuleReversed(rule).reversed) {
      r.analyzer.parse(temp);
      temp = await _getElements(r);
    }
    if (temp is List) {
      return temp.where((e) => null != e).toList();
    } else if (null != temp) {
      return [temp];
    }
    return result;
  }

  Future<dynamic> _getStringList(SingleRule r, [String rule]) async {
    if (null == rule) {
      rule = r.rule;
    }
    if (r.analyzer is AnalyzerJS) {
      return r.analyzer.getStringList(rule);
    }
    if (rule.contains("&&")) {
      var result = <String>[];
      for (final rSimple in rule.split("&&")) {
        final temp = await _getStringList(r, rSimple);
        if (temp is List) {
          result.addAll(temp
              .where((e) => null != e)
              .map((s) => '$s'.trim())
              .where((s) => s.isNotEmpty));
        } else if (null != temp && '$temp'.trim().isNotEmpty) {
          result.add('$temp'.trim());
        }
      }
      return result;
    } else if (rule.contains("||")) {
      var result = <String>[];
      for (final rSimple in rule.split("||")) {
        final temp = await _getStringList(r, rSimple);
        if (temp is List) {
          result = temp
              .where((e) => null != e)
              .map((s) => '$s'.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        } else if (null != temp && '$temp'.trim().isNotEmpty) {
          result = <String>['$temp'.trim()];
        }
        if (result.isNotEmpty) return result;
      }
    } else {
      return r.analyzer.getStringList(rule);
    }
    return null;
  }

  Future<List<String>> getStringList(String rule) async {
    var result = <String>[];
    if (null == rule) return result;
    rule = rule.trimLeft();
    if (rule.isEmpty) return result;

    final pLeft = rule.lastIndexOf("{{");
    final pRight = rule.lastIndexOf("}}");
    if (-1 < pLeft && pLeft < pRight) {
      var position = 0;
      int minCount;
      final rs = <dynamic>[];
      for (final match in expressionPattern.allMatches(rule)) {
        rs.add(rule.substring(position, match.start));
        position = match.end;
        final temp = await getStringList(match.group(1));
        if (temp.isEmpty) continue;
        if (temp.length == 1) {
          rs.add(temp[0]);
        } else {
          rs.add(temp);
          if (minCount == null || temp.length < minCount) {
            minCount = temp.length;
          }
        }
      }
      if (position < rule.length) {
        rs.add(rule.substring(position));
      }
      return List.generate(minCount ?? 1, (int i) {
        return rs.map((e) {
          if (e is String) {
            return e;
          }
          if (e is List<String>) {
            return e[i];
          }
          return '';
        }).join();
      });
    }
    dynamic temp = result.isNotEmpty ? result : _content;
    for (final r in splitRuleReversed(rule).reversed) {
      r.analyzer.parse(temp);
      temp = await _getStringList(r);
      if (r.replace.isNotEmpty) {
        if (temp is List) {
          temp = replaceSmart(r.replace)(temp.join("\n"));
        } else {
          temp = replaceSmart(r.replace)("$temp");
        }
      }
    }
    if (temp is List) {
      result = temp
          .where((e) => null != e)
          .map((s) => '$s'.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (null != temp) {
      result = <String>['$temp'.trim()];
    }
    return result;
  }

  Future<String> _getString(SingleRule r, [String rule]) async {
    if (null == rule) {
      rule = r.rule;
    }
    if (r.analyzer is AnalyzerJS) {
      final temp = await r.analyzer.getString(rule);
      if (temp == null) {
        return '';
      } else if (temp is List) {
        /// 使用双半角空格分隔
        return temp
            .where((s) => null != s)
            .map((s) => '$s'.trim())
            .where((s) => s.isNotEmpty)
            .join("  ");
      }
      return '$temp'.trim();
    }
    var result = "";
    if (rule.contains("&&")) {
      final rs = <String>[];
      for (final rSimple in rule.split("&&")) {
        final temp = await _getString(r, rSimple);
        if (temp.isNotEmpty) rs.add(temp);
      }
      return rs.join("  ");
    } else if (rule.contains("||")) {
      for (final rSimple in rule.split("||")) {
        final temp = await _getString(r, rSimple);
        if (temp.isNotEmpty) return temp;
      }
    } else {
      final temp = await r.analyzer.getString(rule);
      if (temp is List) {
        /// 使用双半角空格分隔
        result = temp
            .where((s) => null != s)
            .map((s) => '$s'.trim())
            .where((s) => s.isNotEmpty)
            .join("  ");
      } else if (null != temp) {
        result = '$temp'.trim();
      }
    }
    return result.isEmpty ? "" : replaceSmart(r.replace)(result);
  }

  Future<String> getString(String rule) async {
    var result = "";
    if (null == rule) return result;
    rule = rule.trimLeft();
    if (rule.isEmpty) return result;

    final pLeft = rule.lastIndexOf("{{");
    final pRight = rule.lastIndexOf("}}");
    if (-1 < pLeft && pLeft < pRight) {
      var position = 0;
      final rs = <String>[];
      for (final match in expressionPattern.allMatches(rule)) {
        rs.add(rule.substring(position, match.start));
        position = match.end;
        rs.add(await getString(match.group(1)));
      }
      if (position < rule.length) {
        rs.add(rule.substring(position));
      }
      return rs.join();
    }

    var first = true;
    for (final r in splitRuleReversed(rule).reversed) {
      if (first) {
        r.analyzer.parse(result.isNotEmpty ? result : _content);
        first = false;
      } else {
        r.analyzer.parse(result);
      }
      result = await _getString(r);
    }
    return result;
  }

  /// 形如 `rule##replaceRegex##replacement##replaceFirst`
  ///
  /// 其中 `rule` 可以是 `js` 或 `css` 或 `xpath` 或 `jsonpath` , 形式如下:
  ///
  /// `@js:js code`
  ///
  /// `@json:$.name` 或 `$.name`（省略`@json:`）
  ///
  /// `@css:li` 或 `li`（省略`@css:`）
  ///
  /// `@xpath://li` 或 `//li`（省略`@xpath:`）
  ///
  /// `:regex`
  /*
      "@js:" // @js: code
      "|"
      "@css:" // @css:a, @css:a@href, @css:a@text
      "|"
      "@json:" // @json:$.books.*, @json:$.name
      "|"
      "@http:" // @http:, @http:/api/$result
      "|"
      "@xpath:" // @xpath://a, @xpath:/a/@href, @xpath: /a/text()
      "|"
      "@match:" // @match:http.*?jpg， @match:url\("?(.*?jpg)@@1
      "|"
      "@regex:" // @regexp:h3[\s\S]*?h3
      "|"
      "@regexp:" // @regexp:h3[\s\S]*?h3
      "|"
      "@filter:" // @filter:lrc, @filter:m3u8, @filter:mp3
      "|"
      "@replace:" // @replace:</?em>, @replace:(?=\d+)@@播放量
      "|"
      "^", // 首规则用如下符号开头 $(jsonpath), /(xpath), :(正则)
  */
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
      Analyzer analyzer;
      switch (r[0]) {
        case r"$":
          analyzer = AnalyzerJSonPath();
          break;
        case "@":
          if (r.startsWith(RegExp(r"@js:", caseSensitive: false))) {
            r = r.substring(4);
            analyzer = AnalyzerJS();
          } else if (r.startsWith(RegExp(r"@hetu:", caseSensitive: false))) {
            r = r.substring(6);
            analyzer = AnalyzerHetu();
          } else if (r.startsWith(RegExp(r"@css:", caseSensitive: false))) {
            r = r.substring(5);
            analyzer = AnalyzerHtml();
          } else if (r.startsWith(RegExp(r"@json:", caseSensitive: false))) {
            r = r.substring(6);
            analyzer = AnalyzerJSonPath();
          } else if (r.startsWith(RegExp(r"@xpath:", caseSensitive: false))) {
            r = r.substring(7);
            analyzer = AnalyzerXPath();
          } else if (r.startsWith(RegExp(r"@match:", caseSensitive: false))) {
            r = r.substring(7);
            analyzer = AnalyzerMatch();
          } else if (r.startsWith(RegExp(r"@regex:", caseSensitive: false))) {
            r = r.substring(7);
            analyzer = AnalyzerRegExp();
          } else if (r.startsWith(RegExp(r"@regexp:", caseSensitive: false))) {
            r = r.substring(8);
            analyzer = AnalyzerRegExp();
          } else if (r.startsWith(RegExp(r"@filter:", caseSensitive: false))) {
            r = r.substring(8);
            analyzer = AnalyzerFilter();
          } else if (r.startsWith(RegExp(r"@replace:", caseSensitive: false))) {
            r = r.substring(9);
            analyzer = AnalyzerReplace();
          } else if (r.startsWith(RegExp(r"@webview:", caseSensitive: false))) {
            r = r.substring(9);
            analyzer = AnalyzerWebview();
          } else if (r.startsWith(RegExp(r"@web:", caseSensitive: false))) {
            r = r.substring(5);
            analyzer = AnalyzerWebview();
          }
          break;
        case ":":
          r = r.substring(1);
          analyzer = AnalyzerRegExp();
          break;
        case "/":
          analyzer = AnalyzerXPath();
          break;
        default:
          analyzer = AnalyzerHtml();
      }

      final position = r.indexOf("##");
      if (!(analyzer is AnalyzerJS) && position > -1) {
        ruleList.add(
            SingleRule(analyzer, r.substring(0, position), r.substring(position + 2)));
      } else {
        ruleList.add(SingleRule(analyzer, r, ""));
      }
      lastStart = m.start;
    }
    return ruleList;
  }
}

class SingleRule {
  final Analyzer analyzer;
  final String rule;
  final String replace;
  SingleRule(this.analyzer, this.rule, this.replace);
}
