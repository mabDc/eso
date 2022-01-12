import 'dart:async';

import 'package:dlna/src/didl.dart';
import 'package:dlna/src/dlna_action_result.dart';
import 'package:dlna/src/dlna_connectivity.dart';
import 'package:dlna/src/dlna_device.dart';
import 'package:dlna/src/soap/play_mode.dart';
import 'package:dlna/src/soap/position_info.dart';
import 'package:dlna/src/soap/soap_controller.dart';
import 'package:dlna/src/soap/transport_actions.dart';
import 'package:dlna/src/ssdp/ssdp_controller.dart';
import 'package:dlna/src/ssdp/upnp_message_parser.dart';

import 'soap/device_capabilities.dart';
import 'soap/media_info.dart';
import 'soap/protocol_info.dart';
import 'soap/transport_info.dart';
import 'ssdp/device_manager.dart';

class DLNAManager {
  SSDPController _ssdpController;
  DiscoveryDeviceManger _deviceManger;
  DiscoveryContentParser _contentParser;

  final SOAPController _soapController = SOAPController();
  final DLNAConnectivity _dlnaConnectivity = DLNAConnectivity();

  bool _isRelease = false;
  bool _inSearch = false;
  bool _hasSearched = false;

  DLNAManager() {
    _deviceManger = DiscoveryDeviceManger();
    _contentParser = DiscoveryContentParser(
        processAlive: (String usn, String location, String cache) {
      _deviceManger.alive(usn, location, cache);
    }, processByeBye: (String usn) {
      _deviceManger.byeBye(usn);
    });
    _dlnaConnectivity.init((bool available) {
      if (available) {
        if (_hasSearched && !_inSearch) {
          _search();
        }
      } else {
        _stop(false);
      }
    });
  }

  void enableCache() {
    _deviceManger.enableCache();
  }

  Future<List<DLNADevice>> getLocalDevices() async {
    return _deviceManger.getLocalDevices();
  }

  void setRefresher(DeviceRefresher refresher) {
    _deviceManger.setRefresh(refresher);
    _soapController.setRefresh(refresher);
  }

  void startSearch() async {
    if (_inSearch || _isRelease) {
      return;
    }
    if (await _dlnaConnectivity.checkConnectivityStatus()) {
      _search();
    }
  }

  void stopSearch() {
    _stop(true);
  }

  Future<void> _search() async {
    _inSearch = true;
    _hasSearched = true;
    _ssdpController = SSDPController();
    _deviceManger.enable();
    await _ssdpController.startSearch();
    _ssdpController.listen((event) {
      _contentParser.startParse(event);
    });
  }

  void _stop(bool requestFromUser) {
    _deviceManger.disable();
    if (_ssdpController != null) {
      _ssdpController.stop();
      _ssdpController = null;
    }
    if (requestFromUser) {
      _hasSearched = false;
    }
    _inSearch = false;
  }

  void forceSearch() {
    stopSearch();
    startSearch();
  }

  void setDevice(DLNADevice currentDevice) {
    _soapController.currentDevice = currentDevice;
  }

  void release() {
    _isRelease = true;
    _dlnaConnectivity.release();
    stopSearch();
    _deviceManger.release();
    _soapController.release();
  }

  Future<DLNAActionResult<String>> actSetVideoUrl(
      VideoObject didlObject) async {
    return await _soapController.setUrl(didlObject);
  }

  Future<DLNAActionResult<String>> actSetAudioUrl(
      AudioObject didlObject) async {
    return await _soapController.setUrl(didlObject);
  }

  Future<DLNAActionResult<String>> actSetImageUrl(
      ImageObject didlObject) async {
    return await _soapController.setUrl(didlObject);
  }

  Future<DLNAActionResult<String>> actPlay() async {
    return await _soapController.play();
  }

  Future<DLNAActionResult<String>> actPause() async {
    return await _soapController.pause();
  }

  Future<DLNAActionResult<String>> actStop() async {
    return await _soapController.stop();
  }

  Future<DLNAActionResult<String>> actSeek(int time) async {
    return await _soapController.seek(time);
  }

  Future<DLNAActionResult<PositionInfo>> actGetPositionInfo() async {
    return await _soapController.getPositionInfo();
  }

  Future<DLNAActionResult<String>> actNext() async {
    return await _soapController.next();
  }

  Future<DLNAActionResult<String>> actPrevious() async {
    return await _soapController.previous();
  }

  Future<DLNAActionResult<String>> actSetPlayMode(PlayMode playMode) async {
    return await _soapController.setPlayMode(playMode);
  }

  Future<DLNAActionResult<TransportInfo>> actGetTransportInfo() async {
    return await _soapController.getTransportInfo();
  }

  Future<DLNAActionResult<TransportActions>> actGetTransportActions() async {
    return await _soapController.getTransportActions();
  }

  Future<DLNAActionResult<DeviceCapabilities>>
      actGetDeviceCapabilities() async {
    return await _soapController.getDeviceCapabilities();
  }

  Future<DLNAActionResult<MediaInfo>> actGetMediaInfo() async {
    return await _soapController.getMediaInfo();
  }

  Future<DLNAActionResult<ProtocolInfo>> actGetProtocolInfo() async {
    return await _soapController.getProtocolInfo();
  }

  Future<DLNAActionResult<bool>> actGetMute() async {
    return await _soapController.getMute();
  }

  Future<DLNAActionResult<String>> actSetMute(bool mute) async {
    return await _soapController.setMute(mute);
  }

  Future<DLNAActionResult<int>> actGetVolume() async {
    return await _soapController.getVolume();
  }

  Future<DLNAActionResult<String>> actSetVolume(int volume) async {
    return await _soapController.setVolume(volume);
  }
}

class DeviceRefresher {
  Function(DLNADevice device) onDeviceAdd;
  Function(DLNADevice device) onDeviceRemove;
  Function(DLNADevice device) onDeviceUpdate;
  Function(String message) onSearchError;

  Function(PositionInfo positionInfo) onPlayProgress;

  DeviceRefresher(
      {this.onDeviceAdd,
      this.onDeviceRemove,
      this.onDeviceUpdate,
      this.onSearchError,
      this.onPlayProgress});
}
