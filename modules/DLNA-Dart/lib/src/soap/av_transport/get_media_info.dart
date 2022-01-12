import 'dart:convert';

import 'package:xml2json/xml2json.dart';

import '../../dlna_action_result.dart';
import '../../dlna_device.dart';
import '../media_info.dart';
import '../soap_action.dart';

class GetMediaInfo extends AbsDLNAAction<MediaInfo> {
  GetMediaInfo(DLNADevice dlnaDevice) : super(dlnaDevice);

  @override
  Future<DLNAActionResult<MediaInfo>> execute() async {
    var result = await start();
    if (result.success) {
      try {
        var myTransformer = Xml2Json();
        myTransformer.parse(result.httpContent);
        String json = myTransformer.toParker();
        var value =
            jsonDecode(json)['s:Envelope']['s:Body']['u:GetMediaInfoResponse'];
        var mediaInfo = MediaInfo()
          ..numberOfTracks = value['NrTracks']
          ..mediaDuration = value['MediaDuration']
          ..currentURI = value['CurrentURI']
          ..currentURIMetaData = value['CurrentURIMetaData']
          ..nextURI = value['NextURI']
          ..nextURIMetaData = value['NextURIMetaData']
          ..playMedium = value['PlayMedium']
          ..recordMedium = value['RecordMedium']
          ..writeStatus = value['WriteStatus'];
        result.result = mediaInfo;
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
    return '\"urn:schemas-upnp-org:service:AVTransport:1#GetMediaInfo\"';
  }

  @override
  String getXmlData() {
    return """<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
	<s:Body>
		<u:GetMediaInfo xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
			<InstanceID>0</InstanceID>
		</u:GetMediaInfo>
	</s:Body>
</s:Envelope>""";
  }
}
