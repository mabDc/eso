import 'dart:convert';
import 'dart:io';

import 'package:eso/database/rule.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class AnalyzeUrl {
  static http.Client get nosslClient {
    // 自定义证书验证
    var ioClient = HttpClient()..badCertificateCallback = (_, __, ___) => true;
    // 自定义代理
    // ioClient.findProxy = (_) => "";
    return IOClient(ioClient);
  }

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
      final _idJsEngine = await FlutterJs.initEngine(99999);
      await FlutterJs.evaluate('''
keyword = ${jsonEncode(keyword)};
page = ${jsonEncode(page)};
host = ${jsonEncode(rule.host)};
result = ${jsonEncode(result)};
pageSize = ${jsonEncode(pageSize)};
cookie = ${jsonEncode(rule.cookies)};
''', _idJsEngine);
      if (rule.loadJs.trim().isNotEmpty) {
        await FlutterJs.evaluate(rule.loadJs, _idJsEngine);
      }
      final re = await FlutterJs.evaluate(url.substring(4), _idJsEngine);
      FlutterJs.close(_idJsEngine);
      final res = await _parser(re, rule, keyword);
      // if (res.statusCode > 400) {
      //   throw "Request Error, statusCode is" + res.statusCode.toString();
      // }
      return res;
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
      final res = await _parser(
        url.replaceAllMapped(
          RegExp(r"\$keyword|\$page|\$host|\$result|\$pageSize|searchKey|searchPage"),
          (m) => '${json[m.group(0)]}',
        ),
        rule,
        keyword,
      );
      // if (res.statusCode > 400) {
      //   throw "Request Error, statusCode is" + res.statusCode.toString();
      // }
      return res;
    }
  }

  static Future<http.Response> _parser(dynamic url, Rule rule, String keyword) async {
    if (url is String) {
      url = url.trim();
      if (url.isEmpty) return nosslClient.get(rule.host);
      if (url.startsWith("{")) {
        url = jsonDecode(url);
      }
    }
    if (url is Map) {
      Map<String, dynamic> r = url.map((k, v) => MapEntry(k.toString().toLowerCase(), v));

      Map<String, String> headers = {
        'user-agent': rule.userAgent.trim().isNotEmpty
            ? rule.userAgent
            : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36',
        "cookie": rule.cookies,
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
      if (r['encoding'] != null) {
        String _urlEncode(String s) {
          if (s.length % 2 == 1) {
            s = '0$s';
          }
          final sb = StringBuffer();
          for (int i = 0; i < s.length; i += 2) {
            sb.write('%${s[i]}${s[i + 1]}');
          }
          return sb.toString();
        }

        final encoding = "${r['encoding']}".contains("gb")
            ? gbk
            : Encoding.getByName("${r['encoding']}");
        u = u.replaceAll(
            keyword,
            encoding
                .encode(keyword)
                .map((code) => _urlEncode(code.toRadixString(16).toUpperCase()))
                .join());
      }
      if (method == null || method == 'get') {
        return nosslClient.get(u, headers: headers);
      }
      if (method == 'post') {
        return nosslClient.post(
          u,
          headers: headers,
          body: body,
          encoding: r['encoding'] != null
              ? "${r['encoding']}".contains("gb")
                  ? gbk
                  : Encoding.getByName("${r['encoding']}")
              : null,
        );
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
      return nosslClient.get(u, headers: {
        'user-agent': rule.userAgent.trim().isNotEmpty
            ? rule.userAgent
            : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36',
        "cookie": rule.cookies,
      });
    }
  }
}
