import 'dart:convert';

import 'package:eso/database/rule.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:http/http.dart' as http;

class AnalyzeUrl {
  static Future<http.Response> urlRuleParser(
    String url,
    Rule rule, {
    String keyword = "",
    String result = "",
    int page,
    int pageSize,
  }) async {
    url = url.trim();
    if (url.startsWith("@js:")) {
      // js规则
      final _idJsEngine = await FlutterJs.initEngine(101);
      await FlutterJs.evaluate('''
keyword = ${jsonEncode(keyword)};
page = ${jsonEncode(page)};
host = ${jsonEncode(rule.host)};
result = ${jsonEncode(result)};
pageSize = ${jsonEncode(pageSize)};
searchKey = ${jsonEncode(keyword)};
searchPage = ${jsonEncode(page)};
''', _idJsEngine);
      if (rule.loadJs.trim().isNotEmpty) {
        await FlutterJs.evaluate(rule.loadJs, _idJsEngine);
      }
      final re = await FlutterJs.evaluate(url.substring(4), _idJsEngine);
      FlutterJs.close(_idJsEngine);
      return _parser(re, rule);
    } else {
      // 非js规则, 考虑字符串替换
      Map<String, dynamic> json = {
        "\$keyword": keyword,
        "\$page": page,
        "\$host": rule.host,
        "\$result": result,
        "\$pageSize": pageSize,
        "searchKey": keyword,
        "searchPage": page,
      };
      return _parser(
          url.replaceAllMapped(
            RegExp(r"\$keyword|\$page|\$host|\$result|\$pageSize|searchKey|searchPage"),
            (m) {
              return '${json[m.group(0)]}';
            },
          ),
          rule);
    }
  }

  static Future<http.Response> _parser(dynamic url, Rule rule) async {
    if (url is String) {
      url = url.trim();
      if (url.isEmpty) return http.get(rule.host);
      if (url.startsWith("{")) {
        url = jsonDecode(url);
      }
    }
    if (url is Map) {
      Map<String, dynamic> r = url.map((k, v) => MapEntry(k.toString().toLowerCase(), v));

      Map<String, String> headers = {
        'User-Agent': rule.userAgent ??
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36'
      }..addAll(Map<String, String>.from(r['headers'] ?? Map()));

      dynamic body = r['body'];
      dynamic method = r['method']?.toString()?.toLowerCase();
      var u = "${r['url']}".trim();
      if (u.startsWith("//")) {
        if (rule.host.startsWith("https")) {
          u = "https:" + u;
        } else {
          u = "http:" + u;
        }
      } else if (u.startsWith("/")) {
        u = rule.host + u;
      }
      if (method == null || method == 'get') {
        return http.get(u, headers: headers);
      }
      if (method == 'post') {
        return http.post(u, headers: headers, body: body);
      }
      throw ('error parser url rule');
    } else {
      var u = "$url".trim();
      if (u.startsWith("//")) {
        if (rule.host.startsWith("https")) {
          u = "https:" + u;
        } else {
          u = "http:" + u;
        }
      } else if (u.startsWith("/")) {
        u = rule.host + u;
      }
      if (rule.userAgent.trim().isNotEmpty) {
        return http.get(u, headers: {'User-Agent': rule.userAgent});
      } else {
        return http.get(u, headers: {
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36'
        });
      }
    }
  }
}
