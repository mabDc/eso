import '../../dlna_action_result.dart';
import '../../dlna_device.dart';
import '../soap_action.dart';

class Previous extends AbsDLNAAction<String> {
  Previous(DLNADevice dlnaDevice) : super(dlnaDevice);

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
    return '\"urn:schemas-upnp-org:service:AVTransport:1#Previous\"';
  }

  @override
  String getXmlData() {
    return """<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
	<s:Body>
		<u:Previous xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
			<InstanceID>0</InstanceID>
		</u:Previous>
	</s:Body>
</s:Envelope>""";
  }
}
