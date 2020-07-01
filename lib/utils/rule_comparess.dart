import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:eso/database/rule.dart';

class RuleCompress {
  static const tag = "eso://";

  static Rule decompass(String text, [Rule rule]) {
    final lastIndex = text.lastIndexOf("@");
    final gzipBytes = base64Decode(text.substring(tag.length, lastIndex));
    final jsonBytes = GZipDecoder().decodeBytes(gzipBytes);
    return Rule.fromJson(jsonDecode(utf8.decode(jsonBytes)), rule);
  }

  static String compass(Rule rule) {
    final json = jsonEncode(rule.toJson());
    final gzipBytes = GZipEncoder().encode(utf8.encode(json));
    return '$tag${base64.encode(gzipBytes)}@${rule.author}:${rule.name}';
  }
}
