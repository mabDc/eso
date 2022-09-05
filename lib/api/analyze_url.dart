import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/global.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as originalHttp;
import 'package:logger/logger.dart';
import 'analyze_url_client.dart' as http;

import 'api_js_engine.dart';

class AnalyzeUrl {
  static Future<Response<List<int>>> urlRuleParser(
    String url,
    Rule rule, {
    String keyword = "",
    String result = "",
    int page,
    int pageSize,
  }) async {
    url = url.trim();
    if (url == "null")
      return Response(
          data: Uint8List(1), statusCode: 200, requestOptions: null);

    if (url.startsWith("@js:")) {
      // js规则
      JSEngine.setEnvironment(page, rule, result, rule.host, keyword, result);
      final re = await JSEngine.evaluate(url.substring(4));
      if (re is String && re == "null") {
        return Response(
            data: Uint8List(1), statusCode: 200, requestOptions: null);
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
          RegExp(
              r"\$keyword|\$page|\$host|\$result|\$pageSize|searchKey|searchPage"),
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

  static Future<Response<List<int>>> parser(dynamic url, Rule rule) async {
    //print("object:$url");
    if (url is String) {
      url = url.trim();
      if (url.isEmpty) return http.get(rule.host);
      if (url.startsWith("{")) {
        url = jsonDecode(url);
      }
    }
    //print("is Map ${url is Map}");
    if (url is Map) {
      Map<String, dynamic> r =
          url.map((k, v) => MapEntry(k.toString().toLowerCase(), v));
      //print("r:${r},${r['requestencode']}");

      Map<String, String> headers = {
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
        'Accept': '*/*',
        // 'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'User-Agent': rule.userAgent.trim().isNotEmpty
            ? rule.userAgent
            : Global.userAgent,
        "Cookie": rule.cookies,
      }..addAll(Map<String, String>.from(r['headers'] ?? Map()));
      dynamic body = r['body'];
      dynamic method = r['method']?.toString()?.toLowerCase();
      int cacheTime = r['cacheTime'] as int;
      // cacheTime = 84000;

      print("cacheTime:${cacheTime}");

      var u = urlFix("${r['url']}", rule.host);
      var forbidRedirect = r['forbidredirect'];
      print("forbidRedirect:${forbidRedirect}");

      //print("is requestEncode ${r['requestencode'] != null}");

      if (r['encoding'] != null || r['requestencode'] != null) {
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

        final encoding = r['encoding'] != null
            ? "${r['encoding']}".contains("gb")
                ? gbk
                : Encoding.getByName("${r['encoding']}")
            : r['requestencode'] != null
                ? "${r['requestencode']}".contains("gb")
                    ? gbk
                    : Encoding.getByName("${r['requestencode']}")
                : null;
        if (body != null && body is String) {
          body = body.replaceAllMapped(
              RegExp(r"[^\x00-\x7F]+"),
              (match) => encoding
                  .encode(match.group(0))
                  .map((code) =>
                      _urlEncode(code.toRadixString(16).toUpperCase()))
                  .join());
        }

        u = u.replaceAllMapped(
            RegExp(r"[^\x00-\x7F]+"),
            (match) => encoding
                .encode(match.group(0))
                .map((code) => _urlEncode(code.toRadixString(16).toUpperCase()))
                .join());
      }
      if (method == null || method == 'get') {
        print("u:${u},headers:${headers.toString()}");
        return http.get(u,
            headers: headers,
            cacheTime: cacheTime,
            forbidRedirect: forbidRedirect);
      }
      if (method == "put") {
        return http.put(u,
            headers: headers,
            body: body,
            cacheTime: cacheTime,
            forbidRedirect: forbidRedirect);
      }
      if (method == 'post') {
        //print("post_body:${body},u:${u}");
        return http.post(
          u,
          headers: headers,
          body: body,
          cacheTime: cacheTime,
          encoding: r['encoding'] != null
              ? "${r['encoding']}".contains("gb")
                  ? gbk
                  : Encoding.getByName("${r['encoding']}")
              : null,
          forbidRedirect: forbidRedirect,
        );
      }
      throw ('error parser url rule');
    } else {
      Logger().d(rule.cookies);
      return http.get(urlFix("$url", rule.host), headers: {
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
        'Accept': '*/*',
        // 'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'User-Agent': rule.userAgent.trim().isNotEmpty
            ? rule.userAgent
            : Global.userAgent,
        "Cookie": rule.cookies,
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
