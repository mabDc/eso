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

  List<String> getR(String rule) {
    rule = rule.trimRight();
    if (rule.endsWith("node()")) {
      return _xpath.query(rule).nodes.map((e) => (e.node as Element).outerHtml).toList();
    } else if (rule.endsWith("/html()")) {
      return _xpath
          .query(rule.substring(0, rule.length - 7))
          .nodes
          .map((e) => (e.node as Element).outerHtml)
          .toList();
    } else if (rule.endsWith("/only()")) {
      return _xpath
          .query(rule.substring(0, rule.length - 7))
          .nodes
          .map((e) => (e.node as Element)
              .innerHtml
              .replaceAll(RegExp("<([a-zA-Z0-9]+)[\\s\\S]+?/(\\1)?>"), "")
              .replaceAll(RegExp("<.?br.?>"), "\n"))
          .toList();
    }
    final nodes = _xpath.query(rule);
    final attrs = nodes.attrs;
    if (attrs.isEmpty && !rule.contains("@") && !rule.contains("()")) {
      return nodes.nodes.map((e) => (e.node as Element).outerHtml).toList();
    }
    return attrs;
  }

  @override
  List<String> getString(String rule) => getR(rule);

  @override
  List<String> getStringList(String rule) => getR(rule);
}
