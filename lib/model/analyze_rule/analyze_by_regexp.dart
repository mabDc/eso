import 'package:html/dom.dart';

class AnalyzerByRegexp {
  String _string;
  String get source => _string;

  AnalyzerByRegexp(str) {
    if (str is String) {
      _string = str;
    } else if (str is Document) {
      _string = str.outerHtml;
    } else if (str is Element) {
      _string = str.outerHtml;
    } else {
      _string = '$str';
    }
  }

  AnalyzerByRegexp parse(str) {
    return AnalyzerByRegexp(str);
  }

  /*
  使用正向/反向肯定/否定预查 (?<=pattern)  (?=pattern)  (?!pattern)  (?<!pattern)
  来定位内容，例：r'(?<=href=")[^"]*'
  */
  String getString(String rule) {
    var result = "";
    if (null == rule || rule.isEmpty) return result;

    var rules = <String>[];
    bool customOrRule = false;
    if (rule.contains('&&')) {
      rules = rule.split('&&');
    } else if (rule.contains('||')) {
      rules = rule.split('||');
      customOrRule = true;
    } else {
      try {
        final matcherList = RegExp(rule).allMatches(_string);
        if (matcherList.isEmpty) return result;

        final builder = <String>[];
        for (var m in matcherList) {
          final value = m.group(0);
          if (value.isNotEmpty) {
            builder.add(value.trim());
          }
        }
        result = builder.join('\n');
      } catch (e) {
        print(e);
      }
      return result;
    }

    final textS = <String>[];
    for (var rl in rules) {
      final temp = getString(rl);
      if (temp.isNotEmpty) {
        textS.add(temp.trim());
        if (customOrRule) break;
      }
    }

    return textS.join("\n");
  }

  List<String> getStringList(String rule) {
    final result = <String>[];
    if (null == rule || rule.isEmpty) return result;

    if (rule.contains('&&')) {
      for (var rl in rule.split('&&')) {
        result.addAll(getStringList(rl));
      }
    } else if (rule.contains('||')) {
      for (var rl in rule.split('||')) {
        final stringList = getStringList(rl);
        if (stringList.isNotEmpty) return stringList;
      }
    } else if (rule.contains('%%')) {
      final results = <List<String>>[];
      for (var rl in rule.split('%%')) {
        results.add(getStringList(rl));
      }
      if (results.length > 0) {
        for (int i = 0; i < results[0].length; i++) {
          for (var temp in results) {
            if (i < temp.length) {
              result.add('${temp[i]}');
            }
          }
        }
      }
    } else {
      final matcherList = RegExp(rule).allMatches(_string);
      if (matcherList.isEmpty) return result;
      for (var m in matcherList) {
        final value = m.group(0);
        if (value.isNotEmpty) {
          result.add(value.trim());
        }
      }
    }
    return result;
  }
}
