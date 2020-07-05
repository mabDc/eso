import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// eso 专用插件
class EsoPlugin {
  static const MethodChannel _channel =
      const MethodChannel('eso_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Map<Function, StreamSubscription> listeners = {};
  // ignore: close_sinks
  static StreamController<int> _volumeKeyboardIncListener = StreamController.broadcast();
  // ignore: close_sinks
  static StreamController<int> _volumeKeyboardDecListener = StreamController.broadcast();

  static void removeListener(dynamic onData) {
    StreamSubscription listener = listeners[onData];
    if (listener == null) return;
    listener.cancel();
    listeners.remove(onData);
  }



  /// 截获音量键盘
  static Future<void> captureVolumeKeyboard(bool enabled, {
    VolumeChangeEvent onVolumeInc,
    VolumeChangeEvent onVolumeDec,
  }) async {
    _channel.setMethodCallHandler(_handler);
    await _channel.invokeMethod('captureVolumeKeyboard', enabled ? 1 : 0);
    if (enabled == true) {
      if (onVolumeDec != null)
        listeners[onVolumeDec] = _volumeKeyboardIncListener.stream.listen(onVolumeDec);
      if (onVolumeInc != null)
        listeners[onVolumeInc] = _volumeKeyboardDecListener.stream.listen(onVolumeInc);
    } else {
      removeListener(onVolumeDec);
      removeListener(onVolumeInc);
    }
  }

  static List<VoidCallback> onVolumeInc, onVolumeDec;

  static Future<dynamic> _handler(MethodCall call) {
    String method = call.method;
    print("handler: $method, arguments: ${call.arguments}");
    switch (method) {
      case "keyboard_Volume_inc":
        {
          _volumeKeyboardIncListener.add(call.arguments);
        }
        break;
      case "keyboard_Volume_dec":
        {
          _volumeKeyboardDecListener.add(call.arguments);
        }
        break;
    }
    return new Future.value(null);
  }


}

typedef VolumeChangeEvent = void Function(int value);
