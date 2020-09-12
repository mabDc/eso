import 'dart:convert';
import 'package:html/dom.dart';

import 'analyzer.dart';

class AnalyzerMatch implements Analyzer {
  String _content;

  @override
  AnalyzerMatch parse(content) {
    if (content is List || content is Map) {
      _content = jsonEncode(content);
    } else if (content is Element) {
      _content = content.outerHtml;
    } else if (content is List<Element>) {
      _content = content.map((e) => e.outerHtml).join("\n");
    } else {
      _content = '$content';
    }
    return this;
  }

  @override
  String getElements(String rule) {
    return getString(rule);
  }

  @override
  String getString(String rule) {
    if (null == rule || rule.isEmpty) return "";
    final r = rule.split("@@");
    final group = r.length > 1 ? int.parse(r[1]) : 0;
    return RegExp(r[0]).allMatches(_content).map((m) => m.group(group)).join("  ");
  }

  @override
  String getStringList(String rule) {
    return getString(rule);
  }
}
