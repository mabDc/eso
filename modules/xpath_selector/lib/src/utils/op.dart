int opNum(int a, int b, String op) {
  switch (op) {
    case '+':
      return a + b;
    case '-':
      return a - b;
    case '*':
      return a * b;
    case '/':
      return a ~/ b;
    case '%':
      return a % b;
    default:
      throw 'Unknown operator: $op';
  }
}

bool opCompare(int a, int b, String op) {
  switch (op) {
    case '<':
      return a < b;
    case '<=':
      return a <= b;
    case '>':
      return a > b;
    case '>=':
      return a >= b;
    case '==':
      return a == b;
    case '=':
      return a == b;
    case '!=':
      return a != b;
    default:
      throw 'Unknown operator: $op';
  }
}

bool opString(String attr, String value, String op) {
  switch (op) {
    case '=':
      return attr == value;
    case '!=':
      return attr != value;
    case '~=':
      return attr.split(' ').contains(value);
    case '*=':
      return attr.contains(value);
    case '^=':
      return attr.startsWith(value);
    case r'$=':
      return attr.endsWith(value);
    default:
      throw 'Unknown operator: $op';
  }
}
