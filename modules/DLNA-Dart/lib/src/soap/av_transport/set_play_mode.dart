import '../../dlna_action_result.dart';
import '../../dlna_device.dart';
import '../play_mode.dart';
import '../soap_action.dart';

class SetPlayMode extends AbsDLNAAction<String> {
  PlayMode playMode;

  SetPlayMode(PlayMode playMode, DLNADevice dlnaDevice) : super(dlnaDevice) {
    this.playMode = playMode;
  }

  @override
  Future<DLNAActionResult<String>> execute() async {
    var result = await start();
    if (result.success) {
      result.result = result.httpContent;
    }
    return result;
  }

  @override
  String getControlURL() {
    return dlnaDevice.description.avTransportControlURL;
  }

  @override
  String getSoapAction() {
    return '\"urn:schemas-upnp-org:service:AVTransport:1#SetPlayMode\"';
  }

  @override
  String getXmlData() {
    return """<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
	<s:Body>
		<u:SetPlayMode xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
			<InstanceID>0</InstanceID>
			<NewPlayMode>${playMode.name}</NewPlayMode>
		</u:SetPlayMode>
	</s:Body>
</s:Envelope>""";
  }
}
