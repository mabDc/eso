import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';
import 'package:html/dom.dart';
import 'analyzer.dart';

class AnalyzerJS implements Analyzer {
  String _content;
  int _jsEngineId;

  @override
  get content => _content;

  @override
  get jsEngineId => _jsEngineId;

  AnalyzerJS(int jsEngineId) {
    _jsEngineId = jsEngineId;
  }

  @override
  AnalyzerJS parse(content) {
    if (null != content) {
      if (content is Document) {
        _content = jsonEncode(content.outerHtml);
      } else if (content is Element) {
        _content = jsonEncode(content.outerHtml);
      } else {
        try {
          _content = jsonEncode(content);
        } catch (e) {
          print("error AnalyzeByJS jsonEncode: $e");
          _content = jsonEncode('$content');
        }
      }
    }
    return this;
  }

  @override
  Future<List> getElements(String rule) async {
    await FlutterJs.evaluate("result = $_content", _jsEngineId);
    return FlutterJs.evaluate(rule, _jsEngineId);
    // final result = await FlutterJs.evaluate(rule, _jsEngineId);
    // if (null == result) return <dynamic>[];
    // if (result is List) return result;
    // return <dynamic>[result];
  }

  @override
  Future<dynamic> getString(String rule) async {
    await FlutterJs.evaluate("result = $_content", _jsEngineId);
    return FlutterJs.evaluate(rule, _jsEngineId);
    final result = await FlutterJs.evaluate(rule, _jsEngineId);
    // if (null == result) return "";
    // if (result is List) {
    //   return result
    //       .where((r) => null != r)
    //       .map((r) => '$r'.trim())
    //       .where((r) => r.isNotEmpty)
    //       .join(", ");
    // }
    // return '$result';
  }

  @override
  Future<List<String>> getStringList(String rule) async {
    await FlutterJs.evaluate("result = $_content", _jsEngineId);
    return FlutterJs.evaluate(rule, _jsEngineId);
    final result = await FlutterJs.evaluate(rule, _jsEngineId);
    // if (null == result) return <String>[];
    // if (result is List) {
    //   return result
    //       .where((r) => null != r)
    //       .map((r) => '$r'.trim())
    //       .where((r) => r.isNotEmpty);
    // }
    // return <String>['$result'];
  }
}
