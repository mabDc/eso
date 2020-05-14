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
      case 'textNodes':
        return e.children.map((e) => e.text).join("\n").trim(); // 适用于文字类正文 用换行符
      case 'id':
        return e.id;
      case 'outerHtml':
        return e.outerHtml;
      case 'innerHtml':
      case 'html':
        return e.innerHtml;
      default:
        final r = e.attributes[lastRule];
        return null == r ? '' : r.trim();
    }
  }

  String getString(String rule) {
    if (!rule.contains('@')) {
      return _getResult(_element, rule);
    } else {
      final split = rule.lastIndexOf("@");
      final lastRule = rule.substring(split + 1);
      final elementList = _querySelectorAll(rule.substring(0, split));
      final builder = <String>[];
      for (var e in elementList) {
        final r = _getResult(e, lastRule);
        if (r.isNotEmpty) builder.add(r.trim());
      }
      return builder.join('\n');
    }
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
        final split = r.lastIndexOf("@");
        final lastRule = r.substring(split + 1);
        final temp = _querySelectorAll(r.substring(0, split));
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
      final split = rule.lastIndexOf("@");
      final lastRule = rule.substring(split + 1);
      final elementList = _querySelectorAll(rule.substring(0, split));
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
