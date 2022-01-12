import 'dart:async';

import 'package:connectivity/connectivity.dart';

class DLNAConnectivity {
  final connectivity = Connectivity();

  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void init(Function(bool available) callback) {
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi) {
        callback(true);
      } else {
        callback(false);
      }
    });
  }

  Future<bool> checkConnectivityStatus() async {
    return await (connectivity.checkConnectivity()) == ConnectivityResult.wifi;
  }

  void release() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}
