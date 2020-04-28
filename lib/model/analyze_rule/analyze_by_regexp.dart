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
   添加自定义符号 AND ,例：
   <div id="content">[\w\W]*</div>AND<li>.*?</li>
   会先匹配前面的内容，然后在前一个AND的结果中匹配后面的内容
  */
  List<String> _getList(String rule, String input) {
    var result = <String>[];
    if (null == rule || rule.isEmpty) return result;

    var rules = <String>[];
    if (rule.contains('AND')) {
      rules = rule.split('AND');
    }

    if (rules.length > 0) {
      for (var rl in rules) {
        result = _getList(rl, input);
        input = result.join('\n');
      }
    } else {
      try {
        final matcherList = RegExp(rule).allMatches(input);
        if (matcherList.isEmpty) return result;

        final builder = <String>[];
        for (var m in matcherList) {
          final value = m.group(0);
          if (value.isNotEmpty) {
            // 因为是正则匹配，所以不使用trim()去掉空格
            builder.add(value);
          }
        }
        result = builder;
      } catch (e) {
        print(e);
      }
    }
    return result;
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
      result = _getList(rule, _string).join('\n');
      return result;
    }

    final textS = <String>[];
    for (var rl in rules) {
      final temp = getString(rl);
      if (temp.isNotEmpty) {
        textS.add(temp);
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
      return _getList(rule, _string);
    }
    return result;
  }

  List<String> getList(String rule) {
    return getStringList(rule);
  }
}