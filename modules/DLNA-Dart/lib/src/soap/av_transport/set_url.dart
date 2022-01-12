import 'dart:async';
import 'dart:convert';

import '../../../dlna.dart';
import '../../didl.dart';
import '../../dlna_action_result.dart';
import '../../dlna_device.dart';
import '../position_info.dart';
import '../soap_action.dart';
import 'get_position_info.dart';
import 'get_transport_info.dart';
import 'play.dart';
import 'stop.dart';

class SetUrl extends AbsDLNAAction<String> {
  static const MAX_RETRY_COUNT = 7;
  static const POLLING_INTERVAL = 1000;
  static const MAX_POLLING_CHECK_THRESHOLD =
      30; // 30 * MAX_POLLING_INTERVAL = 30s
  static const MAX_POLLING_STOP_THRESHOLD = 600;

  StreamController<PositionInfo> _controller;
  Timer _timer;
  int retryCount = 0;
  int unresponsiveCount = 0;
  int lastCurrentElapsed = 0;

  DIDLObject didlObject;
  Function(PositionInfo positionInfo) progress;

  SetUrl(DLNADevice dlnaDevice, DIDLObject didlObject) : super(dlnaDevice) {
    this.didlObject = didlObject;
  }

  @override
  Future<DLNAActionResult<String>> execute() async {
    if (dlnaDevice.isXiaoMiDevice) {
      await Stop(dlnaDevice).execute();
    }
    var result = await start();
    if (result.success) {
      result.result = result.httpContent;
      await Play(dlnaDevice).execute();
      if (didlObject.refreshPosition) {
        _controller = StreamController<PositionInfo>();
        _timer = Timer.periodic(const Duration(milliseconds: POLLING_INTERVAL),
            (Timer t) async {
          if (retryCount > MAX_RETRY_COUNT) {
            stopPollingPos();
            return;
          }
          var posInfoAction = await GetPositionInfo(dlnaDevice).execute();
          var posInfo = posInfoAction.result;
          if (posInfoAction.success && posInfo != null) {
            if (posInfo.relTime == PositionInfo.NOT_IMPLEMENTED) {
              retryCount++;
              return;
            }
            if (unresponsiveCount > MAX_POLLING_CHECK_THRESHOLD) {
              var transportInfoAction =
                  await GetTransportInfo(dlnaDevice).execute();
              if (transportInfoAction.success &&
                  transportInfoAction.result.currentTransportState ==
                      TransportState.STOPPED) stopPollingPos();
              return;
            }

            if (unresponsiveCount > MAX_POLLING_STOP_THRESHOLD) {
              stopPollingPos();
              return;
            }

            posInfo.title = didlObject.title;
            posInfo.url = didlObject.url;

            // The xiaomi box may return the correct track elapsed time, but has no correct duration time
            var currentElapsed = posInfo.trackElapsedSeconds;
            // long currentDuration = positionInfo.getTrackDurationSeconds();
            if (currentElapsed == 0) {
              retryCount++;
              return;
            } else {
              if (currentElapsed == lastCurrentElapsed) {
                unresponsiveCount++;
              } else {
                unresponsiveCount = 0;
              }
              _controller.add(posInfo);
            }
            lastCurrentElapsed = currentElapsed;
          } else {
            retryCount++;
          }
        });
      }
    }
    return result;
  }

  void listenPositionInfo(void Function(PositionInfo positionInfo) onData) {
    if (_controller == null || _controller.isClosed) {
      return;
    }
    _controller.stream.listen(onData);
  }

  void stopPollingPos() {
    if (_controller != null && !_controller.isClosed) {
      _controller.close();
      _controller = null;
    }
    _timer?.cancel();
    _timer = null;
  }

  @override
  String getControlURL() {
    return dlnaDevice.description.avTransportControlURL;
  }

  @override
  String getXmlData() {
    var time = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch);
    var title = HtmlEscape().convert(didlObject.title);
    var url = HtmlEscape().convert(didlObject.url);
    return """<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
<s:Body>
<u:SetAVTransportURI xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
<InstanceID>0</InstanceID>
<CurrentURI>$url</CurrentURI>
<CurrentURIMetaData>
  <DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/" xmlns:dlna="urn:schemas-dlna-org:metadata-1-0/">
	  <item id="id" parentID="0" restricted="0">
		  <dc:title>$title</dc:title>
		  <upnp:artist>unknow</upnp:artist>
      <upnp:class>object.item.videoItem</upnp:class>
		  <dc:date>$time</dc:date>
		  <res protocolInfo="${didlObject.protocol}">$url</res>
	  </item>
  </DIDL-Lite>
</CurrentURIMetaData>
</u:SetAVTransportURI>
</s:Body>
</s:Envelope>""";
  }

  @override
  String getSoapAction() {
    return '\"urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI\"';
  }
}
