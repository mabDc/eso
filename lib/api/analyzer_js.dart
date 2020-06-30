import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';
import 'package:html/dom.dart';
import 'analyzer.dart';

class AnalyzerJS implements Analyzer {
  String _content;
  int _jsEngineId;

  @override
  get jsEngineId => _jsEngineId;

  AnalyzerJS(int jsEngineId) {
    _jsEngineId = jsEngineId;
  }

  @override
  AnalyzerJS parse(content) {
    if (content is Document) {
      _content = jsonEncode(content.outerHtml);
    } else if (content is Element) {
      _content = jsonEncode(content.outerHtml);
    } else if (content is List<Element>) {
      _content = jsonEncode(content.map((e) => e.outerHtml).join("\n"));
    } else {
      try {
        _content = jsonEncode(content);
      } catch (e) {
        print("error AnalyzeByJS jsonEncode: $e");
        _content = jsonEncode('$content');
      }
    }
    return this;
  }

  @override
  Future<dynamic> getElements(String rule) async {
    return FlutterJs.evaluate("result = $_content;$rule;", _jsEngineId);
  }

  @override
  Future<dynamic> getString(String rule) async {
    return FlutterJs.evaluate("result = $_content;$rule;", _jsEngineId);
  }

  @override
  Future<dynamic> getStringList(String rule) async {
    return FlutterJs.evaluate("result = $_content;$rule;", _jsEngineId);
  }
}
