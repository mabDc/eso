import 'dart:convert';

import 'package:xml2json/xml2json.dart';

import '../../dlna_action_result.dart';
import '../../dlna_device.dart';
import '../device_capabilities.dart';
import '../soap_action.dart';

class GetDeviceCapabilities extends AbsDLNAAction<DeviceCapabilities> {
  GetDeviceCapabilities(DLNADevice dlnaDevice) : super(dlnaDevice);

  @override
  Future<DLNAActionResult<DeviceCapabilities>> execute() async {
    var result = await start();
    if (result.success) {
      try {
        final myTransformer = Xml2Json();
        myTransformer.parse(result.httpContent);
        String json = myTransformer.toParker();
        var value = jsonDecode(json)['s:Envelope']['s:Body']
            ['u:GetCapabilitiesResponse'];
        var deviceCapabilities = DeviceCapabilities()
          ..playMedia = value['PlayMedia']?.toString()?.split(',')
          ..recMedia = value['RecMedia']?.toString()?.split(',')
          ..recQualityModes = value['RecqualityModes']?.toString()?.split(',');
        result.result = deviceCapabilities;
      } catch (e) {
        result.success = false;
        result.errorMessage = e.toString();
      }
    }
    return result;
  }

  @override
  String getControlURL() {
    return dlnaDevice.description.avTransportControlURL;
  }

  @override
  String getSoapAction() {
    return '\"urn:schemas-upnp-org:service:AVTransport:1#GetDeviceCapabilities\"';
  }

  @override
  String getXmlData() {
    return """<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
	<s:Body>
		<u:GetDeviceCapabilities xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
			<InstanceID>0</InstanceID>
		</u:GetDeviceCapabilities>
	</s:Body>
</s:Envelope>""";
  }
}
