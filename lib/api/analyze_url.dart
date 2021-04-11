import 'dart:convert';

import 'package:eso/database/rule.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:http/http.dart' as originalHttp;
import 'analyze_url_client.dart' as http;

import 'api_js_engine.dart';

class AnalyzeUrl {
  static Future<originalHttp.Response> urlRuleParser(
    String url,
    Rule rule, {
    String keyword = "",
    String result = "",
    int page,
    int pageSize,
  }) async {
    url = url.trim();
    if (url == "null") return originalHttp.Response("", 200);
    if (url.startsWith("@js:")) {
      // js规则
      JSEngine.setEnvironment(page, rule, result, rule.host, keyword, result);
      final re = await JSEngine.evaluate(url.substring(4));
      if (re is String && re == "null") {
        return originalHttp.Response("", 200);
      }
      final res = await parser(re, rule);
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
      final res = await parser(
        url.replaceAllMapped(
          RegExp(r"\$keyword|\$page|\$host|\$result|\$pageSize|searchKey|searchPage"),
          (m) => '${json[m.group(0)]}',
        ),
        rule,
      );
      // if (res.statusCode > 400) {
      //   throw "Request Error, statusCode is" + res.statusCode.toString();
      // }
      return res;
    }
  }

  static Future<originalHttp.Response> parser(dynamic url, Rule rule) async {
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
        'user-agent': rule.userAgent.trim().isNotEmpty
            ? rule.userAgent
            : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36',
        "cookie": rule.cookies,
      }..addAll(Map<String, String>.from(r['headers'] ?? Map()));

      dynamic body = r['body'];
      dynamic method = r['method']?.toString()?.toLowerCase();
      var u = urlFix("${r['url']}", rule.host);
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
        u = u.replaceAllMapped(
            RegExp(r"[^\x00-\x7F]+"),
            (match) => encoding
                .encode(match.group(0))
                .map((code) => _urlEncode(code.toRadixString(16).toUpperCase()))
                .join());
      }
      if (method == null || method == 'get') {
        return http.get(u, headers: headers);
      }
      if (method == "put") {
        return http.put(u, headers: headers, body: body);
      }
      if (method == 'post') {
        return http.post(
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
      return http.get(urlFix("$url", rule.host), headers: {
        'user-agent': rule.userAgent.trim().isNotEmpty
            ? rule.userAgent
            : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.113 Safari/537.36',
        "cookie": rule.cookies,
      });
    }
  }

  static String urlFix(String url, String host) {
    url = "$url".trim();
    host = host.trim();
    if (url.startsWith("//")) {
      if (host.startsWith("https")) {
        return "https:" + url;
      } else {
        return "http:" + url;
      }
    } else if (!url.startsWith("http") && !url.startsWith("ftp")) {
      return host + url;
    }
    return url;
  }
}
