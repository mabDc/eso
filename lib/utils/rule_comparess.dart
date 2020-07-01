import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:eso/database/rule.dart';

class RuleCompress {
  static const tag = "#";

  static Rule decompass(String text, [Rule rule]) {
    final lastIndex = text.lastIndexOf(tag);
    final gzipBytes = base64Decode(text.substring(lastIndex + 1));
    final jsonBytes = GZipDecoder().decodeBytes(gzipBytes);
    return Rule.fromJson(jsonDecode(utf8.decode(jsonBytes)), rule);
  }

  static String compass(Rule rule) {
    final json = jsonEncode(rule.toJson());
    final gzipBytes = GZipEncoder().encode(utf8.encode(json));
    return '$tag亦搜规则$tag${rule.name}@${rule.author}$tag${base64.encode(gzipBytes)}';
  }
}
