import '../didl.dart';
import '../dlna_action_result.dart';
import '../dlna_device.dart';
import '../dlna_manager.dart';
import 'av_transport/get_deivce_capabilities.dart';
import 'av_transport/get_media_info.dart';
import 'av_transport/get_position_info.dart';
import 'av_transport/get_transport_acts.dart';
import 'av_transport/get_transport_info.dart';
import 'av_transport/next.dart';
import 'av_transport/pause.dart';
import 'av_transport/play.dart';
import 'av_transport/previous.dart';
import 'av_transport/seek.dart';
import 'av_transport/set_play_mode.dart';
import 'av_transport/set_url.dart';
import 'av_transport/stop.dart';
import 'connection_manager/get_protocol_info.dart';
import 'device_capabilities.dart';
import 'media_info.dart';
import 'play_mode.dart';
import 'position_info.dart';
import 'protocol_info.dart';
import 'rendering_control/get_mute.dart';
import 'rendering_control/get_volume.dart';
import 'rendering_control/set_mute.dart';
import 'rendering_control/set_volume.dart';
import 'transport_actions.dart';
import 'transport_info.dart';

class SOAPController {
  DeviceRefresher _refresher;
  DLNADevice currentDevice;
  SetUrl setUrlTask;

  void setRefresh(DeviceRefresher refresher) {
    _refresher = refresher;
  }

  Future<DLNAActionResult<String>> setUrl(DIDLObject didlObject) async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    setUrlTask?.stopPollingPos();
    setUrlTask = SetUrl(currentDevice, didlObject);
    var result = await setUrlTask.execute();
    if (result.success && didlObject.refreshPosition) {
      setUrlTask.listenPositionInfo((PositionInfo info) {
        _refresher?.onPlayProgress(info);
      });
    }
    return result;
  }

  Future<DLNAActionResult<String>> play() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await Play(currentDevice).execute();
  }

  Future<DLNAActionResult<String>> pause() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await Pause(currentDevice).execute();
  }

  Future<DLNAActionResult<String>> stop() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await Stop(currentDevice).execute();
  }

  Future<DLNAActionResult<String>> seek(int time) async {
    if (currentDevice == null || time == null) {
      return DLNAActionResult.error();
    }
    return await Seek(time, currentDevice).execute();
  }

  Future<DLNAActionResult<PositionInfo>> getPositionInfo() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await GetPositionInfo(currentDevice).execute();
  }

  Future<DLNAActionResult<String>> next() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await Next(currentDevice).execute();
  }

  Future<DLNAActionResult<String>> previous() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await Previous(currentDevice).execute();
  }

  Future<DLNAActionResult<String>> setPlayMode(PlayMode playMode) async {
    if (currentDevice == null || playMode == null) {
      return DLNAActionResult.error();
    }
    return await SetPlayMode(playMode, currentDevice).execute();
  }

  Future<DLNAActionResult<TransportInfo>> getTransportInfo() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await GetTransportInfo(currentDevice).execute();
  }

  Future<DLNAActionResult<TransportActions>> getTransportActions() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await GetTransportActs(currentDevice).execute();
  }

  Future<DLNAActionResult<DeviceCapabilities>> getDeviceCapabilities() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await GetDeviceCapabilities(currentDevice).execute();
  }

  Future<DLNAActionResult<MediaInfo>> getMediaInfo() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await GetMediaInfo(currentDevice).execute();
  }

  Future<DLNAActionResult<ProtocolInfo>> getProtocolInfo() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await GetProtocolInfo(currentDevice).execute();
  }

  Future<DLNAActionResult<bool>> getMute() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await GetMute(currentDevice).execute();
  }

  Future<DLNAActionResult<String>> setMute(bool mute) async {
    if (currentDevice == null || mute == null) {
      return DLNAActionResult.error();
    }
    return await SetMute(mute, currentDevice).execute();
  }

  Future<DLNAActionResult<int>> getVolume() async {
    if (currentDevice == null) {
      return DLNAActionResult.error();
    }
    return await GetVolume(currentDevice).execute();
  }

  Future<DLNAActionResult<String>> setVolume(int volume) async {
    if (currentDevice == null || volume == null || volume < 0) {
      return DLNAActionResult.error();
    }
    return await SetVolume(volume, currentDevice).execute();
  }

  void release() {
    currentDevice = null;
    _refresher = null;
    setUrlTask?.stopPollingPos();
    setUrlTask = null;
  }
}
