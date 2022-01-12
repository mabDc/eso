import 'dart:convert';

import 'package:xml2json/xml2json.dart';

import '../../dlna_action_result.dart';
import '../../dlna_device.dart';
import '../soap_action.dart';
import '../transport_info.dart';

class GetTransportInfo extends AbsDLNAAction<TransportInfo> {
  GetTransportInfo(DLNADevice dlnaDevice) : super(dlnaDevice);

  @override
  Future<DLNAActionResult<TransportInfo>> execute() async {
    var result = await start();
    if (result.success) {
      try {
        final myTransformer = Xml2Json();
        myTransformer.parse(result.httpContent);
        String json = myTransformer.toParker();
        var value = jsonDecode(json)['s:Envelope']['s:Body']
            ['u:GetTransportInfoResponse'];
        var info = TransportInfo()
          ..currentSpeed = value['CurrentSpeed']
          ..currentTransportState = value['CurrentTransportState']
          ..currentTransportStatus = value['CurrentTransportStatus'];
        result.result = info;
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
    return '\"urn:schemas-upnp-org:service:AVTransport:1#GetTransportInfo\"';
  }

  @override
  String getXmlData() {
    return """<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
	<s:Body>
		<u:GetTransportInfo xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
			<InstanceID>0</InstanceID>
		</u:GetTransportInfo>
	</s:Body>
</s:Envelope>""";
  }
}
