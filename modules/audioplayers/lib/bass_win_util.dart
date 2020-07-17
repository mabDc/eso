import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ffi';
import 'package:audioplayers/audioplayers.dart';
import 'package:ffi/ffi.dart' as ffi;
import 'package:flutter/services.dart';

// by yangyxd 2020.07.16
class BassWinUtil {
  static DynamicLibrary _library;
  static int floatable = 0;
  static bool isInit = false;

  static void windowsInit() {
    if (_library != null) return;
    final dll = "bass.dll";
    try {
      _library = DynamicLibrary.open(dll);
    } catch (e) {
      stderr.writeln('Failed to load $dll');
      rethrow;
    }
  }

  static int BASS_SAMPLE_FLOAT = 256;
  static int BASS_SAMPLE_LOOP = 4;
  static int BASS_MUSIC_LOOP = BASS_SAMPLE_LOOP;
  static int BASS_MUSIC_RAMPS = 0x400;
  static int BASS_UNICODE = 0x80000000;
  static int BASS_POS_BYTE = 0;
  static int BASS_ACTIVE_STOPPED = 0;
  static int BASS_ACTIVE_PLAYING = 1;
  static int BASS_ACTIVE_STALLED = 2;
  static int BASS_ACTIVE_PAUSED = 3;
  static int BASS_ACTIVE_PAUSED_DEVICE = 4;
  static Pointer<void> nil = Pointer.fromAddress(0);

  static int lastId;
  static ReleaseMode releaseMode;
  static Future<dynamic> Function(MethodCall call) handler;
  static Timer timer;
  /// 0 or null 停止, 1 播放中, 2 暂停
  static int lastState, newState;
  static String curPlayerId;
  static final Map<String, int> player = Map<String, int>();

  static void setMethodCallHandler(String playerId, Future<dynamic> handler(MethodCall call)) {
    BassWinUtil.handler = handler;
    curPlayerId = playerId;
    player.forEach((key, value) {
      stop(value);
    });
    player.clear();
    player[playerId] = 0;
  }

  static void clearTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }
  
  static void initTimer() {
    clearTimer();
    timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (lastState != newState) {
        lastState = newState ?? 0;
        if (handler == null) return;
        switch (lastState) {
          case 0:
            break;
          case 1:
            handler(MethodCall("audio.onNotificationPlayerStateChanged", {
              "playerId": curPlayerId,
              "value": true,
            }));
            break;
          case 2:
            handler(MethodCall("audio.onNotificationPlayerStateChanged", {
              "playerId": curPlayerId,
              "value": false,
            }));
            break;
        }
      } else if (lastState == 1) {
        if (player[curPlayerId] != lastId) {
          player[curPlayerId] = lastId;
        }
        if (lastId != null && lastId != 0) {
          final value = getCurrentPosition(lastId);
          handler(MethodCall("audio.onCurrentPosition", {
            "playerId": curPlayerId,
            "value": (value * 1000).toInt(),
          }));
          final _state = isActive(lastId);
          var _newState;
          if (_state == BASS_ACTIVE_STOPPED)
            _newState = 0;
          else if (_state == BASS_ACTIVE_PLAYING)
            _newState = 1;
          else if (_state == BASS_ACTIVE_PAUSED)
            _newState = 2;
          if (_newState == 0) {
            handler(MethodCall("audio.onComplete", {
              "playerId": curPlayerId,
            }));
          }
          if (_newState != newState)
            newState = _newState;
        }
      }
    });
  }

  static int lastErrorCode() {
    final int Function() BASS_ErrorGetCode =
      _library.lookup<NativeFunction<Uint32 Function()>>("BASS_ErrorGetCode").asFunction();
    final code = BASS_ErrorGetCode();
    if (code != 0 && handler != null) {
      String msg = "unknown error";
      switch (code) {
        case 1: msg = 'memory error'; break;
        case 2: msg = "can't open the file"; break;
        case 3: msg = "can't find a free sound driver"; break;
        case 4: msg = "the sample buffer was lost"; break;
        case 5: msg = 'invalid handle'; break;
        case 6: msg = 'unsupported sample format'; break;
        case 7: msg = 'invalid position'; break;
        case 8: msg = 'BASS_Init has not been successfully called'; break;
        case 9: msg = 'BASS_Start has not been successfully called'; break;
        case 14: msg = 'already initialized/paused/whatever'; break;
        case 17: msg = 'file does not contain audio'; break;
        case 18: msg = "can't get a free channel"; break;
        case 19: msg = 'an illegal type was specified'; break;
        case 20: msg = 'an illegal parameter was specified'; break;
        case 23: msg = 'illegal device number'; break;
        case 24: msg = 'not playing'; break;
        case 25: msg = 'illegal sample rate'; break;
        case 27: msg = 'the stream is not a file stream'; break;
        case 29: msg = 'no hardware voices available'; break;
        case 40: msg = 'connection timedout'; break;
        case 32: msg = 'no internet connection could be opened'; break;
        case 41: msg = 'unsupported file format'; break;
        case 42: msg = 'unavailable speaker'; break;
        case 43: msg = 'invalid BASS version (used by add-ons)'; break;
        case 44: msg = 'codec is not available/supported'; break;
      }
      handler(MethodCall("audio.onError", {
        "playerId": curPlayerId,
        "value": "$msg($code)",
      }));
    }
    return code;
  }

  static int init({bool isLocal = false, double volume = 1.0, String url}) {
    windowsInit();
    clearTimer();
    if (_library == null) return 0;
    final int Function() BASS_GetVersion =
        _library.lookup<NativeFunction<Int32 Function()>>("BASS_GetVersion").asFunction();
    print("bass version: ${BASS_GetVersion()}");
    if (isInit != true) {
      final int Function(int, int, int, int, Pointer<void>) BASS_Init =
        _library.lookup<NativeFunction<Int32 Function(Int32, Uint32, Uint32, Uint32, Pointer<void>)>>("BASS_Init").asFunction();
      var i = BASS_Init(-1, 44100, 0, 0, Pointer.fromAddress(0));
      isInit = i != 0;
      if (!isInit)
        return 0;
      final int Function(int, int, int, Pointer<void>, Pointer<void>) BASS_StreamCreate =
      _library.lookup<NativeFunction<Uint32 Function(Uint32, Uint32, Uint32, Pointer<void>, Pointer<void>)>>("BASS_StreamCreate").asFunction();
      floatable = BASS_StreamCreate(44100, 2, BASS_SAMPLE_FLOAT, nil, nil);
      if (floatable > 0) {
        final void Function(int) BASS_StreamFree =
          _library.lookup<NativeFunction<Void Function(Uint32)>>("BASS_StreamFree").asFunction();
        BASS_StreamFree(floatable);
        floatable = BASS_SAMPLE_FLOAT;
      }
    }

    if (lastId != null) {
      stop(lastId);
      lastId = 0;
    }

    var chan = 0;
    if (isLocal != true) {
      final int Function(Pointer<ffi.Utf8>, int, int, Pointer<void>, Pointer<void>) BASS_StreamCreateURL =
        _library.lookup<NativeFunction<Uint32 Function(Pointer<ffi.Utf8>, Uint32, Uint32, Pointer<void>, Pointer<void>)>>("BASS_StreamCreateURL").asFunction();
      final Pointer<ffi.Utf8> charPointer = ffi.Utf8.toUtf8(url);
      chan = BASS_StreamCreateURL(charPointer, 0,
          BASS_MUSIC_RAMPS | floatable, nil, nil);
      ffi.free(charPointer);
    } else {
      return 0;
    }

    if (chan != 0) {
      final int Function(int, int) BASS_ChannelPlay =
        _library.lookup<NativeFunction<Int32 Function(Uint32, Int8)>>("BASS_ChannelPlay").asFunction();
      BASS_ChannelPlay(chan, 1);
      lastId = chan;
      newState = 1;
      if (handler != null) {
        final value = getDuration(lastId);
        handler(MethodCall("audio.onDuration", {
          "playerId": curPlayerId,
          "value": (value * 1000).toInt(),
        }));
      }
      initTimer();
    } else {
      lastErrorCode();
    }

    return chan;
  }

  static int pause(int id) {
    if (_library == null || id == 0) return 0;
    final int Function(int) BASS_ChannelPause =
      _library.lookup<NativeFunction<Int32 Function(Uint32)>>("BASS_ChannelPause").asFunction();
    if (BASS_ChannelPause(id) == 1)
      newState = 2;
    else
      lastErrorCode();
    return 1;
  }

  static int resume(int id) {
    if (_library == null || id == 0) return 0;
    final int Function(int, int) BASS_ChannelPlay =
      _library.lookup<NativeFunction<Int32 Function(Uint32, Int8)>>("BASS_ChannelPlay").asFunction();
    if (BASS_ChannelPlay(id, 0) == 1)
      newState = 1;
    else
      lastErrorCode();
    return 1;
  }

  static int setPosition(int id, double position) {
    if (_library == null || id == 0) return 0;
    final int Function(int, int, int) BASS_ChannelSetPosition =
      _library.lookup<NativeFunction<Int32 Function(Uint32, Int64, Uint32)>>("BASS_ChannelSetPosition").asFunction();
    final int Function(int, double) BASS_ChannelSeconds2Bytes =
      _library.lookup<NativeFunction<Int64 Function(Uint32, Double)>>("BASS_ChannelSeconds2Bytes").asFunction();
    final v = BASS_ChannelSeconds2Bytes(id, position);
    if (BASS_ChannelSetPosition(id, v, BASS_POS_BYTE) != 1)
      lastErrorCode();
    return 1;
  }

  static int stop(int id) {
    if (_library == null || id == 0 || id == null) return 0;
    final int Function(int) BASS_ChannelStop =
      _library.lookup<NativeFunction<Int32 Function(Uint32)>>("BASS_ChannelStop").asFunction();
    final void Function(int) BASS_MusicFree =
       _library.lookup<NativeFunction<Void Function(Uint32)>>("BASS_MusicFree").asFunction();
    final void Function(int) BASS_StreamFree =
      _library.lookup<NativeFunction<Void Function(Uint32)>>("BASS_StreamFree").asFunction();
    BASS_ChannelStop(id);
    BASS_MusicFree(id);
    BASS_StreamFree(id);
    newState = 0;
    return 1;
  }

  static void free(int id) {
    clearTimer();
    if (_library == null || isInit != true) return;
    stop(id);
    if (releaseMode == ReleaseMode.STOP)
      return;
    final int Function() BASS_Free =
     _library.lookup<NativeFunction<Int64 Function()>>("BASS_Free").asFunction();
    BASS_Free();
    isInit = false;
    newState = null;
  }

  static void setVolume(double volume) {
    if (_library == null || isInit != true) return;
    final int Function(double) BASS_SetVolume =
      _library.lookup<NativeFunction<Int32 Function(Float)>>("BASS_SetVolume").asFunction();
    BASS_SetVolume(volume);
    isInit = false;
  }

  static void setReleaseMode(ReleaseMode releaseMode) {
    BassWinUtil.releaseMode = releaseMode;
  }

  static double getDuration(int id) {
    if (_library == null || isInit != true) return 0;
    final int Function(int, int) BASS_ChannelGetLength =
      _library.lookup<NativeFunction<Int64 Function(Uint32, Uint32)>>("BASS_ChannelGetLength").asFunction();
    final double Function(int, int) BASS_ChannelBytes2Seconds =
      _library.lookup<NativeFunction<Double Function(Uint32, Int64)>>("BASS_ChannelBytes2Seconds").asFunction();
    final v = BASS_ChannelGetLength(id, BASS_POS_BYTE);
    return BASS_ChannelBytes2Seconds(id, v);
  }

  static int isActive(int id) {
    if (_library == null || id == 0 || id == null) return 0;
    final int Function(int) BASS_ChannelIsActive =
      _library.lookup<NativeFunction<Int64 Function(Uint32)>>("BASS_ChannelIsActive").asFunction();
    return BASS_ChannelIsActive(id);
  }

  static double getCurrentPosition(int id) {
    if (_library == null || isInit != true) return 0;
    final int Function(int, int) BASS_ChannelGetPosition =
      _library.lookup<NativeFunction<Int64 Function(Uint32, Uint32)>>("BASS_ChannelGetPosition").asFunction();
    final double Function(int, int) BASS_ChannelBytes2Seconds =
      _library.lookup<NativeFunction<Double Function(Uint32, Int64)>>("BASS_ChannelBytes2Seconds").asFunction();
    final v = BASS_ChannelGetPosition(id, BASS_POS_BYTE);
    return BASS_ChannelBytes2Seconds(id, v);
  }

  static String cStringToString(Pointer<Uint8> str, int len) {
    if (str == null || len <= 0) return null;
    List<int> units = List(len);
    for (int i = 0; i < len; ++i) units[i] = str.elementAt(i).value;
    return Utf8Codec().decode(units);
  }
}
