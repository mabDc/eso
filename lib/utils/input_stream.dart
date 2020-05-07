import 'dart:convert';
import 'package:gbk2utf8/gbk2utf8.dart';

class InputStream {
  String autoDecode(List<int> bytes) {
    final str = latin1.decode(bytes);
    if (!str.contains('charset')) return str;
    try {
      final charset = RegExp("(?<=charset\s*\=\s*[\"']?)[^\"';\s]+")
          .firstMatch(str)
          .group(0);
      return decode(bytes, charset);
    } catch (e) {
      print(e);
      return str;
    }
  }

  String decode(List<int> bytes, [String charset = "utf-8"]) {
    if (charset.toLowerCase() == 'gbk') return gbk.decode(bytes);
    return (Encoding.getByName(charset) ?? latin1).decode(bytes);
  }
}
