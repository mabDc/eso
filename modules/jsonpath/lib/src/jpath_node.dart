import 'config.dart';
import 'expression.dart';

enum Count { one, some, all, none }

enum JPathNodeTypes {
  attr,
  attrAll,
  search,
  searchAll,
  select,
  filter,
  function,
  root
}

enum DataTypes { string, number, list, object }

abstract class JPathNode {
  JPathNodeTypes type;
  JPathNode next;

  JPathNode(this.type);

  @override
  String toString() {
    return type.toString();
  }

  dynamic search(input, root) {
    var result = _search(input, root);
    if (next != null) {
      result = _next(result, root);
    }
    return result;
  }

  dynamic _search(input, root);

  dynamic _next(input, root);
}

class SimpleNode extends JPathNode {
  SimpleNode(JPathNodeTypes type) : super(type);

  @override
  _next(input, root) {
    return next.search(input, root);
  }

  @override
  _search(input, root) {
    return input;
  }
}

class AttrNode extends SimpleNode {
  dynamic attrs;
  Count resultCount;

  AttrNode.one(attrs) : super(JPathNodeTypes.attr) {
    if (!(attrs is String)) {
      throw Exception("select some attr need a attr");
    }
    this.attrs = attrs;
    resultCount = Count.one;
  }

  AttrNode.list(attrs) : super(JPathNodeTypes.attr) {
    if (!(attrs is List)) {
      throw Exception("select some attr need a attr list");
    }
    this.attrs = attrs;
    resultCount = Count.some;
  }

  @override
  _search(input, root) {
    if (input is List) {
      List result = [];
      if (resultCount == Count.one) {
        for(var item in input) {
          if(item is Map) {
            result.add(item[attrs]);
          }
        }
        return result;
      } else if (resultCount == Count.all) {
        return input;
      }
      for(var item in input) {
        if(item is Map) {
          var _item = {};
          for(var attr in attrs) {
            _item[attr] = item[attr];
          }
          result.add(_item);
        }
      }
      return result;
    } else if (input is Map) {
      if (resultCount == Count.one) {
        return input[attrs];
      }
      if (resultCount == Count.all) {
        return input.values.toList();
      }
      var value = {};
      attrs.forEach((attr) {
        value[attr] = input[attr];
      });
      return value;
    }
  }
}

class SearchNode extends SimpleNode {
  String target;
  Count targetCount = Count.one;

  SearchNode(this.target) : super(JPathNodeTypes.search) {
    targetCount = Count.none;
  }

  SearchNode.all() : super(JPathNodeTypes.search) {
    targetCount = Count.all;
  }

  _searchAll(input) {
    List result = [];
    if (input is List) {
      result.addAll(input);
      input.forEach((item) {
        result.addAll(_searchAll(item));
      });
      return result;
    } else if (input is Map) {
      result.addAll(input.values.toList());
      input.values.forEach((item) {
        result.addAll(_searchAll(item));
      });
      return result;
    }
    return [input];
  }

  _searchOne(input, target) {
    List result = [];
    if (input is List) {
      input.forEach((item) {
        result.addAll(_searchOne(item, target));
      });
    } else if (input is Map) {
      if (input.containsKey(target)) {
        result.add(input[target]);
      }
      input.values.forEach((item) {
        result.addAll(_searchOne(item, target));
      });
      return result;
    }
    return result;
  }

  @override
  _search(input, root) {
    if (targetCount == Count.all) {
      return _searchAll(input);
    }
    return _searchOne(input, target);
  }

  @override
  _next(input, root) {
    var result = [];
    input.forEach((item) {
      var _result = next.search(item, root);
      result.add(_result);
    });
    return result;
  }
}

class FilterNode extends SimpleNode {
  Expression expression;

  FilterNode(expressionToken) : super(JPathNodeTypes.filter) {
    expression = buildExpression(expressionToken);
  }

  @override
  _search(input, root) {
    List result = [];
    for(var item in input) {
      if(expression.apply(item, root)){
        result.add(item);
      }
    }
    return result;
  }
}

enum SelectNodeType { all, expression, range, list, one }

class SelectNode extends SimpleNode {
  SelectNodeType selectType;
  Expression expression;
  int selectIndex;
  List selectIndexList;
  List selectRange;

  SelectNode.all() : super(JPathNodeTypes.select) {
    selectType = SelectNodeType.all;
  }

  SelectNode.expression(token) : super(JPathNodeTypes.select) {
    selectType = SelectNodeType.expression;
    expression = buildExpression(token);
  }

  SelectNode.range(range) : super(JPathNodeTypes.select) {
    if (!(range is List) || range.length < 3) {
      throw Exception("select by list need at least 3 number");
    }
    selectType = SelectNodeType.range;
    this.selectRange = range;
  }

  SelectNode.list(list) : super(JPathNodeTypes.select) {
    if (!(list is List)) {
      throw Exception("select by index need a index list");
    }
    if (list.length < 1) {
      throw Exception("select by index need at least a index");
    }
    if (list.length == 1) {
      selectType = SelectNodeType.one;
      selectIndex = list[0];
    } else {
      selectType = SelectNodeType.list;
      selectIndexList = list;
    }
  }

  _selectByExpression(input, root) {
    var result = expression.apply(input, root).toString();
    if(input is Map) {
      return input[result];
    } else if(input is List) {
      int index = double.parse(result).toInt();
      if(index < input.length){
        return input[index];
      }
    }
    return null;
  }

  _selectAll(input) {
    if (input is List) {
      return input;
    } else if (input is Map) {
      return input.values.toList();
    }
    throw Exception("only object or list can apply *, but found $input");
  }

  _selectOne(input) {
    if (!(input is List)) {
      throw Exception("only list can select by index, but found $input");
    }
    var _selectIndex = selectIndex;
    if (_selectIndex < 0) {
      _selectIndex = _selectIndex + input.length;
    }
    if (_selectIndex < 0 || _selectIndex >= input.length) {
      return null;
    }
    return input[_selectIndex];
  }

  _selectByList(input) {
    if (!(input is List)) {
      throw Exception("only list can select by index, but found $input");
    }
    int length = input.length;
    List result = [];
    for (int index in selectIndexList) {
      if (index < 0) {
        index = index + length;
      }
      if (index < 0 || index >= input.length) {
        continue;
      }
      result.add(input[index]);
    }
    return result;
  }

  _selectByRange(input) {
    int start = selectRange[0];
    int end = selectRange[1];
    int step = selectRange[2];
    if (step == 0) {
      throw throw Exception("select items from list range step can not be 0");
    }
    if (start != null) {
      if (start < 0) {
        start = start + input.length;
      }
      if (start < 0) {
        start = 0;
      }
      if (start >= input.length) {
        start = input.length - 1;
      }
    }
    if (end != null) {
      if (end < 0) {
        end = end + input.length;
      }
      if (end < 0) {
        end = 0;
      }
      if (end >= input.length) {
        end = input.length - 1;
      }
    }
    List result = [];
    if (step > 0) {
      for (int index = (start ?? 0);
          index < (end ?? input.length);
          index += step) {
        result.add(input[index]);
      }
    } else {
      for (int index = (start ?? input.length - 1);
          index > (end ?? -1);
          index += step) {
        result.add(input[index]);
      }
    }
    return result;
  }

  @override
  _search(input, root) {
    switch (selectType) {
      case SelectNodeType.all:
        return _selectAll(input);
      case SelectNodeType.expression:
        return _selectByExpression(input, root);
      case SelectNodeType.range:
        return _selectByRange(input);
      case SelectNodeType.list:
        return _selectByList(input);
        break;
      case SelectNodeType.one:
        return _selectOne(input);
    }
  }

  @override
  _next(input, root) {
    if (input == null) {
      return null;
    }
    if (selectType == SelectNodeType.one || !(input is List)) {
      return next.search(input, root);
    }
    var result = [];
    input.forEach((item) {
      var _result = next.search(item, root);
      result.add(_result);
    });
    return result;
  }
}

class FunctionNode extends SimpleNode {
  String funcName;
  FunctionInfo function;
  List args;

  FunctionNode(funcInfo) : super(JPathNodeTypes.function) {
    args = funcInfo["args"] ?? [];
    funcName = funcInfo["name"];
    function = functions[funcName];
    if(function == null) {
      throw Exception("$funcName is not a function");
    }
    if(args.length != function.argNumber) {
      throw Exception("function $funcName need ${function.argNumber} arg, but found ${args.length}");
    }
  }
  @override
  _search(input, root) {
    // TODO: implement _search
    return function.invoke(input, args);
  }
}
