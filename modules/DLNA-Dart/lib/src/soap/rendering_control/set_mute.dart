import '../../dlna_action_result.dart';
import '../../dlna_device.dart';
import '../soap_action.dart';

class SetMute extends AbsDLNAAction<String> {
  bool mute = false;

  SetMute(bool mute, DLNADevice dlnaDevice) : super(dlnaDevice) {
    this.mute = mute;
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
    return dlnaDevice.description.renderingControlControlURL;
  }

  @override
  String getSoapAction() {
    return '\"urn:schemas-upnp-org:service:RenderingControl:1#SetMute\"';
  }

  @override
  String getXmlData() {
    var value = mute ? '1' : '0';
    return """<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
	<s:Body>
		<u:SetMute xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1">
			<InstanceID>0</InstanceID>
			<Channel>Master</Channel>
			<DesiredMute>$value</DesiredMute>
		</u:SetMute>
	</s:Body>
</s:Envelope>""";
  }
}
