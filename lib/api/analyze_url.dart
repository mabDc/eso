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
      await JSEngine.setEnvironment(page, rule, result, rule.host, keyword, result);
      final re = await JSEngine.evaluate(
          "${JSEngine.environment};1+1;${JSEngine.rule.loadJs};1+1;${url.substring(4)}");
      if ((re is String && re == "null") || re == null) {
        // return originalHttp.Response("null url", 200);
        return null;
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

    // 修改headers生成办法
    var headers = <String, String>{
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.80 Safari/537.36 Edg/98.0.1108.50',
    };
    if (rule.cookies.trim().isNotEmpty) {
      headers["cookie"] = rule.cookies;
    }
    if (rule.userAgent.trim().isNotEmpty) {
      final ua = rule.userAgent.trim();
      if (ua.startsWith("{") && ua.endsWith("}")) {
        headers.addAll((jsonDecode(ua) as Map)
            .map((k, v) => MapEntry(k.toString().toLowerCase(), v)));
      } else {
        headers["user-agent"] = ua;
      }
    }

    if (url is Map) {
      Map<String, dynamic> r = url.map((k, v) => MapEntry(k.toString().toLowerCase(), v));

      headers.addAll(Map<String, String>.from(r['headers'] ?? Map()));

      dynamic body = r['body'];
      dynamic method = r['method']?.toString()?.toLowerCase();
      final r_encoding = r['encoding'] == null ? null : "${r['encoding']}";
      var u = urlFix("${r['url']}", rule.host);
      if (r_encoding != null) {
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

        final encoding = r_encoding.contains("gb") ? gbk : Encoding.getByName(r_encoding);
        u = u.replaceAllMapped(
            RegExp(r"[^\x00-\x7F]+"),
            (match) => encoding
                .encode(match.group(0))
                .map((code) => _urlEncode(code.toRadixString(16).toUpperCase()))
                .join());
        if (body != null && body is String) {
          body = body.replaceAllMapped(
              RegExp(r"[^\x00-\x7F]+"),
              (match) => encoding
                  .encode(match.group(0))
                  .map((code) => _urlEncode(code.toRadixString(16).toUpperCase()))
                  .join());
        }
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
          encoding: r_encoding != null && body is Map
              ? r_encoding.contains("gb")
                  ? gbk
                  : Encoding.getByName("${r['encoding']}")
              : null,
        );
      }
      throw ('error parser url rule');
    } else {
      return http.get(urlFix("$url", rule.host), headers: headers);
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
