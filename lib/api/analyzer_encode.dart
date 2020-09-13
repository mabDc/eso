import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:html/dom.dart';

import 'analyzer.dart';

class AnalyzerEncode implements Analyzer {
  String _content;

  @override
  AnalyzerEncode parse(content) {
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
      var _data = utf8.encode(_content);
      return base64Encode(_data);
    } else if (rule.startsWith("md5")) {
      var _data = utf8.encode(_content);
      return md5.convert(_data).toString();
    } else if (rule.startsWith("utf8")) {
      var _data = utf8.encode(_content);
      return String.fromCharCodes(_data);
    } else if (rule.startsWith("gbk")) {
      var _data = gbk.encoder.convert(rule);
      return String.fromCharCodes(_data);
    }
    return _content;
  }

  @override
  String getStringList(String rule) {
    return getString(rule);
  }
}
