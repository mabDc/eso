import 'package:expressions/expressions.dart';
import 'package:xpath_selector/src/parser.dart';
import 'package:xpath_selector/src/utils/dom_selector.dart';
import 'package:xpath_selector/src/selector.dart';
import 'package:xpath_selector/src/utils/utils.dart';
import 'model/base.dart';
import 'reg.dart';
import 'utils/op.dart';

List<XPathNode<T>> execute<T>({
  required List<Selector> selectorList,
  required XPathNode<T> element,
}) {
  var tmp = <XPathNode<T>>[element];

  for (final selector in selectorList) {
    final rootMatch = <XPathNode<T>>[];
    for (final element in tmp) {
      final pathXPathNode = _matchSelectPath<T>(selector, element);
      final selectorMatch = <XPathNode<T>>[];
      for (final element in pathXPathNode) {
        final axisXPathNode = _matchAxis<T>(selector, element);
        final removeIndex = [];

        // _matchSelector
        for (var i = 0; i < axisXPathNode.length; i++) {
          final element = axisXPathNode[i];
          if (!_matchSelector(
              selector: selector,
              element: element,
              position: i,
              length: axisXPathNode.length)) {
            removeIndex.add(i);
          }
        }
        for (final index in removeIndex.reversed) {
          axisXPathNode.removeAt(index);
        }
        removeIndex.clear();

        // matchPredicates
        for (final predicate in selector.axes.predicate) {
          for (var i = 0; i < axisXPathNode.length; i++) {
            final element = axisXPathNode[i];
            if (!_matchPredicates(
              selector: selector,
              element: element,
              position: i,
              length: axisXPathNode.length,
              predicate: predicate,
            )) {
              removeIndex.add(i);
            }
          }
          for (final index in removeIndex.reversed) {
            axisXPathNode.removeAt(index);
          }
          removeIndex.clear();
        }

        selectorMatch.addAllIfNotExist(axisXPathNode);
      }
      rootMatch.addAllIfNotExist(selectorMatch);
    }
    tmp = rootMatch;
  }
  return tmp;
}

/// Get element by path
List<XPathNode<T>> _matchSelectPath<T>(Selector selector, XPathNode<T> node) {
  final waitingSelect = <XPathNode<T>>[];
  switch (selector.selectorType) {
    case SelectorType.descendant:
      waitingSelect.addAllIfNotExist(descentOrSelf<T>(node));
      break;
    case SelectorType.self:
      waitingSelect.addIfNotExist(node);
      break;
  }
  return waitingSelect;
}

/// Get element by Axis
List<XPathNode<T>> _matchAxis<T>(Selector selector, XPathNode<T> node) {
  final waitingSelect = <XPathNode<T>>[];
  switch (selector.axes.axis) {
    case AxesAxis.child:
    case null:
      waitingSelect.addAllIfNotExist(node.children);
      break;
    case AxesAxis.ancestor:
      waitingSelect.addAllIfNotExist(ancestor(node));
      break;
    case AxesAxis.ancestorOrSelf:
      waitingSelect.addAllIfNotExist(ancestorOrSelf(node));
      break;
    case AxesAxis.descendant:
      waitingSelect.addAllIfNotExist(descendant(node));
      break;
    case AxesAxis.descendantOrSelf:
      waitingSelect.addAllIfNotExist(descentOrSelf(node));
      break;
    case AxesAxis.following:
      waitingSelect.addAllIfNotExist(following(top(node) ?? node, node));
      break;
    case AxesAxis.parent:
      if (node.parent != null) waitingSelect.add(node.parent!);
      break;
    case AxesAxis.followingSibling:
      waitingSelect.addAllIfNotExist(followingSibling(node));
      break;
    case AxesAxis.precedingSibling:
      waitingSelect.addAllIfNotExist(precedingSibling(node));
      break;
    case AxesAxis.attribute:
    case AxesAxis.self:
      waitingSelect.addIfNotExist(node);
      break;
  }
  return waitingSelect;
}

/// Is element match [Selector]'s [selector.axes.nodeTest] and [predicate]
bool _matchSelector({
  required Selector selector,
  required XPathNode element,
  required int position,
  required int length,
}) {
  if (selector.attr != null) return true;
  if (selector.axes.axis == AxesAxis.attribute) return true;

  // node-test
  final nodeTest = selector.axes.nodeTest;

  if (nodeTest != 'node()') {
    if (!element.isElement) return false;
    if (nodeTest != '*' && element.name?.qualified != nodeTest) return false;
  }
  return true;
}

/// Is element match [selector.axes.predicate]
bool _matchPredicates({
  required Selector selector,
  required XPathNode element,
  required int position,
  required int length,
  required String predicate,
}) {
  predicate = predicate.replaceAll(' and ', ' && ');
  predicate = predicate.replaceAll(' or ', ' || ');
  predicate = predicate.replaceAll(' div ', ' / ');
  predicate = predicate.replaceAll(' mod ', ' % ');

  if (predicate.contains(' && ') || predicate.contains(' || ')) {
    return _multipleCompare(
      predicate: predicate,
      element: element,
      position: position,
      length: length,
    );
  } else {
    // Position
    if (predicateLast.hasMatch(predicate) || predicateInt.hasMatch(predicate)) {
      return _singlePosition(
        predicate: predicate,
        position: position,
        length: length,
      );
    }

    // Compare
    return _singleCompare(
      predicate: predicate,
      element: element,
      position: position,
      length: length,
    );
  }
}

bool _singlePosition({
  required String predicate,
  required int position,
  required int length,
}) {
  // [last() - 1]
  final lastReg = simpleLast.firstMatch(predicate);
  if (lastReg != null) {
    final num = int.tryParse(lastReg.namedGroup('num')!) ?? 0;
    final op = lastReg.namedGroup('op')!;
    return opNum(length, num, op) == position + 1;
  }

  // [last()]
  final last = simpleSingleLast.firstMatch(predicate);
  if (last != null) {
    return length == position + 1;
  }

  // [1]
  final indexReg = predicateInt.firstMatch(predicate);
  if (indexReg != null) {
    final num = int.tryParse(indexReg.namedGroup('num')!) ?? 0;
    return num == position + 1;
  }

  throw UnsupportedError('Unsupported predicate: $predicate');
}

bool _multipleCompare({
  required String predicate,
  required XPathNode element,
  required int position,
  required int length,
}) {
  var expression = predicate;

  // [position() < 3]
  final positionReg = simplePosition.allMatches(predicate);
  for (final reg in positionReg) {
    final result = _positionMatch(position, reg)!;
    expression = expression.replaceAll(reg[0]!, result ? 'true' : 'false');
  }

  // [@attr='value'] [text()='']
  final equalReg = predicateEqual.allMatches(predicate);
  for (final reg in equalReg) {
    final result = _equalMatch(element, reg)!;
    expression = expression.replaceAll(reg[0]!, result ? 'true' : 'false');
  }

  // [child>1]
  final childReg = predicateChild.allMatches(predicate);
  for (final reg in childReg) {
    final result = _childMatch(element, reg)!;
    expression = expression.replaceAll(reg[0]!, result ? 'true' : 'false');
  }

  // [not?(function(param1, param2))]
  final functionReg = functionPredicate.allMatches(predicate);
  for (final reg in functionReg) {
    final result = _functionMatch(element, reg)!;
    expression = expression.replaceAll(reg[0]!, result ? 'true' : 'false');
  }

  final eval = Expression.parse(expression);
  final evaluator = const ExpressionEvaluator();
  final result = evaluator.eval(eval, {});
  if (result is bool) return result;
  throw FormatException(
      'Expression parse error, raw: $predicate, replaced: $predicate');
}

bool _singleCompare({
  required String predicate,
  required XPathNode element,
  required int position,
  required int length,
}) {
  // [position() < 3]
  final positionReg = simplePosition.firstMatch(predicate);
  final positionResult = _positionMatch(position, positionReg);
  if (positionResult != null) return positionResult;

  // [@attr='gdd'] [function()='foo']
  final attrReg = predicateEqual.firstMatch(predicate);
  final attrResult = _equalMatch(element, attrReg);
  if (attrResult != null) return attrResult;

  // [child<10]
  final childReg = predicateChild.firstMatch(predicate);
  final childResult = _childMatch(element, childReg);
  if (childResult != null) return childResult;

  // [not?(function(param1, param2))]
  final functionReg = functionPredicate.firstMatch(predicate);
  final functionResult = _functionMatch(element, functionReg);
  if (functionResult != null) return functionResult;

  throw UnsupportedError('Unsupported predicate: $predicate');
}

bool? _positionMatch(int position, RegExpMatch? reg) {
  if (reg != null) {
    final op = reg.namedGroup('op')!;
    final num = int.tryParse(reg.namedGroup('num')!) ?? 0;
    return opCompare(position + 1, num, op);
  }
  return null;
}

bool? _equalMatch(XPathNode node, RegExpMatch? reg) {
  if (reg != null) {
    final key = reg.namedGroup('function')!.replaceAll(' ', '');
    final rightValue = reg.namedGroup('value')!;
    final op = reg.namedGroup('op')!;
    final notValue = reg.namedGroup('not') == 'not';
    bool not(bool value) => notValue ? !value : value;
    final leftValue = elementFunction(node: node, function: key);
    if (leftValue == null) return false;
    return not(opString(leftValue, rightValue, op));
  }
  return null;
}

bool? _childMatch(XPathNode element, RegExpMatch? reg) {
  if (reg != null) {
    final childName = reg.namedGroup('child');
    final op = reg.namedGroup('op')!;
    final num = int.tryParse(reg.namedGroup('num')!) ?? 0;
    final int? childValue = element.children
        .where((e) => e.isElement && e.name?.qualified == childName)
        .map((e) => int.tryParse(e.text ?? ''))
        .firstWhere((e) => e != null, orElse: () => null);
    if (childValue == null) return false;
    return opCompare(childValue, num, op);
  }
  return null;
}

bool? _functionMatch(XPathNode node, RegExpMatch? reg) {
  if (reg != null) {
    final notValue = reg.namedGroup('not') == 'not';
    bool not(bool value) => notValue ? !value : value;
    final function = reg.namedGroup('function')!.toLowerCase().trim();
    final param1 = reg.namedGroup('param1')!.toLowerCase().trim();
    final param2 = reg.namedGroup('param2')!;
    final leftValue = elementFunction(node: node, function: param1);
    if (leftValue == null) return false;
    if (function == 'contains') {
      return not(leftValue.contains(param2));
    } else if (function == 'starts-with') {
      return not(leftValue.startsWith(param2));
    } else if (function == 'ends-with') {
      return not(leftValue.endsWith(param2));
    } else {
      throw UnsupportedError('UnSupport $function');
    }
  }
  return null;
}
