import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../dlna_device.dart';

class LocalDeviceParser {
  static const String KEY_DLNA_CACHE_DEVICES = 'key_dlna_cache_devices';

  /// Only for Platform.isAndroid || Platform.isIOS
  void saveDevices(Map<String, DLNADevice> devices) async {
    var prefs = await SharedPreferences.getInstance();
    var jsonDevices = jsonEncode(devices);
    await prefs.setString(KEY_DLNA_CACHE_DEVICES, jsonDevices);
  }

  Future<String> getCacheDevices() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(KEY_DLNA_CACHE_DEVICES);
  }

  Future<List<DLNADevice>> findAndConvert() async {
    var deviceStr = await getCacheDevices();
    if (deviceStr == null || deviceStr.isEmpty) {
      return null;
    }
    var devices = jsonDecode(deviceStr);
    if (devices != null) {
      var deviceMap = Map<String, Map>.from(devices);
      var deviceList = <DLNADevice>[];
      deviceMap.forEach((key, value) {
        var device = DLNADevice();
        device
          ..usn = value['usn']
          ..uuid = value['uuid']
          ..location = value['location'];
        device.description = DLNADescription()
          ..friendlyName = value['deviceName'];
        deviceList.add(device);
      });
      return deviceList;
    }
    return null;
  }
}
