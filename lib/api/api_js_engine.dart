/*
 * @Author: your name
 * @Date: 2020-07-17 11:19:01
 * @LastEditTime: 2020-07-25 17:10:43
 * @LastEditors: your name
 * @Description: In User Settings Edit
 * @FilePath: \eso\lib\api\api_const.dart
 */
import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:eso/api/analyzer_html.dart';
import 'package:eso/api/analyzer_xpath.dart';
import 'package:eso/database/rule.dart';
import 'package:eso/model/moreKeys.dart';
import 'package:eso/utils.dart';
import 'package:eso/utils/decode_body.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qjs/flutter_qjs.dart';
// import 'package:xpath_parse/xpath_selector.dart';
import 'package:xpath_selector/xpath_selector.dart';
import 'package:http/http.dart' as http;
import '../global.dart';
import 'analyze_url.dart';
import 'analyzer_encode.dart';
import 'analyzer_decode.dart';

class APIConst {
  static final pagePattern =
      RegExp(r"""(\$page)|((^|[^a-zA-Z'"_/-])page([^a-zA-Z0-9'"]|$))""");
  static final largeSpaceRegExp = RegExp(r"\n+\s*|\s{2,}");
  static final tagsSplitRegExp = RegExp(r"[　 ,/\|\&\%]+");
}

class JSEngine {
  static IsolateQjs _engine;
  static Rule _rule;
  static Rule get rule => _rule;
  static Future<void> initEngine() async {
    AESMode asAESMode(int _mode) {
      AESMode mode;
      if (_mode == null) {
        return AESMode.sic;
      }
      switch (_mode) {
        case 1:
          mode = AESMode.cbc;
          break;
        case 2:
          mode = AESMode.cfb64;
          break;
        case 3:
          mode = AESMode.ctr;
          break;
        case 4:
          mode = AESMode.ecb;
          break;
        case 5:
          mode = AESMode.ofb64Gctr;
          break;
        case 6:
          mode = AESMode.ofb64;
          break;
        case 7:
          mode = AESMode.sic;
          break;
        default:
          mode = AESMode.ecb;
      }
      return mode;
    }

    if (_engine != null) return;
    final cryptoJS = await rootBundle.loadString(Global.cryptoJSFile);
    final JSEncrypt = await rootBundle.loadString(Global.JSEncryptFile);

    _engine = IsolateQjs(stackSize: 1024 * 1024);
    final setToGlobalObject = await _engine.evaluate(";window = globalThis;" +
        cryptoJS +
        ";1+1;" +
        JSEncrypt +
        ";1+1;" +
        "(key, val) => { this[key] = val; }");
    await setToGlobalObject.invoke([
      "__http__",
      IsolateFunction((dynamic url) async {
        final res = await AnalyzeUrl.parser(url, _rule);
        return DecodeBody()
            .decode(res.data, res.headers["content-type"]?.first);
      }),
    ]);
    await setToGlobalObject.invoke([
      "__http_byte__",
      IsolateFunction((dynamic url) async {
        final res = await AnalyzeUrl.parser(url, _rule);
        String _body = res.data as String;
        if (url is Map) {
          Map<String, dynamic> r =
              url.map((k, v) => MapEntry(k.toString().toLowerCase(), v));
          String encodeing = r['responseEncoding'] != null
              ? res.headers["content-type"]
              : r['responseEncoding'];
          _body = DecodeBody().decode(res.data, encodeing);
        }
        return {
          "bytes": res.data,
          "body": _body,
          "statusCode": res.statusCode,
          "headers": res.headers
        };
      }),
    ]);
    await setToGlobalObject.invoke([
      "require",
      IsolateFunction((dynamic url) async {
        if (url == null) return null;
        final module = url.toString();
        if (module.startsWith("http")) {
          final res = await http.get(Uri.parse(module));
          return await _engine.evaluate(res.body + ";0;");
        } else {
          try {
            final js = await rootBundle.loadString("lib/assets/" +
                module.replaceFirst(new RegExp(r".js$"), "") +
                ".js");
            return await _engine.evaluate(js + ";0;");
          } catch (e) {
            return null;
          }
        }
      }),
    ]);
    await setToGlobalObject.invoke([
      "xpath",
      IsolateFunction((String html, String xpath) async {
        return AnalyzerXPath().parse(html).getString(xpath);
      }),
    ]);
    await setToGlobalObject.invoke([
      "__encode",
      IsolateFunction((String type, String body) async {
        return AnalyzerEncode().parse(body).getString(type);
      }),
    ]);
    await setToGlobalObject.invoke([
      "__decode",
      IsolateFunction((String type, String body) async {
        return AnalyzerDecode().parse(body).getString(type);
      }),
    ]);
    await setToGlobalObject.invoke([
      "css",
      IsolateFunction((String html, String css) async {
        return AnalyzerHtml().parse(html).getString(css);
      }),
    ]);
    await setToGlobalObject.invoke([
      "toast",
      IsolateFunction((dynamic msg) {
        Utils.toast("$msg");
      }),
    ]);
    await setToGlobalObject.invoke([
      "AES_Encode",
      IsolateFunction((String string, String key, dynamic opt) async {
        AESMode mode;
        String padding;
        IV iv;
        if (opt is Map) {
          opt = asT<Map>(opt);
          padding = opt['padding'];
          mode = asAESMode(opt['mode']);
          if (padding == null) {
            padding = 'PKCS7';
          }
          String _iv = opt['iv'];
          if (_iv != null) {
            iv = IV.fromUtf8(_iv);
          }
        } else if (opt == null) {
          padding = "PKCS7";
          mode = AESMode.ecb;
        } else {
          return {'err': '参数错误'};
        }
        if (iv == null) {
          iv = IV.fromLength(16);
        }
        Key enckey = Key.fromUtf8(key);
        Encrypted _encrypted = Encrypter(
          AES(
            enckey,
            mode: mode,
            padding: padding,
          ),
        ).encrypt(string, iv: iv);

        return {
          'base16': _encrypted.base16,
          'base64': _encrypted.base64,
          'bytes': _encrypted.bytes,
        };
        //return AnalyzerHtml().parse(html).getString(css);
      }),
    ]);
    await setToGlobalObject.invoke([
      "AES_Decode",
      IsolateFunction((String string, String key, dynamic opt) async {
        print("isMap:${opt is Map},${opt}");
        AESMode mode;
        String padding;
        IV iv;
        if (opt is Map) {
          opt = asT<Map>(opt);
          padding = opt['padding'];
          mode = asAESMode(opt['mode']);
          if (padding == null) {
            padding = 'PKCS7';
          }
          String _iv = opt['iv'];
          if (_iv != null) {
            iv = IV.fromUtf8(_iv);
          }
        } else if (opt == null) {
          padding = "PKCS7";
          mode = AESMode.ecb;
        } else {
          return {'err': '参数错误'};
        }
        if (iv == null) {
          iv = IV.fromLength(16);
        }
        Key enckey = Key.fromUtf8(key);
        return Encrypter(
          AES(
            enckey,
            mode: mode,
            padding: padding,
          ),
        ).decrypt64(string, iv: iv);
        //return AnalyzerHtml().parse(html).getString(css);
      }),
    ]);

    setToGlobalObject.free();
    await _engine.evaluate("""
    var esoTools = {};
    esoTools.encode = (type, body) => {
        return __encode(type, body);
    };
    esoTools.decode = (type, body) => {
        return __decode(type, body);
    };
    esoTools.AES_Encode = (string, inkey, opt) => {
        return AES_Encode(string, inkey, opt);
    };
    esoTools.AES_Decode = (string, inkey, opt) => {
        return AES_Decode(string, inkey, opt);
    };
    esoTools.AES_EncodeCBC = (string, inkey, iniv) => {
        return AES_Encode(string, inkey, { mode: AESMode.cbc, padding: 'PKCS7', iv: iniv });
    };
    esoTools.AES_DecodeCBC = (string, inkey, iniv) => {
        return AES_Decode(string, inkey, { mode: AESMode.cbc, padding: 'PKCS7', iv: iniv });
    };
    esoTools.AES_EncodeECB = (string, inkey) => {
        return AES_Encode(string, inkey, { mode: AESMode.ecb, padding: 'PKCS7'});
    };
    esoTools.AES_DecodeECB = (string, inkey) => {
        return AES_Decode(string, inkey, { mode: AESMode.ecb, padding: 'PKCS7'});
    };
    esoTools.RSA_encrypt = (string, key) => {
        var encrypted = new window.JSEncrypt;
        encrypted.setPublicKey(key);
        return encrypted.encrypt(string);
    };
    esoTools.RSA_decrypt = (string, key) => {
        var encrypted = new window.JSEncrypt;
        encrypted.setPrivateKey(key);
        return encrypted.decrypt(string);
    };
    esoTools.RSA_encryptWithPrivate = (string, key) => {
        var encrypted = new window.JSEncrypt;
        encrypted.setPrivateKey(key);
        return encrypted.encrypt(string);
    };
    esoTools.RSA_decryptWithPublic = (string, key) => {
        var encrypted = new window.JSEncrypt;
        encrypted.setPublicKey(key);
        return encrypted.decrypt(string);
    };

    var AESMode = {
        cbc: 1,
        cfb64: 2,
        ctr: 3,
        ecb: 4,
        ofb64Gctr: 5,
        ofb64: 6,
        sic: 7,
    };

    var params  = {};
    var http = (url) => __http__(url);
    var httpByte = (url) => __http_byte__(url);
    http.get = (url) => http(url);
    http.post = (url, body, headers) => {
      headers = headers ?? {};
      if(headers["content-type"] === undefined){
        if(typeof(body) === "string"){
          if(body.indexOf("=") > -1){
            headers["content-type"] = "application/x-www-form-urlencoded";
          }else{
            headers["content-type"] = "application/json";
          }
        }else{
          body = JSON.stringify(body);
          headers["content-type"] = "application/json";
        }
      }
      return http({
        url,
        body,
        method: "POST",
        headers
      });
    };
    http.put = (url, body, headers) => {
      headers = headers ?? {};
      if(headers["content-type"] === undefined){
        if(typeof(body) === "string"){
          if(body.indexOf("=") > -1){
            headers["content-type"] = "application/x-www-form-urlencoded";
          }else{
            headers["content-type"] = "application/json";
          }
        }else{
          body = JSON.stringify(body);
          headers["content-type"] = "application/json";
        }
      }
      return http({
        url,
        body,
        method: "PUT",
        headers
      });
    };
    var print = (s, isUrl) => {
      try{
        __print(s, !!isUrl);
      }catch(e){}
    }
    1+1;
    """);
  }

  static Future<void> setFunction(String name, IsolateFunction fun) async {
    await initEngine();
    final setToGlobalObject =
        await _engine.evaluate("(key, val) => { this[key] = val; }");
    await setToGlobalObject.invoke([name, fun]);
    setToGlobalObject.free();
  }

  static String thisBaseUrl;

  static Future<void> setEnvironment(
    int page,
    Rule rule,
    String result,
    String baseUrl,
    String keyword,
    String lastResult,
  ) async {
    print("host:${jsonEncode(rule.host)}}");
    await initEngine();
    _rule = rule;
    thisBaseUrl = baseUrl;
    await _engine.evaluate("""
page = ${jsonEncode(page)};
host = ${jsonEncode(rule.host)};
cookie = ${jsonEncode(rule.cookies)};
result = ${jsonEncode(result)};
baseUrl = ${jsonEncode(baseUrl)};
keyword = ${jsonEncode(keyword)};
lastResult = ${jsonEncode(lastResult)};
1+1;""" +
        rule.loadJs +
        ";1+1;");
  }

  static Future<dynamic> evaluate(String command) async {
    await initEngine();
    return _engine.evaluate(command.replaceAll("let ", "var "));
  }

  // static void close() {
  //   _engine.close();
  //   _engine = null;
  // }
}
