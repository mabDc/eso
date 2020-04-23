import 'config.dart';
import 'jpath.dart';

enum ExpressionBuildState { start, exp, one, two, three, and, or }
enum ExpressionType { one, left, right, center }

Expression buildExpression(JPathToken token) {
  if (token.type != JPathTokenType.expression) {
    throw syntaxError("${token.value} is not a expression");
  }
  List expression = token.value;
  while (expression is List && expression.length == 1) {
    if (expression[0].value is List) {
      expression = expression[0].value;
    } else {
      break;
    }
  }
  if (expression is JPathToken) {
    expression = [expression];
  }
  int index = 0;
  next() {
    index++;
  }

  current() {
    return expression[index];
  }

  top(List list) {
    if (list.length > 0) {
      return list[list.length - 1];
    }
  }

  pop(List list) {
    return list.removeLast();
  }

  push(List list, element) {
    list.add(element);
  }

  expression.add(JPathToken(JPathTokenType.keyword,
      value: "##", index: expression.last.index));
  var dataList = [];
  var opList = [];
  while (index < expression.length) {
    if (current().type == JPathTokenType.keyword) {
      if (!allOperators.containsKey(current().value)) {
        throw syntaxError("${current().value} is not a operator",
            index: current().index);
      }
      OperatorInfo operatorInfo = allOperators[current().value];
      if (operatorInfo.type != OperatorType.left && dataList.isEmpty) {
        throw syntaxError("operator ${current().value} need a left operand",
            index: current().index);
      }
      if (operatorInfo.type == OperatorType.right) {
        push(dataList, Expression.right(pop(dataList), current().value));
      } else if (operatorInfo.type == OperatorType.left) {
        push(opList, current().value);
      } else {
        if (opList.isNotEmpty) {
          OperatorInfo topOp = allOperators[top(opList)];
          if (topOp.priority <= operatorInfo.priority) {
            if (dataList.length > 1) {
              var r = pop(dataList);
              var l = pop(dataList);
              push(dataList, Expression.center(l, pop(opList), r));
              continue;
            } else {
              throw syntaxError("operator ${current().value} need two operand",
                  index: current().index);
            }
          }
        }
        push(opList, current().value);
      }
    } else {
      var c;
      if (current().type == JPathTokenType.expression) {
        c = buildExpression(current());
      } else {
        c = current();
      }
      if (opList.isNotEmpty) {
        OperatorInfo topOp = allOperators[top(opList)];
        if (topOp.type == OperatorType.left) {
          push(dataList, Expression.left(pop(opList), c));
        } else {
          push(dataList, c);
        }
      } else {
        push(dataList, c);
      }
    }
    next();
  }
  var _first = dataList.first;
  if(_first is JPathToken) {
    return Expression.one(_first);
  }
  return dataList.first;
}

class Expression {
  ExpressionType type;
  Function opFunction;

  dynamic lValue;
  dynamic rValue;
  dynamic op;

  apply(current, root) {
    var l = _calcValue(lValue, current, root);
    var r = _calcValue(rValue, current, root);
    if (type == ExpressionType.center) {
      var result = opFunction(l, r);
      return result;
    } else if (type == ExpressionType.left) {
      return opFunction(r);
    } else if (type == ExpressionType.right) {
      return opFunction(l);
    } else {
      return l;
    }
  }

  _calcValue(value, current, root) {
    if (value is Expression) {
      return value.apply(current, root);
    }

    if (value is JPath) {
      if (value.type == JPathType.root) {
        return value.search(root);
      }
      return value.search(current);
    }

    return value;
  }

  _buildValue(value) {
    if (value.type == JPathTokenType.path) {
      var type = value.value["type"] == "@" ? JPathType.current : JPathType.root;
      var result = buildJPath(value.value["path"]);
      result.type = type;
      return result;
    } else if(value.type == JPathTokenType.regex){
      return RegExp(value.value["value"], caseSensitive: !value.value["ignoreCase"]);
    }
    return value.value;
  }

  Expression.one(l) {
    if (!(l is JPathToken)) {
      throw syntaxError("$l");
    }
    if (l.type != JPathTokenType.path) {
      throw syntaxError("only path can allow no operator", index: l.index);
    }
    if (l.value["type"] == "\$") {
      throw syntaxError("\$ should replace by @", index: l.index);
    }
    var _type = l.value["type"];
    lValue = buildJPath(l.value["path"]);
    lValue.type = _type == "\$" ? JPathType.root : JPathType.current;
    type = ExpressionType.one;
  }
  Expression.left(o, r) {
    opFunction = allOperators[o].function;
    if (o == "!") {
      if (!(r is Expression)) {
        r = Expression.one(r);
      }
    } else {}

    op = o;
    rValue = r;
    type = ExpressionType.left;
  }

  Expression.right(l, o) {
    opFunction = allOperators[o].function;
    lValue = l;
    op = o;
    type = ExpressionType.right;
  }

  Expression.center(l, o, r) {
    opFunction = allOperators[o].function;
    type = ExpressionType.center;
    if (o == "&&" || o == "||") {
      if (!(l is Expression)) {
        l = Expression.one(l);
      }
      if (!(r is Expression)) {
        r = Expression.one(r);
      }
    }
    if (l is JPathToken) {
      l = _buildValue(l);
    }
    if (r is JPathToken) {
      r = _buildValue(r);
    }
    lValue = l;
    op = o;
    rValue = r;
  }

  toString() {
    return "($lValue $op $rValue)";
  }
}
