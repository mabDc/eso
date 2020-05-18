import 'analyzer.dart';
import 'package:jsonpath/json_path.dart';

class AnalyzerJSonPath implements Analyzer {
  final _jsonRulePattern = RegExp(r"\{(\$\.[^\}]+)\}");
  dynamic _ctx;

  @override
  get content => _ctx;

  @override
  int get jsEngineId => null;

  @override
  AnalyzerJSonPath parse(content) {
    _ctx = content;
    return this;
  }

  @override
  dynamic getElements(String rule) {
    return JPath.compile(rule).search(_ctx);
  }

  @override
  dynamic getString(String rule) {
    if (rule.contains("{\$.")) {
      return rule.splitMapJoin(
        _jsonRulePattern,
        onMatch: (match) => getString(match.group(1)),
        onNonMatch: (nonMatch) => nonMatch,
      );
    }

    return JPath.compile(rule).search(_ctx);
  }

  @override
  dynamic getStringList(String rule) {
    return JPath.compile(rule).search(_ctx);
  }
}
