import 'package:xml/xml.dart';
import '../../xpath_selector.dart';

/// Built-in xml model.
class XmlNodeTree extends XPathNode<XmlNode> {
  XmlNodeTree(XmlNode node) : super(node);

  static XmlNodeTree? from(XmlNode? node) {
    if (node == null) return null;
    return XmlNodeTree(node);
  }

  @override
  bool get isElement => node is XmlElement;

  @override
  Map<String, String> get attributes => Map.fromEntries(
      node.attributes.map((e) => MapEntry(e.name.qualified, e.value)));

  @override
  List<XmlNodeTree> get children =>
      node.children.map((child) => XmlNodeTree(child)).toList();

  @override
  XmlNodeTree? get parent => from(node.parent);

  @override
  String? get text => node.text;

  @override
  String? get html => node.outerXml;

  @override
  bool operator ==(Object other) => other is XmlNodeTree && other.node == node;

  @override
  int get hashCode => node.hashCode;

  @override
  NodeTagName? get name =>
      isElement ? NodeTagName.from(element.name.qualified) : null;

  @override
  String toString() => node.toString();

  @override
  XmlNodeTree? get nextSibling => from(node.nextElementSibling);

  @override
  XmlNodeTree? get previousSibling => from(node.previousSibling);

  XmlElement get element {
    if (!isElement) throw Exception('$node is not XmlElement');
    return node as XmlElement;
  }
}

extension XmlElementHelper on XmlElement {
  /// Xml XPath query
  XPathResult<XmlNode> queryXPath(String xpath) =>
      XPath.xmlElement(this).query(xpath);
}
