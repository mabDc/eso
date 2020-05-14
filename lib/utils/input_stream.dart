import 'dart:convert';
import 'package:fast_gbk/fast_gbk.dart';

class InputStream {
  static String autoDecode(List<int> bytes) {
    final str = utf8.decode(bytes);
    if (!str.contains('charset')) return str;
    try {
      final charset =
          RegExp(r"""(?<=charset\s*\=\s*["']?)[^"';\s]+""").firstMatch(str).group(0);
      if (charset.contains(RegExp("utf-?8", caseSensitive: false))) {
        return str;
      }
      return decode(bytes, charset);
    } catch (e) {
      print(e);
      return str;
    }
  }

  static String decode(List<int> bytes, [String charset = "utf-8"]) {
    if (charset.toLowerCase().startsWith('gb')) return gbk.decode(bytes);
    return (Encoding.getByName(charset) ?? utf8).decode(bytes);
  }
}
