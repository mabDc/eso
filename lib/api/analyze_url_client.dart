import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:encrypt/encrypt.dart';
import 'package:eso/global.dart';
import 'package:eso/utils/cache_util.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio_http2_adapter/dio_http2_adapter.dart';

class HttpLog {
  bool _open = false;
  List<Map<String, String>> urls = [];
  List<Map<String, String>> requestHeader = [];
  List<Map<String, String>> responseHeader = [];
  void clear({bool open = true}) {
    _open = open;
    urls.forEach((element) => element.clear());
    urls.clear();
    requestHeader.forEach((element) => element.clear());
    requestHeader.clear();
    responseHeader.forEach((element) => element.clear());
    responseHeader.clear();
  }

  String GetUrls() {
    if (urls.isEmpty) {
      return '';
    }
    return urls.map((e) {
      String r = '';
      for (var item in e.entries) {
        r += '${item.key}  => ${item.value}';
      }
      return r;
    }).join('\n');
  }

  String GetOriginalRequest() {
    if (requestHeader.isEmpty) {
      return '';
    }
    return JsonEncoder.withIndent('\t\t').convert(requestHeader?.first ?? '');
  }

  String GetCurrentRequest() {
    if (requestHeader.isEmpty) {
      return '';
    }
    return JsonEncoder.withIndent('\t\t').convert(requestHeader?.last ?? '');
  }

  String GetOriginalResponse() {
    if (responseHeader.isEmpty) {
      return '';
    }
    return JsonEncoder.withIndent('\t\t').convert(responseHeader?.first ?? '');
  }

  String GetCurrentResponse() {
    if (responseHeader.isEmpty) {
      return '';
    }
    return JsonEncoder.withIndent('\t\t').convert(responseHeader?.last ?? '');
  }

  bool get open => _open;
  set open(bool v) {
    if (_open != v) {
      _open = v;
    }
  }
}

HttpLog httpLog = HttpLog();

class CacheInterceptor extends dio.Interceptor {
  final _TAG = 'CacheInterceptor';
  CacheUtil _cacheUtil;
  String _cachePath;
  CacheInterceptor() {
    _cacheUtil = CacheUtil(backup: false, basePath: "httpCache");
    _init();
  }
  _init() async {
    _cachePath = await _cacheUtil.cacheDir();
    print("[$_TAG] _cachePath:${_cachePath}");
  }

  @override
  void onRequest(
    dio.RequestOptions options,
    dio.RequestInterceptorHandler handler,
  ) async {
    var cacheKey = options.extra['cacheKey'] as String;
    if (cacheKey == null) {
      cacheKey = md5.convert(utf8.encode(options.path)).toString();
    }
    var response = await _cacheUtil.getData(cacheKey, hashCodeKey: false);
    // print("[$_TAG] onRequest:${response} cacheKey:[$cacheKey]");
    // 如果缓存数据为null或刷新数据则继续下一个
    if (response == null || options.extra['refresh'] == true) {
      print("[$_TAG] response为空或刷新数据,继续下一个拦截器");

      // options..validateStatus = (status) => status < 500;

      return handler.next(options);
    } else {
      // return handler.next(options);
      try {
        final _cacheTime1 = options.extra['cacheTime'] as int;
        final _cacheTime2 = response['cacheTime'] as int;
        // -1 表示禁用缓存
        if (_cacheTime1 == -1) {
          print("[$_TAG] onRequest>cache 禁用缓存");

          return handler.next(options);
        }

        print(
            "[$_TAG] onRequest>cache ${(DateTime.now().millisecondsSinceEpoch - _cacheTime2)},_cacheTime2:${_cacheTime2},_cacheTime1:${_cacheTime1}");

        if ((DateTime.now().millisecondsSinceEpoch - _cacheTime2) >
            _cacheTime1 * 1000) {
          print("[$_TAG] onRequest 缓存过期");
          return handler.next(options);
        }

        final _response = response['response'];
        final _data = _response['data'].cast<int>();

        final _headers = dio.Headers();

        for (var item in (_response['headers'] as Map).entries) {
          _headers.add(item.key, item.value.join());
        }
        return handler.resolve(
          dio.Response(
            data: Uint8List.fromList(_data),
            headers: _headers,
            statusCode: _response['statusCode'] as int,
            statusMessage: _response['statusMessage'] as String,
            requestOptions: options,
          ),
        );
      } catch (e) {
        print("[$_TAG] onRequest 读取缓存异常:${e}");

        return handler.next(options);
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      dio.Response response, dio.ResponseInterceptorHandler handler) {
    final cacheTime = response.requestOptions.extra['cacheTime'] as int;

    var cacheKey = response.requestOptions.extra['cacheKey'] as String;

    if (cacheKey == null) {
      cacheKey =
          md5.convert(utf8.encode(response.requestOptions.path)).toString();
    }
    if (cacheTime != -1) {
      _cacheUtil.put(
        cacheKey,
        jsonEncode(
          {
            'cacheTime': DateTime.now().millisecondsSinceEpoch,
            'response': {
              'data': response.data,
              'extra': response.extra,
              'headers': response.headers.map,
              'isRedirect': response.isRedirect,
              'statusCode': response.statusCode,
              'statusMessage': response.statusMessage,
            }
          },
        ),
        false,
      );
    }

    return handler.next(response);

    // print(
    //     "[$_TAG] onResponse: cacheKey:[$cacheKey] ; response:[${response.toString()}]");

    // _cache[response.requestOptions.uri] = response;
    super.onResponse(response, handler);
  }

  @override
  void onError(dio.DioError err, dio.ErrorInterceptorHandler handler) {
    print('[$_TAG] onError: $err');
    super.onError(err, handler);
  }
}

class MyAdapter extends dio.HttpClientAdapter {
  Http2Adapter http2Adapter = Http2Adapter(
    ConnectionManager(
      idleTimeout: 10000,
      onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
    ),
  );

  DefaultHttpClientAdapter defaultHttpClientAdapter = DefaultHttpClientAdapter()
    ..onHttpClientCreate = (HttpClient client) {
      client.idleTimeout = const Duration(seconds: 10);
      return null;
    };

  @override
  void close({bool force = false}) {
    http2Adapter.close();
    defaultHttpClientAdapter.close();
  }

  @override
  Future<dio.ResponseBody> fetch(dio.RequestOptions options,
      Stream<Uint8List> requestStream, Future cancelFuture) async {
    print("httpLog.open:${httpLog.open}");
    // 判断是否为空 只记录第一次的请求
    if (httpLog.open) {
      final url = Map<String, String>();
      url[options.path] = options.method;
      httpLog.urls.add(url);

      httpLog.requestHeader
          .add(options.headers.map((key, value) => MapEntry(key, value)));
    }

    // httpLog.requestHeader =
    //     options.headers.map((key, value) => MapEntry(key, value));

    dio.ResponseBody responseBody;
    if (options.uri.toString().startsWith(RegExp(r'https'))) {
      try {
        responseBody = await http2Adapter.fetch(
          options,
          requestStream,
          cancelFuture,
        );
        print("[responseBody] ${responseBody.statusCode}");
      } catch (e) {
        responseBody = await defaultHttpClientAdapter.fetch(
          options,
          requestStream,
          cancelFuture,
        );
      }
    } else {
      responseBody = await defaultHttpClientAdapter.fetch(
          options, requestStream, cancelFuture);
    }
    httpLog.responseHeader.add(
        responseBody.headers.map((key, value) => MapEntry(key, value.join())));
    if (options.followRedirects && responseBody.statusCode == 301 ||
        responseBody.statusCode == 302) {
      options.extra[''] == true;

      print("[fetch] options.maxRedirects:${options.maxRedirects}");
      String location = responseBody.headers['location'].first;

      if (location.startsWith("//")) {
        location = "${options.uri.scheme}:$location";
      } else if (location.startsWith("/")) {
        location = "${options.uri.scheme}://${options.uri.host}$location";
      } else if (location.startsWith('http') == false) {
        var urlpath = options.uri.path;
        var index = urlpath.lastIndexOf('/') + 1;
        if (index <= 0) {
          return responseBody;
        }
        urlpath = urlpath.substring(0, index);
        location =
            "${options.uri.scheme}://${options.uri.host}$urlpath$location";
      }
      print("[fetch] location:${location}");
      return fetch(
        options.copyWith(
          path: location,
          maxRedirects: --options.maxRedirects,
        ),
        requestStream,
        cancelFuture,
      );
    }

    return responseBody;
  }
}

dio.Dio get dioClient {
  var d = dio.Dio()
    // ..interceptors.add(LogsInterceptors())
    ..interceptors.add(CacheInterceptor())
    ..httpClientAdapter = MyAdapter();

  return d;
}

dio.Options makeOptions(Map<String, dynamic> header, {int cacheTime}) {
  dio.Options option = dio.Options();
  option.responseType = dio.ResponseType.bytes;
  option.extra ??= {};
  option.extra['cacheTime'] = cacheTime ?? -1;

  if (header != null && header.isNotEmpty) {
    Map<String, String> headers = {};
    for (var v in header.entries) {
      // 过滤此字段 HTTP 2 没有这玩意
      if (v.key.toLowerCase().contains('connection')) {
        continue;
      }
      headers[v.key.toLowerCase()] = v.value;
    }
    option.headers = headers;
    print("option.headers:${option.headers}");
  }

  return option;
}

Future<dio.Response<List<int>>> get(
  String url, {
  Map<String, String> headers,
  int cacheTime,
  bool forbidRedirect,
}) async {
  forbidRedirect ??= false;
  final options = makeOptions(headers, cacheTime: cacheTime)
    ..followRedirects = !forbidRedirect
    ..maxRedirects = 5
    ..validateStatus = (status) => status < 500;
  final r = await dioClient.get<List<int>>(
    url,
    options: options,
  );
  return r;
}

Future<dio.Response<List<int>>> put(
  String url, {
  Map<String, String> headers,
  dynamic body,
  int cacheTime,
  bool forbidRedirect,
}) {
  final options = makeOptions(headers, cacheTime: cacheTime)
    ..followRedirects = !forbidRedirect
    ..maxRedirects = 5
    ..validateStatus = (status) => status < 500;
  return dioClient.put<List<int>>(url, data: body, options: options);
}

Future<dio.Response<List<int>>> post(
  String url, {
  Map<String, String> headers,
  dynamic body,
  Encoding encoding,
  bool forbidRedirect,
  int cacheTime,
}) async {
  // print("post->headers:${headers}");
  final options = makeOptions(headers, cacheTime: cacheTime)
    ..followRedirects = !forbidRedirect
    ..maxRedirects = 5
    ..validateStatus = (status) => status < 500;

  final response = await dioClient.post<List<int>>(
    url,
    data: body,
    options: options,
  );
  print("response:${response.statusCode}");
  if (forbidRedirect == true) {
    return response;
  }
  return response;
}

// /// Log 拦截器
// class LogsInterceptors extends dio.InterceptorsWrapper {
//   @override
//   onRequest(dio.RequestOptions options, handler) {
//     if (kDebugMode) {
//       print("请求类型：${options.method}");
//       print("请求URL：${options.baseUrl}${options.path}");
//       if (options.queryParameters.isNotEmpty) {
//         print('请求参数: ${options.queryParameters}');
//       }
//       print('请求头: ${options.headers}');
//       if (options.method == "POST" || options.method == "PUT") {
//         print(
//             '请求Body: ${options.data is Map ? const JsonEncoder().convert(options.data) : options.data.toString()}');
//       }
//     }

//     return super.onRequest(options, handler);
//   }

//   @override
//   onResponse(dio.Response response, handler) {
//     if (kDebugMode) {
//       print('返回数据: ${response.data?.length ?? 0} bytes');
//     }

//     return super.onResponse(response, handler); // continue
//   }

//   @override
//   onError(dio.DioError err, handler) {
//     if (kDebugMode) {
//       print('请求异常: $err');
//       if (err.response != null) {
//         print('请求异常信息: ${String.fromCharCodes(err.response?.data)}');
//       }
//     }

//     return super.onError(err, handler);
//   }
// }
