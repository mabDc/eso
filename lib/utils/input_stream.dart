import 'dart:convert';
import 'package:fast_gbk/fast_gbk.dart';

class InputStream {
  static String autoDecode(List<int> bytes) {
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

  static String decode(List<int> bytes, [String charset = "utf-8"]) {
    if (charset.toLowerCase().startsWith('gb')) return gbk.decode(bytes);
    return (Encoding.getByName(charset) ?? latin1).decode(bytes);
  }
}
