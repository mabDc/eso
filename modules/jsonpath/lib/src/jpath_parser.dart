import 'config.dart';

enum ParseState {
  init,
  start,
  dot,
  doubleDot,
  star,
  id,
  lBracket,
  expressionStart,
  quotesId,
  root,
}

enum ExpressionState {
  pathStart,
  less,
  more,
  equal,
  and,
  or,
  not,
  rParentheses
}

class JPathParser {
  String jPath;
  int currentIndex = 0;
  ParseState status = ParseState.init;
  List<JPathToken> tokenList = [];

  JPathParser();

  parseJPath(String _jPath) {
    currentIndex = 0;
    jPath = _jPath;
    tokenList = [makeToken(JPathTokenType.keyword, "\$")];
    if (jPath == null || jPath == "" || jPath == "\$") {
      return tokenList;
    }

    if (!jPath.startsWith("\$")) {
      jPath = "\$." + jPath;
    }

    next();
    status = ParseState.start;
    var path = parsePath();
    tokenList.addAll(path);
    return tokenList;
  }

  get end {
    return currentIndex >= jPath.length;
  }

  get current {
    return jPath[currentIndex];
  }

  get currentCode {
    return jPath.codeUnitAt(currentIndex);
  }

  next() {
    currentIndex++;
  }

  skipBlank() {
    while (isBlankChar(current)) {
      next();
    }
  }

  JPathToken makeToken(type, value) {
    return JPathToken(type, value: value, index: currentIndex);
  }

  _notImplementError(text) {
    return Exception("not implement $text @$currentIndex");
  }

  _syntaxError(text, {index}) {
    return Exception("json path syntax error @${index ?? currentIndex}: $text");
  }

  parseId({String endChars = "."}) {
    bool backslash = false;
    String result = "";
    int startIndex = currentIndex;
    while (true) {
      if (end) {
        return result;
      }
      if (backslash) {
        result += current;
        next();
        backslash = false;
      } else {
        if (endChars.contains(current)) {
          return result;
        }
        if (current == "\\") {
          backslash = true;
          next();
        } else {
          result += current;
          next();
        }
      }
    }
  }

  parseInt() {
    String num = "";
    if (current == '-') {
      num = "-";
      next();
    }
    while (
    currentCode >= "0".codeUnitAt(0) && currentCode <= "9".codeUnitAt(0)) {
      num += current;
      next();
    }
    if (num == "" || num == "-") {
      return null;
    }
    return int.parse(num);
  }

  parseRegex() {
    return parseId(endChars: "/");
  }

  parseDouble() {
    int startIndex = currentIndex;
    String number = current;
    next();

    while (".0123456789".contains(current)) {
      number += current;
      next();
    }

    try {
      return double.parse(number);
    } catch (e) {
      throw _syntaxError("$number is not a double", index: startIndex);
    }
  }

  parseList({endChars = "]"}) {
    skipBlank();
    List list = [];
    while ("'\"-.0123456789".contains(current)) {
      if (end) {
        return;
      }
      if (current == "'" || current == "\"") {
        var end = current;
        next();
        var id = parseId(endChars: end);
        if (current == end) {
          next();
        } else {
          throw _syntaxError("expect a $end");
        }
        list.add(id);
      } else if ("-.0123456789".contains(current)) {
        var number = parseDouble();
        list.add(number);
      }

      skipBlank();
      if (current == ',') {
        next();
        skipBlank();
      } else if (endChars.contains(current)) {
        return list;
      } else {
        throw _syntaxError("expect a $endChars");
      }
    }
  }

  parseExpression() {
    skipBlank();

    if (current != "(") {
      throw _syntaxError("except a (");
    }
    next();
    skipBlank();
    int parenthesesNum = 1;
    List expressionTokens = [];
    ExpressionState expressionState = ExpressionState.pathStart;
    while (true) {
      if (parenthesesNum == 0) {
        return makeToken(JPathTokenType.expression, expressionTokens);
      }
      switch (expressionState) {
        case ExpressionState.pathStart:
          if (current == "\$") {
            next();
            var path = parsePath(endChars: " <=!>&|)");
            expressionTokens.add(
                makeToken(JPathTokenType.path, {"type": "\$", "path": path}));
          } else if (current == "@") {
            next();
            var path = parsePath(endChars: " <=!>&|)");
            expressionTokens.add(
                makeToken(JPathTokenType.path, {"type": "@", "path": path}));
          } else if (current == "(") {
            var expression = parseExpression();
            expressionTokens.add(expression);
          } else if (current == "'" || current == "\"") {
            var end = current;
            next();
            var id = parseId(endChars: end);
            expressionTokens.add(makeToken(JPathTokenType.string, id));
            if (current != end) {
              throw _syntaxError("except a $end");
            }
            next();
          } else if (current == "/") {
            next();
            var regex = parseRegex();
            if (current != "/") {
              throw _syntaxError("except a /");
            }
            next();
            if (current == "i") {
              next();
              expressionTokens.add(makeToken(
                  JPathTokenType.regex, {"value": regex, "ignoreCase": true}));
            } else {
              expressionTokens.add(makeToken(
                  JPathTokenType.regex, {"value": regex, "ignoreCase": false}));
            }
          } else if (current == "[") {
            next();
            var list = parseList();
            expressionTokens.add(makeToken(JPathTokenType.list, list));
            if (current == "]") {
              next();
            } else {
              throw _syntaxError("except a ]");
            }
          } else if (".-0123456789".contains(current)) {
            var num = parseDouble();
            expressionTokens.add(makeToken(JPathTokenType.double, num));
          } else if (current == "!") {
            expressionTokens.add(makeToken(JPathTokenType.keyword, '!'));
            next();
            break;
          } else {
            throw _syntaxError("except a @ or a \$");
          }

          skipBlank();

          String id = parseId(endChars: " <=>!&|)+-*/");
          bool continueParse = false;

          if (id == null || id == "") {
            continueParse = true;
          } else {
            if (allOperators.containsKey(id)) {
              expressionTokens.add(makeToken(JPathTokenType.keyword, id));
              if (allOperators[id].type == OperatorType.right) {
                continueParse = true;
              }
            } else {
              throw _syntaxError("$id is not a operator");
            }
          }

          skipBlank();

          if (continueParse) {
            switch (current) {
              case "<":
                expressionState = ExpressionState.less;
                next();
                break;
              case "=":
                expressionState = ExpressionState.equal;
                next();
                break;
              case ">":
                expressionState = ExpressionState.more;
                next();
                break;
              case "!":
                expressionState = ExpressionState.not;
                next();
                break;
              case "&":
                expressionState = ExpressionState.and;
                next();
                break;
              case "|":
                expressionState = ExpressionState.or;
                next();
                break;
              case ")":
                expressionState = ExpressionState.rParentheses;
                next();
                break;
              case "+":
              case "-":
              case "*":
              case "/":
                expressionTokens
                    .add(makeToken(JPathTokenType.keyword, current));
                next();
                skipBlank();
                expressionState = ExpressionState.pathStart;
                break;
              default:
                break;
            }
          }
          break;
        case ExpressionState.less:
          if (current == "=") {
            next();
            expressionTokens.add(makeToken(JPathTokenType.keyword, "<="));
          } else {
            expressionTokens.add(makeToken(JPathTokenType.keyword, "<"));
          }
          skipBlank();
          expressionState = ExpressionState.pathStart;
          break;
        case ExpressionState.more:
          if (current == "=") {
            next();
            expressionTokens.add(makeToken(JPathTokenType.keyword, ">="));
          } else {
            expressionTokens.add(makeToken(JPathTokenType.keyword, ">"));
          }
          skipBlank();
          expressionState = ExpressionState.pathStart;
          break;
        case ExpressionState.equal:
          if (current == "=") {
            next();
            expressionTokens.add(makeToken(JPathTokenType.keyword, "=="));
          } else if (current == "~") {
            next();
            expressionTokens.add(makeToken(JPathTokenType.keyword, "=~"));
          }
          skipBlank();
          expressionState = ExpressionState.pathStart;
          break;
        case ExpressionState.and:
          if (current == "&") {
            next();
            expressionTokens.add(makeToken(JPathTokenType.keyword, "&&"));
          } else {
            throw _syntaxError("except a & \$");
          }
          skipBlank();
          expressionState = ExpressionState.pathStart;
          break;
        case ExpressionState.or:
          if (current == "|") {
            next();
            expressionTokens.add(makeToken(JPathTokenType.keyword, "||"));
          } else {
            throw _syntaxError("except a | \$");
          }
          skipBlank();
          expressionState = ExpressionState.pathStart;
          break;
        case ExpressionState.not:
          if (current == "=") {
            next();
            expressionTokens.add(makeToken(JPathTokenType.keyword, "!="));
          } else {
            throw _syntaxError("except a = \$");
          }
          skipBlank();
          expressionState = ExpressionState.pathStart;
          break;
        case ExpressionState.rParentheses:
          return makeToken(JPathTokenType.expression, expressionTokens);
      }
    }
  }

  parsePath({String endChars = ""}) {
    status = ParseState.start;
    List<JPathToken> tokenList = [];
    while (true) {
      if (end) {
        break;
      }
      if (endChars.contains(current)) {
        return tokenList;
      }
      switch (status) {
        case ParseState.init:
          break;
        case ParseState.start:
          if (current == ".") {
            status = ParseState.dot;
            next();
          } else if (current == "[") {
            status = ParseState.lBracket;
            tokenList.add(makeToken(JPathTokenType.keyword, "["));
            next();
          }
          break;
        case ParseState.dot:
          if (current == ".") {
            tokenList.add(makeToken(JPathTokenType.keyword, ".."));
            next();
          } else {
            tokenList.add(makeToken(JPathTokenType.keyword, "."));
          }
          if (current == "*") {
            status = ParseState.start;
            tokenList.add(makeToken(JPathTokenType.keyword, "*"));
            next();
          } else {
            status = ParseState.id;
          }
          break;
        case ParseState.doubleDot:
        // TODO: Handle this case.
          break;
        case ParseState.star:
        // TODO: Handle this case.
          break;
        case ParseState.id:
          var id = parseId(endChars: ".[(" + endChars);
          if (id == null || id == "") {
            throw _syntaxError("attr shouldn't null");
          }
          if (!end && current == "(") {
            if (!functions.containsKey(id)) {
              throw _syntaxError("$id is not a function");
            }
            next();
            skipBlank();
            if (current == ")") {
              tokenList.add(makeToken(JPathTokenType.function, {"name": id}));
              next();
              status = ParseState.start;
            } else {
              var args = parseList(endChars: ")");
              if (current != ")") {
                throw _syntaxError("except a )");
              }
              next();
              tokenList.add(makeToken(
                  JPathTokenType.function, {"name": id, "args": args}));
              status = ParseState.start;
            }
          } else {
            tokenList.add(makeToken(JPathTokenType.id, id));
            status = ParseState.start;
          }
          break;
        case ParseState.lBracket:
          skipBlank();
          if (current == "?" || current == "(") {
            if (current == "?") {
              next();
              tokenList.add(makeToken(JPathTokenType.keyword, "?"));
            }
            status = ParseState.expressionStart;
            var expression = parseExpression();
            tokenList.add(expression);
            skipBlank();
            if (current == "]") {
              next();
              status = ParseState.start;
              tokenList.add(makeToken(JPathTokenType.keyword, "]"));
            } else {
              throw _syntaxError("except a ]");
            }
            break;
          }

          if (!"012345679-:'\"*".contains(current)) {
            throw _syntaxError("$current shouldn't here");
          }

          if (current == "*") {
            tokenList.add(makeToken(JPathTokenType.keyword, "*"));
            next();
          } else if (current == '\'' || current == '"') {
            var ids = [];
            while (current == '\'' || current == '"') {
              var first = current;
              next();
              var id = parseId(endChars: first);
              if (id == null || id == "") {
                throw _syntaxError("id is null");
              }
              ids.add(id);
              next();
              skipBlank();
              if (current == ",") {
                next();
                skipBlank();
              } else {
                break;
              }
            }
            tokenList.add(makeToken(JPathTokenType.idList, ids));
          } else {
            int firstNum;
            if (current == "-" || isNumber(currentCode)) {
              firstNum = parseInt();
              if (num == null) {
                throw _syntaxError("number is null");
              }
            }
            skipBlank();
            if (current == ":") {
              next();
              skipBlank();
              var endNum = parseInt();
              skipBlank();
              int step = 1;
              if (current == ":") {
                next();
                skipBlank();
                step = parseInt() ?? 1;
              }
              tokenList.add(
                  makeToken(JPathTokenType.range, [firstNum, endNum, step]));
            } else if (current == "," || current == "]") {
              var intList = [firstNum];
              while (current == ",") {
                next();
                skipBlank();
                int num = parseInt();
                if (num == null) {
                  throw _syntaxError("number is null");
                }
                intList.add(num);
                skipBlank();
              }
              tokenList.add(makeToken(JPathTokenType.intList, intList));
            }
          }

          skipBlank();
          if (current == ']') {
            tokenList.add(makeToken(JPathTokenType.keyword, ']'));
            next();
            status = ParseState.start;
            break;
          } else {
            throw _syntaxError("] not found");
          }
          break;
        case ParseState.expressionStart:
        // TODO: Handle this case.
          throw _notImplementError("expression");
        case ParseState.quotesId:
        // TODO: Handle this case.
          break;
        case ParseState.root:
        // TODO: Handle this case.
          break;
      }
    }
    return tokenList;
  }
}
