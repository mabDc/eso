import 'package:jsonpath/json_path.dart';

class AnalyzeByJSonPath {
  final _jsonRulePattern = new RegExp(r"(?<={)\$\..+?(?=})");
  dynamic _ctx = null;

  AnalyzeByJSonPath parse(json) {
    _ctx = json;
    return this;
  }

  String getString(String rule) {
    if (rule.isEmpty) return "";
    var result = "";
    List<String> rules;
    String elementsType;
    if (rule.contains("&&")) {
      rules = rule.split("&&");
      elementsType = "&";
    } else {
      rules = rule.split("||");
      elementsType = "|";
    }
    if (rules.length == 1) {
      if (!rule.contains("{\$.")) {
        try {
          var ob = JPath.compile(rule).search(_ctx);
          if (ob is List) {
            List<String> builder = [];
            for (var o in ob) {
              builder.add(o);
              builder.add("\n");
            }
            result = builder.toString().replaceFirst(new RegExp(r'\n$'), "");
          } else {
            result = ob.toString();
          }
        } catch (e) {
          print(e);
        }
        return result;
      } else {
        result = rule;
        var matcher = _jsonRulePattern.allMatches(rule);
        for (var m in matcher) {
          result = result.replaceAll("{${m.group(0)}}", getString(m.group(0).trim()));
        }
        return result;
      }
    } else {
      List<String> textS = [];
      for (String rl in rules) {
        String temp = getString(rl);
        if (temp.isNotEmpty) {
          textS.add(temp);
          if (elementsType == "|") {
            break;
          }
        }
      }
      return textS.map((s) => s.trim()).join("\n");
    }
  }

  List<String> getStringList(String rule) {
    List<String> result = [];
    if (rule.isEmpty) return result;
    List<String> rules;
    String elementsType;
    if (rule.contains("&&")) {
      rules = rule.split("&&");
      elementsType = "&";
    } else if (rule.contains("%%")) {
      rules = rule.split("%%");
      elementsType = "%";
    } else {
      rules = rule.split("||");
      elementsType = "|";
    }
    if (rules.length == 1) {
      if (!rule.contains("{\$.")) {
        try {
          var object = JPath.compile(rule).search(_ctx);
          if (object == null) return result;
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
        var matcher = _jsonRulePattern.allMatches(rule);
        for (var m in matcher) {
          var stringList = getStringList(m.group(0).trim());
          for (var s in stringList) {
            result.add(rule.replaceAll("{${m.group(0)}}", s));
          }
        }
        return result;
      }
    } else {
      List<List<String>> results = [];
      for (var rl in rules) {
        List<String> temp = getStringList(rl);
        if (temp.isNotEmpty) {
          results.add(temp);
          if (temp.length > 0 && elementsType == "|") {
            break;
          }
        }
      }
      if (results.length > 0) {
        if ("%" == elementsType) {
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
      return result;
    }
  }

  dynamic getObject(String rule) {
    return JPath.compile(rule).search(_ctx);
  }

  List<dynamic> getList(String rule) {
    List<dynamic> result = [];
    if (rule.isEmpty) return result;
    String elementsType;
    List<String> rules;
    if (rule.contains("&&")) {
      rules = rule.split("&&");
      elementsType = "&";
    } else if (rule.contains("%%")) {
      rules = rule.split("%%");
      elementsType = "%";
    } else {
      rules = rule.split("||");
      elementsType = "|";
    }
    if (rules.length == 1) {
      try {
        return JPath.compile(rules[0]).search(_ctx);
      } catch (e) {
        print(e);
        return null;
      }
    } else {
      List<List> results = [];
      for (var rl in rules) {
        var temp = getList(rl);
        if (temp.isNotEmpty) {
          results.add(temp);
          if (temp.length > 0 && elementsType == "|") {
            break;
          }
        }
      }
      if (results.length > 0) {
        if ("%" == elementsType) {
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
