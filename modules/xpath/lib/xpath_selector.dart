import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:xpath_parse/token_kind.dart';
import 'package:xpath_parse/xpath_parser.dart';

class XPath {
  final rootElement;

  XPath(this.rootElement);

  ///parse [html] to node
  ///
  static XPath source(String html) {
    var node = parse(html).documentElement;
    var evaluator = XPath(node);
    return evaluator;
  }

  ///query data from [rootElement] by [xpath]
  ///
  SelectorEvaluator query(String xpath) {
    var evaluator = SelectorEvaluator();
    evaluator.matchSelectorGroup(rootElement, parseSelectorGroup(xpath));
    return evaluator;
  }
}

class SelectorEvaluator extends VisitorBase {
  Element _element;

  //结果
  var _results = <Element>[];
  var _temps = <Element>[];
  String _output;

  ///select elements from node or node.child  which match selector
  ///
  void matchSelector(Node node, Selector selector) {
    _temps.clear();
    if (node is! Element) return;
    switch (selector.operatorKind) {
      case TokenKind.CHILD:
        {
          for (var item in node.nodes) {
            if (item is! Element) continue;
            _element = item;
            if (selector.visit(this)) {
              _temps.add(item);
            }
          }
          _removeIfNotMatchPosition(selector);
          _results.addAll(_temps);
        }
        break;
      case TokenKind.ROOT:
        for (var item in node.nodes) {
          if (item is! Element) continue;
          _element = item;
          if (selector.visit(this)) {
            _temps.add(item);
          }
        }
        _removeIfNotMatchPosition(selector);
        _results.addAll(_temps);
        for (var item in node.nodes) {
          matchSelector(item, selector);
        }

        break;
      case TokenKind.CURRENT:
        _element = node;
        if (selector.visit(this)) {
          _results.add(node);
        }
        break;
      case TokenKind.PARENT:
        _element = node.parent;
        if (selector.visit(this)) {
          _results.add(_element);
        }
        break;
    }
  }

  ///select elements from node or node.child  which match group
  ///
  void matchSelectorGroup(Node node, SelectorGroup group) {
    _output = group.output;
    _results = [node];
    for (var selector in group.selectors) {
      var list = List.of(_results);
      _results.clear();
      for (var item in list) {
        matchSelector(item, selector);
      }
    }
  }

  ///return first of  [list]
  ///
  String get() {
    var data = list();
    if (data.isNotEmpty) {
      return data.first;
    } else {
      return "";
    }
  }

  ///return List<String> form [_results] output text
  ///
  List<String> list() {
    var list = <String>[];

    if (_output == "/text()") {
      for (var element in elements()) {
        list.add(element.text.trim());
      }
    } else if (_output == "//text()") {
      void getTextByElement(List<Element> elements) {
        for (var item in elements) {
          list.add(item.text.trim());
          getTextByElement(item.children);
        }
      }

      getTextByElement(elements());
    } else if (_output?.startsWith("/@") == true) {
      var attr = _output.substring(2, _output.length);
      for (var element in elements()) {
        var attrValue = element.attributes[attr].trim();
        if (attrValue != null) {
          list.add(attrValue);
        }
      }
    } else if (_output?.startsWith("//@") == true) {
      var attr = _output.substring(3, _output.length);
      void getAttrByElements(List<Element> elements) {
        for (var element in elements) {
          var attrValue = element.attributes[attr].trim();
          if (attrValue != null) {
            list.add(attrValue);
          }
        }
        for (var element in elements) {
          getAttrByElements(element.children);
        }
      }

      getAttrByElements(elements());
    } else {
      for (var element in elements()) {
        list.add(element.outerHtml);
      }
    }
    if (list.isEmpty) {
      print("xpath query result is empty");
    }
    return list;
  }

  List<Element> elements() => _results;

  _unsupported(selector) =>
      FormatException("'$selector' is not a valid selector");

  @override
  bool visitAttributeSelector(AttributeSelector selector) {
    // Match name first
    var value = _element.attributes[selector.name.toLowerCase()];
    if (value == null) return false;

    if (selector.operatorKind == TokenKind.NO_MATCH) return true;

    var select = '${selector.value}';
    switch (selector.operatorKind) {
      case TokenKind.EQUALS:
        return value == select;
      case TokenKind.NOT_EQUALS:
        return value != select;
      case TokenKind.INCLUDES:
        return value.split(' ').any((v) => v.isNotEmpty && v == select);
      case TokenKind.PREFIX_MATCH:
        return value.startsWith(select);
      case TokenKind.SUFFIX_MATCH:
        return value.endsWith(select);
      case TokenKind.SUBSTRING_MATCH:
        return value.contains(select);
      default:
        throw _unsupported(selector);
    }
  }

  @override
  bool visitElementSelector(ElementSelector selector) =>
      selector.isWildcard || _element.localName == selector.name.toLowerCase();

  @override
  bool visitPositionSelector(PositionSelector selector) {
    var index = _temps.indexOf(_element) + 1;
    if (index == -1) return false;
    var value = selector.value;
    if (selector._position == TokenKind.NUM) {
      return index == value;
    } else if (selector._position == TokenKind.POSITION) {
      switch (selector.operatorKind) {
        case TokenKind.GREATER:
          return index > value;
        case TokenKind.GREATER_OR_EQUALS:
          return index >= value;
        case TokenKind.LESS:
          return index < value;
        case TokenKind.LESS_OR_EQUALS:
          return index <= value;
        default:
          throw _unsupported(selector);
      }
    } else if (selector._position == TokenKind.LAST) {
      switch (selector.operatorKind) {
        case TokenKind.MINUS:
          return index == _temps.length - value - 1;
        case TokenKind.NO_MATCH:
          return index >= _temps.length - 1;
        default:
          throw _unsupported(selector);
      }
    } else {
      throw _unsupported(selector);
    }
  }

  @override
  bool visitSelector(Selector selector) {
    var result = true;
    for (var s in selector.simpleSelectors) {
      result = s.visit(this);
      if (!result) break;
    }
    return result;
  }

  void _removeIfNotMatchPosition(Selector node) {
    _temps.removeWhere((item) {
      _element = item;
      return node.positionSelector?.visit(this) == false;
    });
  }

  @override
  visitSimpleSelector(SimpleSelector node) => false;
}

///
/// select element which match [Selector]
///
class SelectorGroup {
  final List<Selector> selectors;
  final String source;
  final String output;

  SelectorGroup(this.selectors, this.output, this.source);
}

///
/// select element which match [SimpleSelector]
///
class Selector {
  /// [TokenKind.CHILD]
  /// [TokenKind.ROOT]
  /// [TokenKind.CURRENT]
  /// [TokenKind.PARENT]
  ///
  final int _nodeType;

  final List<SimpleSelector> simpleSelectors;

  PositionSelector positionSelector;

  int get operatorKind => _nodeType;

  Selector(this._nodeType, this.simpleSelectors);

  bool visit(VisitorBase visitor) => visitor.visitSelector(this);
}

class SimpleSelector {
  final String _name;
  final String _source;

  SimpleSelector(this._name, this._source);

  String get name => _name;

  bool get isWildcard => _name == "*";

  ///transfer  [VisitorBase.visitSimpleSelector]
  visit(VisitorBase visitor) => visitor.visitSimpleSelector(this);

  @override
  String toString() => _source;
}

/// select name of elements
class ElementSelector extends SimpleSelector {
  ElementSelector(String name, String source) : super(name, source);

  ///transfer  [VisitorBase.visitElementSelector]
  visit(VisitorBase visitor) => visitor.visitElementSelector(this);

  String toString() => name;
}

///select attr of elements
class AttributeSelector extends SimpleSelector {
  final int _op;
  final _value;

  AttributeSelector(String name, this._op, this._value, String source)
      : super(name, source);

  int get operatorKind => _op;

  get value => _value;

  ///transfer  [VisitorBase.visitAttributeSelector]
  visit(VisitorBase visitor) => visitor.visitAttributeSelector(this);
}

///select position of elements
class PositionSelector extends SimpleSelector {
  // last() or position()
  final int _position;

  // >  >=  <  <=  or null
  final int _op;
  final int _value;

  PositionSelector(this._position, this._op, this._value, String source)
      : super("*", source);

  int get operatorKind => _op;

  get value => _value;

  ///transfer  [VisitorBase.visitPositionSelector]
  visit(VisitorBase visitor) => visitor.visitPositionSelector(this);
}

abstract class VisitorBase {
  visitSimpleSelector(SimpleSelector node);

  ///return [bool] type
  ///if element enable visit by ElementSelector  true
  ///else   false
  bool visitElementSelector(ElementSelector node);

  ///return [bool] type
  ///if element enable visit by AttributeSelector  true
  ///else   false
  bool visitAttributeSelector(AttributeSelector node);

  ///return [bool] type
  ///if element enable visit by PositionSelector  true
  ///else   false
  bool visitPositionSelector(PositionSelector node);

  ///return [bool] type
  ///if element enable visit by selector  true
  ///else   false
  bool visitSelector(Selector node);
}
//</editor-fold>
