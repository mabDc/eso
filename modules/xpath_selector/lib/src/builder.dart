import 'package:html/dom.dart' as import_html;
import 'package:html/parser.dart' as import_html;
import 'package:xpath_selector/src/parser.dart';
import 'package:xml/xml.dart' as import_xml;

import 'execute.dart';
import 'model/base.dart';
import 'model/html.dart';
import 'model/xml.dart';

/// Result of XPath
class XPathResult<T> {
  XPathResult(this.nodes, this.attrs);

  /// Get all nodes of query results
  final List<XPathNode<T>> nodes;

  /// Get all properties of query results
  final List<String?> attrs;

  /// Get the first node of query results
  XPathNode<T>? get node => nodes.isNotEmpty ? nodes.first : null;

  /// Get the first valid property of the query result (not null)
  String? get attr => attrs.firstWhere((e) => e != null, orElse: () => null);

  @Deprecated('Use nodes instead')
  List<XPathNode<T>> get elements => nodes;

  /// Get the first node of query results
  @Deprecated('Use node instead')
  XPathNode<T>? get element => nodes.isNotEmpty ? nodes.first : null;

  @override
  String toString() => '<XPathResult: $nodes>';
}

/// Query root node
class XPath<T> {
  /// Create XPath by element
  XPath(this.root);

  final XPathNode<T> root;

  /// Create XPath by html string
  static XPath<import_html.Node> html(String value) {
    final dom = import_html.parse(value).documentElement;
    if (dom == null) throw UnsupportedError('No html');
    return XPath<import_html.Node>(HtmlNodeTree(dom));
  }

  /// Create XPath by html element
  static XPath<import_html.Node> htmlElement(import_html.Element element) =>
      XPath(HtmlNodeTree(element));

  /// Create XPath by xml string
  static XPath<import_xml.XmlNode> xml(String value) {
    final dom = import_xml.XmlDocument.parse(value);
    return XPath(XmlNodeTree(dom));
  }

  /// Create XPath by xml element
  static XPath<import_xml.XmlNode> xmlElement(import_xml.XmlElement element) =>
      XPath<import_xml.XmlNode>(XmlNodeTree(element));

  /// Query XPath
  XPathResult<T> query(String xpath) {
    final result = <XPathNode<T>>[];
    final resultAttrs = <String?>[];
    final selectorGroup = parseSelectGroup(xpath);
    for (final selector in selectorGroup) {
      final newResult = execute<T>(selectorList: selector, element: root)
          .where((e) => !result.contains(e))
          .toList();
      result.addAll(newResult);
      resultAttrs.addAll(parseAttr(
        selectorList: selector,
        elements: newResult.toList(),
      ));
    }
    return XPathResult(result, resultAttrs);
  }
}
