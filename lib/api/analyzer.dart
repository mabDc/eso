import 'dart:async';

abstract class Analyzer {
  // dynamic _content;
  // dynamic get content => _content;
  // int _id;
  // int get id => _id;
  // Analyzer(dynamic content, [int jsEngineId]);
  Analyzer parse(dynamic content);
  FutureOr getString(String rule);
  FutureOr getStringList(String rule);
  FutureOr getElements(String rule);
}
