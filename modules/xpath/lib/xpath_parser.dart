import 'package:xpath_parse/token_kind.dart';
import 'package:xpath_parse/xpath_selector.dart';

/// Parse the [XPath] string to [SelectorGroup]
///
SelectorGroup parseSelectorGroup(String xpath) {
  var selectors = <Selector>[];
  String output;

  var matches = RegExp("//|/").allMatches(xpath).toList();
  var selectorSources = List<String>();
  for (var index = 0; index < matches.length; index++) {
    if (index > 0) {
      selectorSources
          .add(xpath.substring(matches[index - 1].start, matches[index].start));
    }
    if (index == matches.length - 1) {
      selectorSources.add(xpath.substring(matches[index].start, xpath.length));
    }
  }

  var lastSource = selectorSources.last.replaceAll("/", "");
  if (lastSource == "text()" || lastSource.startsWith("@")) {
    output = selectorSources.last;
    selectorSources.removeLast();
  }

  for (var source in selectorSources) {
    selectors.add(_parseSelector(source));
  }

  var firstSelector = selectors.first;
  if (firstSelector.operatorKind == TokenKind.CHILD) {
    var simpleSelector = firstSelector.simpleSelectors.first;
    if (simpleSelector != null &&
        (simpleSelector.name != "body" || simpleSelector.name != "head")) {
      selectors.insert(
          0, Selector(TokenKind.CHILD, [ElementSelector("body", "/body")]));
    }
  }

  return SelectorGroup(selectors, output, xpath);
}

///parse input string to [Selector]
///
Selector _parseSelector(String input) {
  int type;
  String source;
  var simpleSelectors = <SimpleSelector>[];
  if (input.startsWith("//")) {
    type = TokenKind.ROOT;
    source = input.substring(2, input.length);
  } else if (input.startsWith("/")) {
    type = TokenKind.CHILD;
    source = input.substring(1, input.length);
  } else {
    throw FormatException("'$input' is not a valid xpath query string");
  }

  //匹配所有父节点
  if (source == "..") {
    return Selector(TokenKind.PARENT, [ElementSelector("*", "")]);
  }

  var selector = Selector(type, simpleSelectors);

  //匹配条件
  var match = RegExp("(.+)\\[(.+)\\]").firstMatch(source);
  if (match != null) {
    var elementName = match.group(1);
    simpleSelectors.add(ElementSelector(elementName, input));
    var group = match.group(2);
    //匹配Attr
    if (group.startsWith("@")) {
      var m =
          RegExp("^@(.+?)(=|!=|\\^=|~=|\\*=|\\\$=)(.+)\$").firstMatch(group);
      if (m != null) {
        var name = m.group(1);
        var op = TokenKind.matchAttrOperator(m.group(2));
        var value = m.group(3).replaceAll(RegExp("['\"]"), "");
        simpleSelectors.add(AttributeSelector(name, op, value, group));
      } else {
        simpleSelectors.add(AttributeSelector(
            group.substring(1, group.length), TokenKind.NO_MATCH, null, group));
      }
    }
    //匹配数字
    var m = RegExp("^\\d+\$").firstMatch(group);
    if (m != null) {
      var position = int.tryParse(m.group(0));
      selector.positionSelector =
          PositionSelector(TokenKind.NUM, TokenKind.NO_MATCH, position, input);
    }

    //匹配position()方法
    m = RegExp("^position\\(\\)(<|<=|>|>=)(\\d+)\$").firstMatch(group);
    if (m != null) {
      var op = TokenKind.matchPositionOperator(m.group(1));
      var value = int.tryParse(m.group(2));
      selector.positionSelector =
          PositionSelector(TokenKind.POSITION, op, value, input);
    }

    //匹配last()方法
    m = RegExp("^last\\(\\)(-)?(\\d+)?\$").firstMatch(group);
    if (m != null) {
      var op = TokenKind.matchPositionOperator(m.group(1));
      var value = int.tryParse(m.group(2) ?? "");
      selector.positionSelector =
          PositionSelector(TokenKind.LAST, op, value, input);
    }
  } else {
    simpleSelectors.add(ElementSelector(source, input));
  }

  return selector;
}
