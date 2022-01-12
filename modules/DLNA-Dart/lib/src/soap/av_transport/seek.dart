import '../../dlna_action_result.dart';
import '../../dlna_device.dart';
import '../soap_action.dart';

class Seek extends AbsDLNAAction<String> {
  int time;

  Seek(int time, DLNADevice dlnaDevice) : super(dlnaDevice) {
    this.time = time;
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
    return '\"urn:schemas-upnp-org:service:AVTransport:1#Seek\"';
  }

  @override
  String getXmlData() {
    return """<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<s:Envelope s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
	<s:Body>
		<u:Seek xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
			<InstanceID>0</InstanceID>
			<Unit>REL_TIME</Unit>
			<Target>${_seconds2String(time)}</Target>
		</u:Seek>
	</s:Body>
</s:Envelope>""";
  }

  String _seconds2String(int time) {
    if (time <= 0) {
      return '00:00:00';
    }
    var seconds = (time % 60).truncate();
    var minutes = (time / 60 % 60).truncate();
    var hours = (time / 3600).truncate();
    var secondsStr = seconds.toString().padLeft(2, '0');
    var minutesStr = minutes.toString().padLeft(2, '0');
    var hoursStr = hours.toString().padLeft(2, '0');
    return '$hoursStr:$minutesStr:$secondsStr';
  }
}
