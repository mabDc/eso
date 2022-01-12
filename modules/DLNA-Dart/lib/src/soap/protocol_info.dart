class ProtocolInfo {
  String source;
  List<ProtocolData> data;

  @override
  String toString() {
    return 'ProtocolInfo {source: $source, dataSize: ${data.length}}';
  }
}

class ProtocolData {
  String protocol = Protocol.ALL;
  String network = Protocol.ALL;
  String contentFormat = Protocol.ALL;
  String additionalInfo = Protocol.ALL;

  static List<ProtocolData> convert(String s) {
    var items = s.split(',');
    var list = List<ProtocolData>();
    for (var value in items) {
      var split = value.split(':');
      if (split.length != 4) {
        continue;
      }
      var protocolData = ProtocolData();
      protocolData.protocol = Protocol.value(split[0]);
      protocolData.network = split[1];
      protocolData.contentFormat = split[2];
      protocolData.additionalInfo = split[3];
      list.add(protocolData);
    }
    return list;
  }
}

class Protocol {
  static const String WILDCARD = "*";
  static const String ALL = WILDCARD;
  static const String HTTP_GET = "http-get";
  static const String RTSP_RTP_UDP = "rtsp-rtp-udp";
  static const String INTERNAL = "internal";
  static const String IEC61883 = "iec61883";
  static const String XBMC_GET = "xbmc-get";
  static const String OTHER = "other";
  static const LIST = {
    ALL,
    HTTP_GET,
    RTSP_RTP_UDP,
    INTERNAL,
    IEC61883,
    XBMC_GET,
    OTHER
  };

  static String value(String s) {
    if (LIST.contains(s)) {
      return s;
    } else {
      return OTHER;
    }
  }
}
