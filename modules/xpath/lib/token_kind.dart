class TokenKind {
  // Path Type
  static const int CHILD = 1; //     /
  static const int ROOT = 2; //       //
  static const int CURRENT = 3; //   .
  static const int PARENT = 4; //    ..

  // List position type
  static const int PLUS = 11; //               +
  static const int MINUS = 12; //              -
  static const int GREATER = 13; //            >
  static const int GREATER_OR_EQUALS = 14; //  >=
  static const int LESS = 15; //               <
  static const int LESS_OR_EQUALS = 16; //     <=

  static const Map<String, int> _POSITION_OPERATOR = {
    "+": PLUS,
    "-": MINUS,
    ">": GREATER,
    ">=": GREATER_OR_EQUALS,
    "<": LESS,
    "<=": LESS_OR_EQUALS
  };

  // Attribute match types:
  static const int EQUALS = 28; //           =
  static const int NOT_EQUALS = 29; //       !=
  static const int INCLUDES = 530; //        ~=
  static const int PREFIX_MATCH = 531; //    ^=
  static const int SUFFIX_MATCH = 532; //    $=
  static const int SUBSTRING_MATCH = 533; // *=
  static const int NO_MATCH = 534; // No operator.

  static const Map<String, int> _ATTR_OPERATOR = {
    "=": EQUALS,
    "!=": NOT_EQUALS,
    "~=": INCLUDES,
    "^=": PREFIX_MATCH,
    "\$=": SUFFIX_MATCH,
    "*=": SUBSTRING_MATCH
  };

  static const int NUM = 600; //      [0]
  static const int LAST = 601; //     last()
  static const int POSITION = 602; // position()


  ///string to position operator
  static int matchPositionOperator(String text) {
    return _POSITION_OPERATOR[text] ?? NO_MATCH;
  }

  ///string to attr operator
  static int matchAttrOperator(String text) {
    return _ATTR_OPERATOR[text] ?? NO_MATCH;
  }
}
