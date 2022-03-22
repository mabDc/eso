import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:retry/retry.dart';

import 'file.dart';

class WebDavException implements Exception {
  String cause;
  int statusCode;

  WebDavException(this.cause, this.statusCode);
}

class Client {
  final HttpClient httpClient = new HttpClient();
  late String _baseUrl;
  String _cwd = '/';

  /// Construct a new [Client].
  /// [path] will should be the root path you want to access.
  Client(
    String host,
    String user,
    String password, {
    String? path,
    String? protocol,
    int? port,
  }) : assert((host.startsWith('https://') ||
            host.startsWith('http://') ||
            protocol != null)) {
    _baseUrl = (protocol != null
            ? '$protocol://$host${port != null ? ':$port' : ''}'
            : host) +
        (path ?? '');
    this.httpClient.addCredentials(
        Uri.parse(_baseUrl), '', HttpClientBasicCredentials(user, password));
  }

  /// get url from given [path]
  String getUrl(String path) =>
      path.startsWith('/') ? _baseUrl + path : '$_baseUrl$_cwd$path';

  /// change current dir to the given [path], you should make sure the dir exist
  void cd(String path) {
    path = path.trim();
    if (path.isEmpty) {
      return;
    }
    List tmp = path.split("/");
    tmp.removeWhere((value) => value == null || value == '');
    String strippedPath = tmp.join('/') + '/';
    if (strippedPath == '/') {
      _cwd = strippedPath;
    } else if (path.startsWith("/")) {
      _cwd = '/' + strippedPath;
    } else {
      _cwd += strippedPath;
    }
  }

  /// send the request with given [method] and [path]
  ///
  Future<HttpClientResponse> _send(
      String method, String path, List<int> expectedCodes,
      {Uint8List? data, Map? headers}) async {
    return await retry(
        () => this
            .__send(method, path, expectedCodes, data: data, headers: headers),
        retryIf: (e) => e is WebDavException,
        maxAttempts: 5);
  }

  /// send the request with given [method] and [path]
  Future<HttpClientResponse> __send(
      String method, String path, List<int> expectedCodes,
      {Uint8List? data, Map? headers}) async {
    String url = this.getUrl(path);
    print("[webdav] http send with method:$method path:$path url:$url");

    HttpClientRequest request =
        await this.httpClient.openUrl(method, Uri.parse(url));
    request
      ..followRedirects = false
      ..persistentConnection = true;

    if (data != null) {
      request.add(data);
    }
    if (headers != null) {
      headers.forEach((k, v) => request.headers.add(k, v));
    }

    HttpClientResponse response = await request.close();
    if (!expectedCodes.contains(response.statusCode)) {
      throw WebDavException(
          "operation failed method:$method "
          "path:$path exceptionCodes:$expectedCodes "
          "statusCode:${response.statusCode}",
          response.statusCode);
    }
    return response;
  }

  /// make a dir with [path] under current dir
  Future<HttpClientResponse> mkdir(String path, [bool safe = true]) {
    List<int> expectedCodes = [201];
    if (safe) {
      expectedCodes.addAll([301, 405]);
    }
    return this._send('MKCOL', path, expectedCodes);
  }

  /// just like mkdir -p
  Future mkdirs(String path) async {
    path = path.trim();
    List<String> dirs = path.split("/");
    dirs.removeWhere((value) => value == '');
    if (dirs.isEmpty) {
      return;
    }
    if (path.startsWith("/")) {
      dirs[0] = '/' + dirs[0];
    }
    String oldCwd = _cwd;
    try {
      for (String dir in dirs) {
        try {
          await this.mkdir(dir, true);
        } finally {
          this.cd(dir);
        }
      }
    } catch (e) {} finally {
      this.cd(oldCwd);
    }
  }

  /// remove dir with given [path]
  Future rmdir(String path, [bool safe = true]) async {
    path = path.trim();
    if (!path.endsWith('/')) {
      // Apache is unhappy when directory to be deleted
      // does not end with '/'
      path += '/';
    }
    List<int> expectedCodes = [204];
    if (safe) {
      expectedCodes.addAll([204, 404]);
    }
    await this._send('DELETE', path, expectedCodes);
  }

  /// remove dir with given [path]
  Future delete(String path) async {
    await this._send('DELETE', path, [204]);
  }

  /// upload a new file with [localData] as content to [remotePath]
  Future _upload(Uint8List localData, String remotePath) async {
    await this._send('PUT', remotePath, [200, 201, 204], data: localData);
  }

  /// upload a new file with [localData] as content to [remotePath]
  Future upload(Uint8List data, String remotePath) async {
    await this._upload(data, remotePath);
  }

  /// upload local file [path] to [remotePath]
  Future uploadFile(String path, String remotePath) async {
    await this._upload(await File(path).readAsBytes(), remotePath);
  }

  /// download [remotePath] to local file [localFilePath]
  Future download(String remotePath, String localFilePath) async {
    HttpClientResponse response = await this._send('GET', remotePath, [200]);
    await response.pipe(new File(localFilePath).openWrite());
  }

  /// download [remotePath] and store the response file contents to String
  Future<String> downloadToBinaryString(String remotePath) async {
    HttpClientResponse response = await this._send('GET', remotePath, [200]);
    return response.transform(utf8.decoder).join();
  }

  /// list the directories and files under given [remotePath]
  Future<List<FileInfo>> ls({String? path, int depth = 1}) async {
    Map userHeader = {"Depth": depth};
    HttpClientResponse response = await this
        ._send('PROPFIND', path ?? '/', [207, 301], headers: userHeader);
    if (response.statusCode == 301) {
      return this.ls(path: response.headers.value('location'));
    }
    return treeFromWebDavXml(await response.transform(utf8.decoder).join());
  }
}
