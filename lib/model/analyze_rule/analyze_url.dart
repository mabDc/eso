import 'dart:convert';

import 'package:flutter_js/flutter_js.dart';
import 'package:http/http.dart' as http;

class AnalyzeUrl {
  static Future<http.Response> urlRuleParser(
    String rule, {
    String host = "",
    String key = "",
    String result = "",
    int page = 1,
    int pageSize = 20,
  }) async {
    rule = rule.trim();
    Map<String, dynamic> json = {
      "host": host,
      "key": key,
      "page": page,
      "pageSize": pageSize,
      "searchKey": key,
      "searchPage": page,
      "result": result,
    };
    if (rule.startsWith("@js:")) {
      // js规则
      final _idJsEngine = await FlutterJs.initEngine();
      await FlutterJs.initJson(json, _idJsEngine);
      final result = FlutterJs.evaluate(rule, _idJsEngine);
      FlutterJs.close(_idJsEngine);
      return _parser(host, result);
    } else {
      // 非js规则, 考虑字符串替换
      return _parser(
          host,
          rule.replaceAllMapped(
            RegExp(
                r"\$result|\$host|\$key|\$page|\$pageSize|searchKey|searchPage"),
            (m) {
              return '${json[m.group(0).replaceFirst("\$", '')]}';
            },
          ));
    }
  }

  static Future<http.Response> _parser(String host, dynamic rule) async {
    if (rule is String) {
      rule = rule.trim();
      if (rule.isEmpty) return http.get('$host');
      if (rule.startsWith("{")) {
        rule = jsonDecode(rule);
      }
    }
    if (rule is Map) {
      Map<String, dynamic> r =
          rule.map((k, v) => MapEntry(k.toString().toLowerCase(), v));

      Map<String, String> headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.132 Safari/537.36',
      }..addAll(Map<String, String>.from(r['headers'] ?? Map()));

      dynamic body = r['body'];
      dynamic method = r['method']?.toString()?.toLowerCase();

      if (method == null || method == 'get') {
        return http.get(r['url'], headers: headers);
      }
      if (method == 'post') {
        return http.post(r['url'], headers: headers, body: body);
      }
      throw ('error parser url rule');
    } else {
      return http.get('$rule');
    }
  }
}
