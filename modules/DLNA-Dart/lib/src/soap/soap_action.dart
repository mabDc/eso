import 'dart:convert';
import 'dart:io';

import '../dlna_action_result.dart';
import '../dlna_device.dart';

abstract class AbsDLNAAction<T> {
  static final ContentType contentType =
      ContentType('text', 'xml', charset: 'utf-8');

  HttpClient httpClient = HttpClient();

  DLNADevice dlnaDevice;

  AbsDLNAAction(DLNADevice dlnaDevice) {
    this.dlnaDevice = dlnaDevice;
    httpClient
      ..connectionTimeout = Duration(seconds: 5)
      ..idleTimeout = Duration(seconds: 5);
  }

  String getControlURL();

  String getXmlData();

  String getSoapAction();

  Future<DLNAActionResult<T>> execute();

  Future<DLNAActionResult<T>> start() async {
    var url = 'http://' + Uri.parse(dlnaDevice.location).authority;
    var controlURL = getControlURL();
    if (!url.endsWith('/')) {
      url = url + ('/');
    }
    if (controlURL.startsWith('/')) {
      controlURL = controlURL.substring(1);
    }
    url = url + controlURL;
    var content = getXmlData();
    var result = DLNAActionResult<T>();
    try {
      var request = await httpClient.postUrl(Uri.parse(url))
        ..headers.contentType = contentType
        ..headers.contentLength = utf8.encode(content).length
        ..headers.add('Connection', 'Keep-Alive')
        ..headers.add('Charset', 'UTF-8')
        ..headers.add('Soapaction', getSoapAction())
        ..write(content);
      var response = await request.close();
      result.httpContent = await response.transform(utf8.decoder).join();
      result.success =
          (response.statusCode == HttpStatus.ok && result.httpContent != null);
    } catch (e) {
      result.success = false;
      result.errorMessage = e.toString();
    }
    return result;
  }
}
