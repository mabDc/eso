import 'analyzer.dart';
import 'package:html/dom.dart';
// import 'package:xpath_parse/xpath_selector.dart';
import 'package:xpath_selector/xpath_selector.dart';

class AnalyzerXPath implements Analyzer {
  XPath<Node> _xpath;

  @override
  AnalyzerXPath parse(content) {
    if (content is Element) {
      _xpath = XPath.htmlElement(content);
    } else if (content is Document) {
      _xpath = XPath.htmlElement(content.documentElement);
    } else if (content is String) {
      _xpath = XPath.html(content);
    } else {
      _xpath = XPath.html('$content');
    }
    return this;
  }

  @override
  List<Element> getElements(String rule) {
    return _xpath.query(rule).nodes.map((e) => e.node as Element).toList();
  }

  @override
  List<String> getString(String rule) {
    return _xpath.query(rule).attrs;
  }

  @override
  List<String> getStringList(String rule) {
    return _xpath.query(rule).attrs;
  }
}
