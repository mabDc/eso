import '../model/base.dart';

/// Select top element
XPathNode<T>? top<T>(XPathNode<T>? e) {
  if (e == null) return null;
  while (e!.parent != null) {
    e = e.parent!;
  }
  return e;
}

/// Selects all ancestors (parent, grandparent, etc.) of the current node
List<XPathNode<T>> ancestor<T>(XPathNode<T>? e) {
  final result = <XPathNode<T>>[];
  if (e == null) return result;
  var currentDom = e;

  while (currentDom.parent != null) {
    currentDom = currentDom.parent!;
    if (currentDom.name != null) {
      result.add(currentDom);
    }
  }
  return result;
}

/// Selects all ancestors (parent, grandparent, etc.) of the current node and the current node itself
List<XPathNode<T>> ancestorOrSelf<T>(XPathNode<T>? e) {
  if (e == null) return <XPathNode<T>>[];
  return <XPathNode<T>>[e, ...ancestor(e)];
}

/// Selects all children of the current node
List<XPathNode<T>> child<T>(XPathNode<T>? e) => e?.children ?? [];

/// Selects all descendants (children, grandchildren, etc.) of the current node
List<XPathNode<T>> descendant<T>(XPathNode<T>? e) {
  final result = <XPathNode<T>>[];
  if (e == null) return result;
  for (final child in e.children) {
    result.add(child);
    result.addAll(descendant(child));
  }
  return result;
}

/// Selects all descendants (children, grandchildren, etc.) of the current node and the current node itself
List<XPathNode<T>> descentOrSelf<T>(XPathNode<T>? e) {
  if (e == null) return <XPathNode<T>>[];
  return <XPathNode<T>>[e, ...descendant(e)];
}

/// Selects everything in the document after the closing tag of the current node
List<XPathNode<T>> following<T>(XPathNode<T> root, XPathNode<T>? e) {
  final result = <XPathNode<T>>[];
  var elementFound = false;

  void dfs(XPathNode<T> parent) {
    for (final child in parent.children) {
      if (child == e) {
        elementFound = true;
      }
      if (elementFound) {
        result.add(child);
      }
      dfs(child);
    }
  }

  dfs(root);
  return result;
}

/// Selects all siblings after the current node
List<XPathNode<T>> followingSibling<T>(XPathNode<T>? e) {
  final result = <XPathNode<T>>[];
  if (e == null) return result;
  var currentDom = e;
  while (currentDom.nextSibling != null) {
    result.add(currentDom.nextSibling!);
    currentDom = currentDom.nextSibling!;
  }
  return result;
}

/// Selects all siblings before the current node
List<XPathNode<T>> precedingSibling<T>(XPathNode<T>? e) {
  final result = <XPathNode<T>>[];
  if (e == null) return result;
  var currentDom = e;
  while (currentDom.previousSibling != null) {
    result.add(currentDom.previousSibling!);
    currentDom = currentDom.previousSibling!;
  }
  return result;
}
