import 'dart:async';

import '../dlna_device.dart';
import '../dlna_manager.dart';
import 'description_parser.dart';
import 'local_device_parser.dart';

class DiscoveryDeviceManger {
  static const int FROM_ADD = 1;
  static const int FROM_UPDATE = 2;
  static const int FROM_CACHE_ADD = 3;

  // 150s = 2.5min
  static const int DEVICE_DESCRIPTION_INTERVAL_TIME = 150000;

  // 5min
  static const DEVICE_ALIVE_CHECK_INTERVAL_TIME = Duration(minutes: 5);
  static const DEVICE_ALIVE_CHECK_RETRY_INTERVAL_TIME = Duration(seconds: 30);

  final int _startSearchTime = DateTime.now().millisecondsSinceEpoch;
  final List<String> _descTasks = [];
  final Map<String, int> _unnecessaryDevices = {};
  final Map<String, DLNADevice> _currentDevices = {};

  final DescriptionParser _descriptionParser = DescriptionParser();
  final LocalDeviceParser _localDeviceParser = LocalDeviceParser();

  Timer _timer;
  bool _enableCache = false;
  bool _disable = true;
  DeviceRefresher _refresher;

  void enableCache() {
    _enableCache = true;
  }

  Future<List<DLNADevice>> getLocalDevices() async {
    return _localDeviceParser.findAndConvert();
  }

  void setRefresh(DeviceRefresher refresher) {
    _refresher = refresher;
    if (_refresher != null) {
      _currentDevices.forEach((key, value) {
        _refresher.onDeviceAdd(value);
      });
    }
  }

  void enable() {
    _disable = false;
    _timer = Timer.periodic(DEVICE_ALIVE_CHECK_INTERVAL_TIME, (Timer t) {
      if (_disable) {
        return;
      }
      _currentDevices.forEach((key, value) {
        _checkAliveDevice(value, 0);
      });
    });
    if (_enableCache) {
      getLocalDevices().then((devices) {
        if (devices != null) {
          for (var device in devices) {
            _cacheAlive(device);
          }
        }
      }).catchError((error) {});
    }
  }

  void disable() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    _disable = true;
  }

  void release() {
    disable();
    _refresher = null;
    _descriptionParser.stop();
    _descTasks.clear();
    _unnecessaryDevices.clear();
    _currentDevices.clear();
  }

  Future<void> alive(String usn, String location, String cache) async {
    if (_disable) {
      return;
    }
    var split = usn.split('::').where((element) => element.isNotEmpty);
    if (split.isEmpty) {
      return;
    }
    var uuid = split.first;
    var cacheTime = 3600;
    try {
      // max-age=
      cacheTime = int.parse(cache.substring(8));
      // ignore: empty_catches
    } catch (ignore) {}
    DLNADevice tmpDevice = _currentDevices[uuid];
    if (tmpDevice == null) {
      int count = _unnecessaryDevices[location] ??= 0;
      if (count > 3) {
        return;
      }
      var hasTask = _descTasks.contains(uuid);
      if (hasTask) {
        return;
      }
      var device = DLNADevice();
      device
        ..usn = usn
        ..uuid = uuid
        ..location = location
        ..setCacheControl = cacheTime;
      _descTasks.add(device.uuid);
      await _getDescription(device, count, FROM_ADD);
    } else {
      var hasTask = _descTasks.contains(uuid);
      if (hasTask) {
        return;
      }
      var isLocationChang = (location != tmpDevice.location);
      var diff =
          DateTime.now().millisecondsSinceEpoch - tmpDevice.lastDescriptionTime;
      if (diff > DEVICE_DESCRIPTION_INTERVAL_TIME || isLocationChang) {
        tmpDevice
          ..usn = usn
          ..uuid = uuid
          ..location = location
          ..setCacheControl = cacheTime;
        _descTasks.add(uuid);
        await _getDescription(tmpDevice, 0, FROM_UPDATE);
      }
    }
  }

  void byeBye(String usn) {
    if (_disable) {
      return;
    }
    var split = usn.split('::').where((element) => element.isNotEmpty);
    if (split == null || split.isEmpty) {
      return;
    }
    _onRemove(split.first);
  }

  void _cacheAlive(DLNADevice device) async {
    if (_disable) {
      return;
    }
    var hasTask = _descTasks.contains(device.uuid);
    if (hasTask) {
      return;
    }
    _descTasks.add(device.uuid);
    await _getDescription(device, 0, FROM_CACHE_ADD);
  }

  void _checkAliveDevice(DLNADevice device, int count) {
    _descriptionParser.getDescription(device).then((value) {
      if (value == null) {
        if (count >= 3) {
          _onRemove(device.uuid);
        } else {
          Future.delayed(DEVICE_ALIVE_CHECK_RETRY_INTERVAL_TIME, () {
            _checkAliveDevice(device, count + 1);
          });
        }
      }
    }).catchError((e) {
      if (count >= 3) {
        _onRemove(device.uuid);
      } else {
        Future.delayed(DEVICE_ALIVE_CHECK_RETRY_INTERVAL_TIME, () {
          _checkAliveDevice(device, count + 1);
        });
      }
    });
  }

  Future<void> _getDescription(
      DLNADevice device, int tryCount, int type) async {
    try {
      var startTime = DateTime.now().millisecondsSinceEpoch;
      var desc = await _descriptionParser.getDescription(device);
      device.description = desc;
      var endTime = DateTime.now().millisecondsSinceEpoch;
      device.lastDescriptionTime = endTime;
      device.descriptionTaskSpendingTime = endTime - startTime;
      if (desc == null ||
          desc.avTransportControlURL == null ||
          desc.avTransportControlURL.isEmpty) {
        tryCount++;
        _onUnnecessary(device, tryCount);
        return;
      }
      switch (type) {
        case FROM_ADD:
          {
            _onAdd(device);
          }
          break;
        case FROM_UPDATE:
          {
            _onUpdate(device);
          }
          break;
        case FROM_CACHE_ADD:
          {
            _onCacheAdd(device);
          }
          break;
        default:
          {}
          break;
      }
    } catch (e) {
      _onSearchError(
          'getDescription\n' + device.toString() + '\n' + e.toString());
    }
  }

  void _onSearchError(String message) {
    _refresher?.onSearchError(message);
  }

  void _onUnnecessary(DLNADevice device, int count) {
    _unnecessaryDevices[device.location] = count;
    _descTasks.remove(device.uuid);
  }

  void _onAdd(DLNADevice device) {
    device.discoveryFromStartSpendingTime =
        DateTime.now().millisecondsSinceEpoch - _startSearchTime;
    device.isFromCache = false;
    _currentDevices[device.uuid] = device;
    if (_enableCache) {
      _localDeviceParser.saveDevices(_currentDevices);
    }
    _descTasks.remove(device.uuid);
    _refresher?.onDeviceAdd(device);
  }

  void _onCacheAdd(DLNADevice device) {
    device.discoveryFromStartSpendingTime =
        DateTime.now().millisecondsSinceEpoch - _startSearchTime;
    device.isFromCache = true;
    _currentDevices[device.uuid] = device;
    if (_enableCache) {
      _localDeviceParser.saveDevices(_currentDevices);
    }
    _descTasks.remove(device.uuid);
    _refresher?.onDeviceAdd(device);
  }

  void _onUpdate(DLNADevice device) {
    _currentDevices[device.uuid] = device;
    if (_enableCache) {
      _localDeviceParser.saveDevices(_currentDevices);
    }
    _descTasks.remove(device.uuid);
    _refresher?.onDeviceUpdate(device);
  }

  void _onRemove(String uuid) {
    DLNADevice device = _currentDevices.remove(uuid);
    if (device != null) {
      if (_enableCache) {
        _localDeviceParser.saveDevices(_currentDevices);
      }
      _refresher?.onDeviceRemove(device);
    }
  }
}
