import 'package:html/dom.dart';
import 'package:xpath_parse/xpath_selector.dart';

class AnalyzeByXPath {
  XPath _xpath;
  XPath get xpath => _xpath;

  AnalyzeByXPath(doc) {
    if (doc is Element) {
      _xpath = XPath(doc);
    } else if (doc is Document) {
      _xpath = XPath(doc.documentElement);
    } else if (doc is String) {
      _xpath = XPath.source(doc);
    } else {
      _xpath = XPath.source('$doc');
    }
  }

  AnalyzeByXPath parse(doc) {
    return AnalyzeByXPath(doc);
  }

  String getString(String rule) {
    return _xpath.query(rule).list().join(", ");
  }

  List<String> getStringList(String rule) {
    final result = <String>[];

    if (rule.contains('&&')) {
      for (final r in rule.split('&&')) {
        result.addAll(getStringList(r));
      }
    } else if (rule.contains('||')) {
      for (final r in rule.split('||')) {
        final stringList = getStringList(r);
        if (stringList.isNotEmpty) return stringList;
      }
    } else if (rule.contains('%%')) {
      final rules = rule.split('%%');
      final results = <List<String>>[];
      final el = <int>[];
      int max = 0;
      for (final r in rules) {
        final temp = _xpath.query(r).list();
        final l = temp.length;
        results.add(temp);
        el.add(l);
        if (l > max) max = l;
      }
      for (var i = 0; i < max; i++) {
        for (var j = 0; j < el.length; j++) {
          if (i < el[j]) {
            result.add(results[j][i]);
          }
        }
      }
    } else {
      return _xpath.query(rule).list();
    }
    return result;
  }

  List<Element> getElements(String rule) {
    final result = <Element>[];

    if (rule.contains('&&')) {
      for (final r in rule.split('&&')) {
        result.addAll(_xpath.query(r).elements());
      }
    } else if (rule.contains('||')) {
      for (final r in rule.split('||')) {
        final elementsList = _xpath.query(r).elements();
        if (elementsList.isNotEmpty) return elementsList;
      }
    } else if (rule.contains('%%')) {
      final rules = rule.split('%%');
      final elementsList = <List<Element>>[];
      final el = <int>[];
      int max = 0;
      rules.forEach((r) {
        final temp = _xpath.query(r).elements();
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
      return _xpath.query(rule).elements();
    }
    return result;
  }
}
