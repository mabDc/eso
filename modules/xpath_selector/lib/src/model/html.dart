import '../../xpath_selector.dart';
import 'package:html/dom.dart';

/// Built-in html model.
class HtmlNodeTree extends XPathNode<Node> {
  HtmlNodeTree(Node node) : super(node);

  static HtmlNodeTree? from(Node? node) {
    if (node == null) return null;
    return HtmlNodeTree(node);
  }

  @override
  bool get isElement => node is Element;

  @override
  HtmlNodeTree? get parent => from(node.parentNode);

  @override
  List<HtmlNodeTree> get children =>
      node.children.map((e) => HtmlNodeTree(e)).toList();

  @override
  HtmlNodeTree? get nextSibling =>
      isElement ? from(element.nextElementSibling) : null;

  @override
  HtmlNodeTree? get previousSibling =>
      isElement ? from(element.previousElementSibling) : null;

  @override
  Map<String, String> get attributes =>
      node.attributes.map((key, value) => MapEntry(key.toString(), value));

  @override
  String? get text => node.text;

  @override
  String? get html => element.outerHtml;

  @override
  String toString() => node.toString();

  @override
  bool operator ==(Object other) => other is HtmlNodeTree && other.node == node;

  @override
  int get hashCode => node.hashCode;

  @override
  NodeTagName? get name =>
      isElement ? NodeTagName(localName: element.localName) : null;

  Element get element {
    if (!isElement) throw Exception('$node is not Element');
    return node as Element;
  }
}

extension HtmlElementHelper on Element {
  /// Html XPath query
  XPathResult<Node> queryXPath(String xpath) =>
      XPath.htmlElement(this).query(xpath);
}
