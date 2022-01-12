class DiscoveryContentParser {
  static const SSDP_MSG_ALIVE = 'ssdp:alive';
  static const SSDP_MSG_BYE_BYE = 'ssdp:byebye';

  Function(String usn, String location, String cache) processAlive;
  Function(String usn) processByeBye;

  DiscoveryContentParser({this.processAlive, this.processByeBye});

  void startParse(String message) {
    var messageLines = message.split('\r\n');
    if (messageLines.length < 3) {
      return;
    }
    var firstLine = messageLines.first;
    var firstLineParameter = firstLine.split(' ').first;
    if (firstLineParameter.startsWith('HTTP/1.')) {
      var httpProtocol = firstLine[2];
      if (httpProtocol == 'OK') {
        readSearchResponseMessage(messageLines);
      }
    } else {
      if (firstLineParameter == 'NOTIFY') {
        readNotifyMessage(messageLines);
      } else if (firstLineParameter != 'M-SEARCH') {}
    }
  }

  void readSearchResponseMessage(List<String> lines) {
    resolveContent(lines,
        (String usn, String location, String cache, String nts) {
      if (usn != null &&
          usn.isNotEmpty &&
          location != null &&
          location.isNotEmpty &&
          cache != null &&
          cache.isNotEmpty) {
        processAlive(usn, location, cache);
      }
    });
  }

  void readNotifyMessage(List<String> lines) {
    resolveContent(lines,
        (String usn, String location, String cache, String nts) {
      if (usn != null && usn.isNotEmpty) {
        if (nts == SSDP_MSG_ALIVE) {
          if (location != null &&
              location.isNotEmpty &&
              cache != null &&
              cache.isNotEmpty) {
            processAlive(usn, location, cache);
          }
        } else if (nts == SSDP_MSG_BYE_BYE) {
          processByeBye(usn);
        }
      }
    });
  }

  void resolveContent(List<String> lines,
      Function(String usn, String location, String cache, String nts) onData) {
    String usn;
    String location;
    String cache;
    String nts;
    lines.forEach((element) {
      if (element.isNotEmpty) {
        var header = element.split(': ');
        if (header.length >= 2) {
          if (header.first.toLowerCase() == 'usn') {
            usn = header[1];
          } else if (header.first.toLowerCase() == 'location') {
            location = header[1];
          } else if (header.first.toLowerCase() == 'cache-control') {
            cache = header[1];
          } else if (header.first.toLowerCase() == 'nts') {
            nts = header[1];
          }
        }
      }
    });
    onData(usn, location, cache, nts);
  }
}
