import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:eso/database/rule.dart';

class RuleCompress {
  static const tag = "eso://";

  static Rule decompass(String text, [Rule rule]) {
    return Rule.fromJson(jsonDecode(decompassString(text, rule)), rule);
  }

  static String decompassString(String text, [Rule rule]) {
    final lastIndex = text.lastIndexOf("@");
    final gzipBytes = base64Decode(text.substring(lastIndex + 1));
    final jsonBytes = GZipDecoder().decodeBytes(gzipBytes);
    return utf8.decode(jsonBytes);
  }

  static String compass(Rule rule) {
    final json = jsonEncode(rule.toJson());
    final gzipBytes = GZipEncoder().encode(utf8.encode(json));
    return '$tag${rule.author}:${rule.name}@${base64.encode(gzipBytes)}';
  }

  // static String manyCompass(List<Rule> rules){
  //   final json = jsonEncode(rules.map((rule) => rule.toJson()).toList());
  //   final gzipBytes = GZipEncoder().encode(utf8.encode(json));
  //   return '$tag多规则:${rules.length}@${base64.encode(gzipBytes)}';
  // }
  static String manyCompass(List<Rule> rules) {
    return jsonEncode(rules.map((rule) => compass(rule)).toList());
  }
}
