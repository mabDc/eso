import 'analyzer.dart';
import 'package:html/dom.dart';
import 'package:xpath_parse/xpath_selector.dart';

class AnalyzerXPath implements Analyzer {
  XPath _xpath;

  @override
  int get jsEngineId => null;

  @override
  AnalyzerXPath parse(content) {
    if (content is Element) {
      _xpath = XPath(content);
    } else if (content is Document) {
      _xpath = XPath(content.documentElement);
    } else if (content is String) {
      _xpath = XPath.source(content);
    } else {
      _xpath = XPath.source('$content');
    }
    return this;
  }

  @override
  List<Element> getElements(String rule) {
    return _xpath.query(rule).elements();
  }

  @override
  List<String> getString(String rule) {
    return _xpath.query(rule).list();
  }

  @override
  List<String> getStringList(String rule) {
    return _xpath.query(rule).list();
  }
}
