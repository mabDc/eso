import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

class AnalyzerByHtml {
  Element _element;
  Element get element => _element;

  AnalyzerByHtml(doc) {
    if (doc is Element) {
      _element = doc;
    } else if (doc is Document) {
      _element = doc.documentElement;
    } else if (doc is String) {
      _element = parser.parse(doc).documentElement;
    } else {
      _element = parser.parse('$doc').documentElement;
    }
  }

  AnalyzerByHtml parse(doc) {
    return AnalyzerByHtml(doc);
  }

  Element _querySelector(String selector) {
    return _element.querySelector(selector);
  }

  List<Element> _querySelectorAll(String selector) {
    return _element.querySelectorAll(selector);
  }

  String _getResult(Element e, String lastRule) {
    switch (lastRule) {
      case 'text':
        return e.text.trim();
      case 'id':
        return e.id;
      case 'outerHtml':
        return e.outerHtml;
      case 'innerHtml':
      case 'html':
        return e.innerHtml;
      default:
        final r = e.attributes[lastRule];
        return null == r || r.isEmpty ? '' : r.trim();
    }
  }

  String getString(String rule) {
    if (rule == null || rule.isEmpty) return "";

    var rules = <String>[];
    bool customOrRule = false;
    if (rule.contains('&&')) {
      rules = rule.split('&&');
    } else if (rule.contains('||')) {
      rules = rule.split('||');
      customOrRule = true;
    } else if (!rule.contains('@')) {
      return _getResult(_element, rule);
    } else {
      final lastRule = rule.split('@').last;
      final elementList = _querySelectorAll(
          rule.substring(0, rule.length - lastRule.length - 1));
      final builder = <String>[];
      for (var e in elementList) {
        final r = _getResult(e, lastRule);
        if (r.isNotEmpty) builder.add(r.trim());
      }
      return builder.join('\n');
    }

    final textS = <String>[];
    for (var rl in rules) {
      final temp = getString(rl);
      if (temp.isNotEmpty) {
        textS.add(temp.trim());
        if (customOrRule) {
          break;
        }
      }
    }
    return textS.join("\n");
  }

  List<String> getStringList(String rule) {
    final result = <String>[];
    if (null == rule || rule.isEmpty) return result;

    if (rule.contains('&&')) {
      for (var r in rule.split('&&')) {
        result.addAll(getStringList(r));
      }
    } else if (rule.contains('||')) {
      for (var r in rule.split('||')) {
        final stringList = getStringList(r);
        if (stringList.isNotEmpty) return stringList;
      }
    } else if (rule.contains('%%')) {
      final rules = rule.split('%%');
      final elementsList = <List<Element>>[];
      final lastRuleList = <String>[];
      final el = <int>[];
      int max = 0;
      for (var r in rules) {
        final lastRule = r.split('@').last;
        final temp =
            _querySelectorAll(r.substring(0, rule.length - lastRule.length));
        final l = temp.length;
        lastRuleList.add(lastRule);
        elementsList.add(temp);
        el.add(l);
        if (l > max) max = l;
      }
      for (var i = 0; i < max; i++) {
        for (var j = 0; j < el.length; j++) {
          if (i < el[j]) {
            result.add(_getResult(elementsList[j][i], lastRuleList[j]));
          }
        }
      }
    } else {
      final lastRule = rule.split('@').last;
      final elementList =
          _querySelectorAll(rule.substring(0, rule.length - lastRule.length));
      for (var e in elementList) {
        final r = _getResult(e, lastRule);
        if (r.isNotEmpty) result.add(r);
      }
    }
    return result;
  }

  List<Element> getElements(String rule) {
    final result = <Element>[];
    if (null == rule || rule.isEmpty) return result;

    if (rule.contains('&&')) {
      for (var r in rule.split('&&')) {
        result.addAll(_querySelectorAll(r));
      }
    } else if (rule.contains('||')) {
      for (var r in rule.split('||')) {
        final elementsList = _querySelectorAll(r);
        if (elementsList.isNotEmpty) return elementsList;
      }
    } else if (rule.contains('%%')) {
      final rules = rule.split('%%');
      final elementsList = <List<Element>>[];
      final el = <int>[];
      int max = 0;
      rules.forEach((r) {
        final temp = _querySelectorAll(r);
        final l = temp.length;
        elementsList.add(temp);
        el.add(l);
        if (l > max) max = l;
      });
      for (var i = 0; i < max; i++) {
        for (var j = 0; j < el.length; j++) {
          if (i < el[j]) {
            result.add(elementsList[j][i]);
          }
        }
      }
    } else {
      return _querySelectorAll(rule);
    }
    return result;
  }
}
