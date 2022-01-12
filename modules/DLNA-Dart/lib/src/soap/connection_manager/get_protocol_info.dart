import 'dart:convert';

import 'package:xml2json/xml2json.dart';

import '../../dlna_action_result.dart';
import '../../dlna_device.dart';
import '../protocol_info.dart';
import '../soap_action.dart';

class GetProtocolInfo extends AbsDLNAAction<ProtocolInfo> {
  GetProtocolInfo(DLNADevice dlnaDevice) : super(dlnaDevice);

  @override
  Future<DLNAActionResult<ProtocolInfo>> execute() async {
    var result = await start();
    if (result.success) {
      try {
        final myTransformer = Xml2Json();
        myTransformer.parse(result.httpContent);
        String json = myTransformer.toParker();
        var value = jsonDecode(json)['s:Envelope']['s:Body']
            ['u:GetProtocolInfoResponse'];
        var source = value['Source'];
        var sink = value['Sink'];
        var protocolInfo = ProtocolInfo();
        protocolInfo.source = source;
        protocolInfo.data = ProtocolData.convert(sink);
        result.result = protocolInfo;
      } catch (e) {
        result.success = false;
        result.errorMessage = e.toString();
      }
    }
    return result;
  }

  @override
  String getControlURL() {
    return dlnaDevice.description.connectionManagerControlURL;
  }

  @override
  String getSoapAction() {
    return '\"urn:schemas-upnp-org:service:ConnectionManager:1#GetProtocolInfo\"';
  }

  @override
  String getXmlData() {
    return """<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
	<s:Body>
		<u:GetProtocolInfo xmlns:u="urn:schemas-upnp-org:service:ConnectionManager:1" />
	</s:Body>
</s:Envelope>""";
  }
}
