import 'package:jsonpath/json_path.dart';

class AnalyzeByJSonPath {
  final _jsonRulePattern = RegExp(r"\{(\$\.[^\}]+)\}");
  dynamic _ctx;
  dynamic get json => _ctx;

  AnalyzeByJSonPath(json) {
    _ctx = json;
  }

  AnalyzeByJSonPath parse(json) {
    return AnalyzeByJSonPath(json);
  }

  String getString(String rule) {
    if (rule.contains("{\$.")) {
      return rule.splitMapJoin(
        _jsonRulePattern,
        onMatch: (match) => getString(match.group(1)),
        onNonMatch: (nonMatch) => nonMatch,
      );
    }

    final result = JPath.compile(rule).search(_ctx);
    if (result is List) {
      return result.map((r) => '$r').join(", ");
    } else {
      return result == null ? "" : '$result';
    }
  }

  List<String> getStringList(String rule) {
    final result = <String>[];
    if (null == rule || rule.isEmpty) return result;
    List<String> rules;
    String elementsType;
    if (rule.contains('&&')) {
      rules = rule.split('&&');
      elementsType = '&';
    } else if (rule.contains('%%')) {
      rules = rule.split('%%');
      elementsType = '%';
    } else {
      rules = rule.split('||');
      elementsType = '|';
    }
    if (rules.length == 1) {
      if (!rule.contains('{\$.')) {
        try {
          final object = JPath.compile(rule).search(_ctx);
          if (null == object) return result;
          if (object is List) {
            for (var o in object) result.add(o.toString());
          } else {
            result.add(object.toString());
          }
        } catch (e) {
          print(e);
        }
        return result;
      } else {
        final matcher = _jsonRulePattern.allMatches(rule);
        for (var m in matcher) {
          final stringList = getStringList(m.group(0).trim());
          for (var s in stringList) {
            result.add(rule.replaceAll('{${m.group(0)}}', s));
          }
        }
        return result;
      }
    } else {
      final results = <List<String>>[];
      for (var rl in rules) {
        final temp = getStringList(rl);
        if (temp != null && temp.isNotEmpty) {
          results.add(temp);
          if (temp.length > 0 && '|' == elementsType) {
            break;
          }
        }
      }
      if (results.length > 0) {
        if ('%' == elementsType) {
          for (int i = 0; i < results[0].length; i++) {
            for (var temp in results) {
              if (i < temp.length) {
                result.add('${temp[i]}');
              }
            }
          }
        } else {
          for (var temp in results) {
            result.addAll(temp);
          }
        }
      }
      return result;
    }
  }

  List<dynamic> getList(String rule) {
    final result = <dynamic>[];
    if (null == rule || rule.isEmpty) return result;
    String elementsType;
    List<String> rules;
    if (rule.contains('&&')) {
      rules = rule.split('&&');
      elementsType = '&';
    } else if (rule.contains('%%')) {
      rules = rule.split('%%');
      elementsType = '%';
    } else {
      rules = rule.split('||');
      elementsType = '|';
    }
    if (rules.length == 1) {
      final res = JPath.compile(rules[0]).search(_ctx);
      if (null == res) return result;
//        print(res.runtimeType);
      if (res[0] is List) {
        res.forEach((r) => result.addAll(r));
      } else {
        result.addAll(res);
      }
      return result;
    } else {
      final results = <List<dynamic>>[];
      for (var rl in rules) {
        final temp = getList(rl);
        if (null != temp && temp.isNotEmpty) {
          results.add(temp);
          if (temp.length > 0 && '|' == elementsType) {
            break;
          }
        }
      }
      if (results.length > 0) {
        if ('%' == elementsType) {
          for (int i = 0; i < results[0].length; i++) {
            for (var temp in results) {
              if (i < temp.length) {
                result.add(temp[i]);
              }
            }
          }
        } else {
          for (var temp in results) {
            result.addAll(temp);
          }
        }
      }
    }
    return result;
  }
}
