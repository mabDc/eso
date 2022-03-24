import 'package:xpath_selector/src/builder.dart';

/// Entity name.
class NodeTagName {
  NodeTagName({required this.localName, this.namespace});

  static NodeTagName from(String qualified) {
    if (qualified.contains(':')) {
      return NodeTagName(
        namespace: qualified.split(':')[0],
        localName: qualified.split(':')[1],
      );
    }
    return NodeTagName(localName: qualified);
  }

  final String? namespace;
  final String? localName;

  String? get qualified => localName != null
      ? namespace != null
          ? '$namespace:$localName'
          : localName
      : null;

  @override
  String toString() => '<${qualified ?? 'Null'}>';

  @override
  bool operator ==(Object other) =>
      other is NodeTagName && other.qualified == qualified;

  @override
  int get hashCode => qualified.hashCode;
}

/// If you want to create your own model, please extend this class.
abstract class XPathNode<T> {
  XPathNode(this.node);

  /// Html or Xml node
  T node;

  /// TagName, [NodeTagName]
  NodeTagName? get name;

  /// Return the concatenated text of this node and all its descendants
  String? get text;

  /// Return the origin content of this node that include tags
  String? get html;

  /// Return the parent node of this node, or `null` if there is none.
  XPathNode<T>? get parent;

  /// Return the direct children of this node in document order.
  List<XPathNode<T>> get children;

  /// Return the attribute nodes of this node in document order.
  Map<String, String> get attributes;

  /// Return the next element sibling of this node, or `null`.
  XPathNode<T>? get nextSibling;

  /// Return the previous sibling of this node, or `null`.
  XPathNode<T>? get previousSibling;

  /// Is element or node
  bool get isElement;

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  XPathResult<T> queryXPath(String xpath) => XPath<T>(this).query(xpath);
}
