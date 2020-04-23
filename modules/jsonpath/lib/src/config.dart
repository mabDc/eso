enum JPathTokenType {
  keyword,
  id,
  int,
  double,
  string,
  regex,
  list,
  intList,
  idList,
  range,
  expression,
  path,
  function
}

class FunctionInfo {
  String name;
  int argNumber;
  Function func;

  invoke(input, args) {
    return func(input, args);
  }

  FunctionInfo(this.name, this.argNumber, this.func);
}

Map<String, FunctionInfo> functions = {
  "min": FunctionInfo("min", 0, (input, args) {
    if (!(input is List) || input.length < 1) {
      return null;
    }
    var min = double.parse(input[0]);
    input.forEach((item) {
      if (double.parse(item) < min) {
        min = item;
      }
    });
    return min;
  }),
  "max": FunctionInfo("min", 0, (input, args) {
    if (!(input is List) || input.length < 1) {
      return null;
    }
    var max = double.parse(input[0]);
    input.forEach((item) {
      if (double.parse(item) > max) {
        max = item;
      }
    });
    return max;
  }),
  "avg": FunctionInfo("min", 0, (input, args) {
    if (!(input is List) || input.length < 1) {
      return input;
    }
    double sum = 0;
    input.forEach((item) {
      sum += toNumber(item);
    });
    return sum / input.length;
  }),
  "length": FunctionInfo("min", 0, (list, args) {
    if (list is List) {
      return list.length;
    }
    return list.toString().length;
  }),
  "sum": FunctionInfo("min", 0, (input, args) {
    if (!(input is List) || input.length < 1) {
      return input;
    }
    double sum = 0;
    input.forEach((item) {
      sum += toNumber(item);
    });
    return sum;
  }),
  "substr": FunctionInfo("min", 2, (input, args) {
    if (!(input is String)) {
      return null;
    }
    return input.substring(args[0].toInt(), args[1].toInt());
  })
};

class OperatorInfo {
  int priority;
  OperatorType type;
  Function function;

  OperatorInfo(this.type, this.priority, this.function);
}

enum OperatorType { left, right, center, end }

double toNumber(value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (!(value is String)) {
    value = value.toString();
  }
  try {
    return double.parse(value);
  } catch (e) {
    return 0;
  }
}

Map<String, OperatorInfo> allOperators = {
  "in": OperatorInfo(OperatorType.center, 5, (lValue, rValue) {
    if (!(rValue is List)) {
      return false;
    }
    return rValue.contains(lValue);
  }),
  "nin": OperatorInfo(OperatorType.center, 5, (lValue, rValue) {
    if (!(rValue is List)) {
      return true;
    }
    return !rValue.contains(lValue);
  }),
  "subsetof": OperatorInfo(OperatorType.center, 5, (lValue, rValue) {
    if (!(rValue is List) || !(lValue is List)) {
      return false;
    }
    return lValue.every((v) => rValue.contains(v));
  }),
  "anyof": OperatorInfo(OperatorType.center, 5, (lValue, rValue) {
    if (!(rValue is List) || !(lValue is List)) {
      return false;
    }
    return lValue.any((v) => rValue.contains(v));
  }),
  "noneof": OperatorInfo(OperatorType.center, 5, (lValue, rValue) {
    if (!(rValue is List) || !(lValue is List)) {
      return false;
    }
    return lValue.every((v) => !rValue.contains(v));
  }),
  "size": OperatorInfo(OperatorType.center, 5, (lValue, size) {
    if (!(lValue is List)) {
      return false;
    }
    return lValue.length == size;
  }),
  "empty": OperatorInfo(OperatorType.right, 1, (lValue) {
    if (!(lValue is List)) {
      return true;
    }
    return lValue.isEmpty;
  }),
  "isNull": OperatorInfo(OperatorType.right, 1, (lValue) {
    return lValue == null;
  }),
  "&&": OperatorInfo(OperatorType.center, 6, (lValue, rValue) {
    return lValue && rValue;
  }),
  "||": OperatorInfo(OperatorType.center, 7, (lValue, rValue) {
    return lValue || rValue;
  }),
  ">": OperatorInfo(OperatorType.center, 4, (lValue, rValue) {
    return toNumber(lValue) > toNumber(rValue);
  }),
  "<": OperatorInfo(OperatorType.center, 4, (lValue, rValue) {
    return toNumber(lValue) < toNumber(rValue);
  }),
  ">=": OperatorInfo(OperatorType.center, 4, (lValue, rValue) {
    return toNumber(lValue) >= toNumber(rValue);
  }),
  "<=": OperatorInfo(OperatorType.center, 4, (lValue, rValue) {
    return toNumber(lValue) <= toNumber(rValue);
  }),
  "==": OperatorInfo(OperatorType.center, 4, (lValue, rValue) {
    if (lValue is int ||
        lValue is double ||
        rValue is int ||
        rValue is double) {
      return toNumber(lValue) == toNumber(rValue);
    }
    return lValue.toString() == rValue.toString();
  }),
  "=~": OperatorInfo(OperatorType.center, 4, (lvalue, RegExp reg) {
    return reg.hasMatch(lvalue);
  }),
  "!=": OperatorInfo(OperatorType.center, 4, (lValue, rValue) {
    if (lValue is int ||
        lValue is double ||
        rValue is int ||
        rValue is double) {
      return toNumber(lValue) != toNumber(rValue);
    }
    return lValue.toString() != rValue.toString();
  }),
  "+": OperatorInfo(OperatorType.center, 3, (lValue, rValue) {
    if ((lValue is int || lValue is double) &&
        (rValue is int || rValue is double)) {
      return lValue + rValue;
    }
    return lValue.toString() + rValue.toString();
  }),
  "-": OperatorInfo(OperatorType.center, 3, (lValue, rValue) {
    if ((lValue is int || lValue is double) &&
        (rValue is int || rValue is double)) {
      return lValue - rValue;
    }
    return 0;
  }),
  "*": OperatorInfo(OperatorType.center, 2, (lValue, rValue) {
    if ((lValue is int || lValue is double) &&
        (rValue is int || rValue is double)) {
      return lValue * rValue;
    }
    return 0;
  }),
  "/": OperatorInfo(OperatorType.center, 2, (lValue, rValue) {
    if ((lValue is int || lValue is double) &&
        (rValue is int || rValue is double)) {
      return lValue / rValue;
    }
    return 0;
  }),
  "!": OperatorInfo(OperatorType.left, 1, (rValue) {
    return !rValue;
  }),
  "##": OperatorInfo(OperatorType.center, 99, () {})
};

bool compute(OperatorInfo current, OperatorInfo next) {
  return current.priority <= next.priority;
}

bool isSingleOperator(OperatorInfo operatorInfo) {
  return operatorInfo.type != OperatorType.center;
}

class JPathToken {
  JPathTokenType type;
  int index;
  dynamic value;

  JPathToken(this.type, {this.value, this.index});

  @override
  String toString() {
    return "${type.index}--$value";
  }
}

bool isBlankChar(char) {
  if (char == ' ') {
    return true;
  }
  return false;
}

bool isNumber(code) {
  return (code >= "0".codeUnitAt(0) && code <= "9".codeUnitAt(0));
}

syntaxError(text, {index}) {
  return Exception("json path syntax error @$index: $text");
}
