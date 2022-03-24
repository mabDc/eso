enum SelectorType { descendant, self }

class SelectorGroup {
  final List<Selector> selectors;
  final String source;
  final String? output;

  SelectorGroup(this.selectors, this.output, this.source);
}

class Selector {
  Selector({
    required this.selectorType,
    required this.axes,
    this.attr,
    this.function,
  });

  final SelectorType selectorType;
  final SelectorAxes axes;
  final String? attr;
  final String? function;

  @override
  String toString() =>
      '${selectorType == SelectorType.descendant ? '//' : '/'}${axes.axis?.toString() ?? ''}${axes.axis != null ? '::' : ''}${function ?? axes.nodeTest}${axes.predicate.isNotEmpty ? axes.predicate.map((e) => '[$e]').join() : ''}';
}

// axes
enum AxesAxis {
  ancestor,
  ancestorOrSelf,
  child,
  descendant,
  descendantOrSelf,
  following,
  followingSibling,
  parent,
  precedingSibling,
  self,
  attribute,
}

class SelectorAxes {
  SelectorAxes({
    required this.axis,
    required this.nodeTest,
    required this.predicate,
  });

  final AxesAxis? axis;
  final String nodeTest;
  final List<String> predicate;

  static AxesAxis createAxis(String axis) {
    final map = {
      'ancestor': AxesAxis.ancestor,
      'ancestor-or-self': AxesAxis.ancestorOrSelf,
      'child': AxesAxis.child,
      'descendant': AxesAxis.descendant,
      'descendant-or-self': AxesAxis.descendantOrSelf,
      'following': AxesAxis.following,
      'following-sibling': AxesAxis.followingSibling,
      'parent': AxesAxis.parent,
      'preceding-sibling': AxesAxis.precedingSibling,
      'self': AxesAxis.self,
      'attribute': AxesAxis.attribute,
    };
    if (!map.containsKey(axis)) {
      throw FormatException('not support axis: $axis');
    }
    return map[axis]!;
  }

  @override
  String toString() => 'axes: $axis nodeTest: $nodeTest predicate: $predicate';
}
