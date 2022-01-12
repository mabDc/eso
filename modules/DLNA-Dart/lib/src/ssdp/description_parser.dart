import 'dart:convert';
import 'dart:io';

import 'package:xml2json/xml2json.dart';

import '../dlna_device.dart';

class DescriptionParser {
  static const String DEVICE_TYPE = "deviceType";
  static const String UDN = "UDN";
  static const String FRIEND_NAME = "friendlyName";
  static const String MANUFACTURER = "manufacturer";
  static const String MANUFACTURER_URL = "manufacturerURL";
  static const String MODEL_DESCRIPTION = "modelDescription";
  static const String MODEL_NAME = "modelName";
  static const String MODEL_URL = "modelURL";
  static const String SERVICE = "service";
  static const String SERVICE_TYPE = "serviceType";
  static const String SERVICE_ID = "serviceId";
  static const String CONTROL_URL = "controlURL";
  static const String EVENT_SUB_URL = "eventSubURL";
  static const String SCPDURL = "SCPDURL";

  static const String X_RCONTROLLER_DEVICEINFO = "x_rcontroller_deviceinfo";
  static const String X_RCONTROLLER_VERSION = "x_rcontroller_version";
  static const String X_RCONTROLLER_SERVICE = "x_rcontroller_service";
  static const String X_RCONTROLLER_SERVICETYPE = "x_rcontroller_servicetype";
  static const String X_RCONTROLLER_ACTIONLIST_URL =
      "x_rcontroller_actionlist_url";

  static const String AV_X_RCONTROLLER_DEVICEINFO =
      "av:x_rcontroller_deviceinfo";
  static const String AV_X_RCONTROLLER_VERSION = "av:x_rcontroller_version";
  static const String AV_X_RCONTROLLER_SERVICE = "av:x_rcontroller_service";
  static const String AV_X_RCONTROLLER_SERVICETYPE =
      "av:x_rcontroller_servicetype";
  static const String AV_X_RCONTROLLER_ACTIONLIST_URL =
      "av:x_rcontroller_actionlist_url";

  static const String AV_TRANSPORT =
      "urn:schemas-upnp-org:service:AVTransport:1";
  static const String RENDERING_CONTROL =
      "urn:schemas-upnp-org:service:RenderingControl:1";
  static const String CONNECTION_MANAGER =
      "urn:schemas-upnp-org:service:ConnectionManager:1";

  var httpClient = HttpClient();

  Future<DLNADescription> getDescription(DLNADevice dlnaDevice) async {
    String url = dlnaDevice.location;
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    var myTransformer = Xml2Json();
    myTransformer.parse(responseBody);
    String json = myTransformer.toParker();
    var source = jsonDecode(json);

    DLNADescription description = DLNADescription();
    var root = source['root'];
    var device = root['device'];

    description.deviceType = device[DEVICE_TYPE];
    description.friendlyName = device[FRIEND_NAME];
    description.udn = device[UDN];
    description.manufacturer = device[MANUFACTURER];
    description.manufacturerURL = device[MANUFACTURER_URL];
    description.modelDescription = device[MODEL_DESCRIPTION];
    description.modelName = device[MODEL_NAME];
    description.modelURL = device[MODEL_URL];

    var serviceList = device['serviceList'];
    if (serviceList != null) {
      var service = serviceList[SERVICE];
      if (service is List) {
        var dlnaServices = List<DLNAService>();
        for (var item in service) {
          var dlnaService = DLNAService();
          dlnaService.type = item[SERVICE_TYPE];
          dlnaService.serviceId = item[SERVICE_ID];
          dlnaService.SCPDUrl = item[SCPDURL];
          dlnaService.controlUrl = item[CONTROL_URL];
          dlnaService.eventSubUrl = item[EVENT_SUB_URL];
          dlnaServices.add(dlnaService);
          if (AV_TRANSPORT == dlnaService.type) {
            description.avTransportControlURL = dlnaService.controlUrl;
          } else if (RENDERING_CONTROL == dlnaService.type) {
            description.renderingControlControlURL = dlnaService.controlUrl;
          } else if (CONNECTION_MANAGER == dlnaService.type) {
            description.connectionManagerControlURL = dlnaService.controlUrl;
          }
        }
        description.dlnaServices = dlnaServices;
      }
    }
    return description;
  }

  void stop() {
    httpClient.close();
  }
}
