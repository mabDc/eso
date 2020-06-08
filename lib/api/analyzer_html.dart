import 'analyzer.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as parser;

class AnalyzerHtml implements Analyzer {
  Element _element;

  @override
  get content => _element;

  @override
  int get jsEngineId => null;

  @override
  AnalyzerHtml parse(content) {
    if (content is Element) {
      _element = content;
    } else if (content is Document) {
      _element = content.documentElement;
    } else if (content is String) {
      _element = parser.parse(content).documentElement;
    } else {
      _element = parser.parse('$content').documentElement;
    }
    return this;
  }

  String _getResult(Element e, String lastRule) {
    switch (lastRule) {
      case 'text':
        return e.text.trim();
      case 'textNodes':
        return e.children
            .map((e) => e.text)
            .where((e) => e.isNotEmpty)
            .join("\n")
            .trim(); // 适用于文字类正文 用换行符
      case 'id':
        return e.id;
      case 'outerHtml':
        return e.outerHtml.trim();
      case 'innerHtml':
      case 'html':
        return e.innerHtml.trim();
      default:
        final r = e.attributes[lastRule];
        return null == r ? '' : r.trim();
    }
  }

  @override
  List<String> getString(String rule) {
    return getStringList(rule);
  }

  @override
  List<String> getStringList(String rule) {
    if (!rule.contains('@')) {
      return <String>[_getResult(_element, rule)];
    }
    final result = <String>[];
    final split = rule.lastIndexOf("@");
    final lastRule = rule.substring(split + 1);
    final elementList = _element.querySelectorAll(rule.substring(0, split));
    for (var e in elementList) {
      final r = _getResult(e, lastRule);
      if (r.isNotEmpty) result.add(r);
    }
    return result;
  }

  @override
  List<Element> getElements(String rule) {
    return _element.querySelectorAll(rule);
  }
}
