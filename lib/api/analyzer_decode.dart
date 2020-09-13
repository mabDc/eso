import 'dart:convert';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:html/dom.dart';

import 'analyzer.dart';

class AnalyzerDecode implements Analyzer {
  String _content;

  @override
  AnalyzerDecode parse(content) {
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
    if (rule.startsWith("base64")) {
      var _text = _content.trim().replaceAll("\n", "");
      if (_text.endsWith('"')) _text = _text.substring(0, _text.length - 1);
      final _data = base64Decode(_text);
      return utf8.decode(_data);
    } else if (rule.startsWith("gbk")) {
      final _data = utf8.encode(_content);
      return gbk.decoder.convert(_data);
    } else if (rule.startsWith("utf8")) {
      return utf8.decode(_content.codeUnits);
    }
    return _content;
  }

  @override
  String getStringList(String rule) {
    return getString(rule);
  }
}
