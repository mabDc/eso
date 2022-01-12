import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef NetworkInterfacesFactory = Future<Iterable<NetworkInterface>> Function(
    InternetAddressType type);

typedef RawDatagramSocketFactory = Future<RawDatagramSocket> Function(
    dynamic host, int port,
    {bool reuseAddress, bool reusePort, int ttl});

class SSDPController {
  static const String UPNP_IP_V4 = '239.255.255.250';
  static const int UPNP_PORT = 1900;
  static const String DLNA_M_SEARCH = 'M-SEARCH * HTTP/1.1\r\n' +
      'ST: ssdp:all\r\n' +
      'HOST: 239.255.255.250:1900\r\n' +
      'MX: 3\r\n' +
      'MAN: \"ssdp:discover\"\r\n\r\n';

  static NetworkInterfacesFactory allInterfacesFactory =
      (InternetAddressType type) => NetworkInterface.list(
            includeLinkLocal: true,
            type: type,
            includeLoopback: true,
          );

  final InternetAddress UPNP_AddressIPv4 = InternetAddress(UPNP_IP_V4);
  final InternetAddress UPNP_AddressIPv6 = InternetAddress('FF02::FB');

  bool _starting = false;
  bool _started = false;

  InternetAddress _address;
  int _port;
  Timer _timer;
  RawDatagramSocket _incoming;
  final List<RawDatagramSocket> _sockets = <RawDatagramSocket>[];
  final RawDatagramSocketFactory _rawDatagramSocketFactory;
  final StreamController<String> controller = StreamController<String>();

  SSDPController({
    RawDatagramSocketFactory rawDatagramSocketFactory = RawDatagramSocket.bind,
  }) : _rawDatagramSocketFactory = rawDatagramSocketFactory {
    _address = UPNP_AddressIPv4;
    _port = UPNP_PORT;
  }

  Future<void> start() async {
    if (_started || _starting) {
      return;
    }
    _starting = true;

    _incoming = await _rawDatagramSocketFactory(
      InternetAddress.anyIPv4.address,
      _port,
      reuseAddress: true,
      reusePort: true,
      ttl: 255,
    );
    _sockets.add(_incoming);

    final List<NetworkInterface> interfaces =
        await allInterfacesFactory(InternetAddress.anyIPv4.type);
    for (var interface in interfaces) {
      var targetAddress = interface.addresses[0];
      var socket = await _rawDatagramSocketFactory(
        targetAddress,
        _port,
        reuseAddress: true,
        reusePort: true,
        ttl: 255,
      );
      socket.multicastLoopback = false;
      socket.setRawOption(RawSocketOption(
        RawSocketOption.levelIPv4,
        RawSocketOption.IPv4MulticastInterface,
        targetAddress.rawAddress,
      ));
      _sockets.add(socket);

      _incoming.multicastLoopback = false;
      _incoming.multicastHops = 12;
      _incoming.joinMulticast(_address, interface);
    }
    _incoming.listen(_handleIncoming);
    _started = true;
    _starting = false;
  }

  void stop() {
    if (!_started) {
      return;
    }
    if (_starting) {
      throw StateError('Cannot stop mDNS client while it is starting.');
    }
    if (_timer != null) {
      _timer.cancel();
    }
    controller.close();
    for (var socket in _sockets) {
      socket.close();
    }
    _started = false;
  }

  void send() {
    if (!_started) {
      throw StateError('mDNS client must be started before calling lookup.');
    }
    _sockets.forEach((socket) {
      print('Sending from ${socket.address.address}:${socket.port}');
    });
    var dataToSend = Utf8Codec().encode(DLNA_M_SEARCH);
    _timer = Timer.periodic(const Duration(milliseconds: 3000), (Timer t) {
      for (var socket in _sockets) {
        socket.send(dataToSend, _address, _port);
      }
    });
  }

  void _handleIncoming(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      var packet = _incoming.receive().data;
      var message = utf8.decode(packet);
      controller.add(message);
    }
  }

  Future<void> startSearch() async {
    await start();
    send();
  }

  void listen(void Function(String event) onData) {
    if (controller.isClosed) {
      return;
    }
    controller.stream.listen(onData);
  }
}
