import 'dart:convert';

import 'config.dart';
import 'jpath_node.dart';
import 'jpath_parser.dart';

JPath buildJPath(List<JPathToken> jPathTokens) {
  List<JPathNode> nodeList = [];
  int index = 0;
  if (jPathTokens[0].type == JPathTokenType.keyword &&
      jPathTokens[0].value == "\$") {
    index = 1;
  }
  next() {
    index++;
  }

  current() {
    return jPathTokens[index];
  }

  bool hasNext() {
    return index < jPathTokens.length - 1;
  }

  while (index < jPathTokens.length) {
    if (current().type == JPathTokenType.keyword) {
      switch (current().value) {
        case ".":
          if (!hasNext()) {
            throw syntaxError(
                "after . should follow a attr name or * or a function",
                index: current().index);
          }
          next();
          if (current().type == JPathTokenType.id) {
            nodeList.add(AttrNode.one(current().value));
          } else if (current().type == JPathTokenType.keyword &&
              current().value == "*") {
            nodeList.add(SelectNode.all());
          } else if (current().type == JPathTokenType.function) {
            nodeList.add(FunctionNode(current().value));
          } else {
            throw syntaxError(
                "after . should follow a attr name or * or a function",
                index: current().index);
          }
          next();
          break;
        case "..":
          if (!hasNext()) {
            throw syntaxError("after .. should follow a attr name or *",
                index: current().index);
          }
          next();
          if (current().type == JPathTokenType.id) {
            nodeList.add(SearchNode(current().value));
          } else if (current().type == JPathTokenType.keyword &&
              current().value == "*") {
            nodeList.add(SearchNode.all());
          } else {
            throw syntaxError("after .. should follow a attr name",
                index: current().index);
          }
          next();
          break;
        case "[":
          if (!hasNext()) {
            throw syntaxError("after [ should follow a params list",
                index: current().index);
          }
          next();
          if (current().type == JPathTokenType.keyword &&
              current().value == "?") {
            next();
            if (current().type != JPathTokenType.expression) {
              throw syntaxError("after ? should follow a expression",
                  index: current().index);
            }
            nodeList.add(FilterNode(current()));
          } else if (current().type == JPathTokenType.intList) {
            nodeList.add(SelectNode.list(current().value));
          } else if (current().type == JPathTokenType.range) {
            nodeList.add(SelectNode.range(current().value));
          } else if (current().type == JPathTokenType.idList) {
            if(current().value.length < 1) {
              throw syntaxError("in [] at least have one index or attr");
            }
            if(current().value.length > 1) {
              nodeList.add(AttrNode.list(current().value));
            } else {
              nodeList.add(AttrNode.one(current().value.first));
            }

          } else if (current().type == JPathTokenType.keyword &&
              current().value == "*") {
            nodeList.add(SelectNode.all());
          } else if (current().type == JPathTokenType.expression) {
            nodeList.add(SelectNode.expression(current()));
          }
          next();
          if (current().type == JPathTokenType.keyword &&
              current().value == "]") {
            next();
          } else {
            throw syntaxError("[ should end with ]", index: current().index);
          }
      }
    }
  }
  return JPath(nodeList);
}

enum JPathType { root, current }

class JPath {
  JPathType type = JPathType.root;
  static JPathParser jPathParser = JPathParser();
  List<JPathNode> jPathNodeList;
  JPathNode rootNode;

  JPath(this.jPathNodeList, {this.type}) {
    rootNode = SimpleNode(JPathNodeTypes.root);
    var head = rootNode;
    jPathNodeList.forEach((node) {
      head.next = node;
      head = node;
    });
  }

  search(input) {
    if (input is String) {
      input = json.decode(input);
    }
    if (input is Map || input is List) {
      return _searchFromMap(input);
    }
    throw Exception("input should be a String or Map or List");
  }

  _searchFromMap(object) {
    return rootNode.search(object, object);
  }

  static JPath compile(String jPath) {
    return _compile(jPathParser.parseJPath(jPath));
  }

  static parse(String jPath) {
    return jPathParser.parseJPath(jPath);
  }

  static _compile(List tokens) {
    return buildJPath(tokens);
  }
}
