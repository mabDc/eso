import '../../dlna_action_result.dart';
import '../../dlna_device.dart';
import '../soap_action.dart';

class SetVolume extends AbsDLNAAction<String> {
  int volume = 0;

  SetVolume(int volume, DLNADevice dlnaDevice) : super(dlnaDevice) {
    this.volume = volume;
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
    return '\"urn:schemas-upnp-org:service:RenderingControl:1#SetVolume\"';
  }

  @override
  String getXmlData() {
    return """<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
	<s:Body>
		<u:SetVolume xmlns:u="urn:schemas-upnp-org:service:RenderingControl:1">
			<InstanceID>0</InstanceID>
			<Channel>Master</Channel>
			<DesiredVolume>$volume</DesiredVolume>
		</u:SetVolume>
	</s:Body>
</s:Envelope>""";
  }
}
