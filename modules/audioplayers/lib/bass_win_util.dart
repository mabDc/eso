import 'dart:convert';
import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

// by yangyxd 2020.07.16
class BassWinUtil {
  static DynamicLibrary _library;
  static bool isInit = false;
  static int floatable = 0;

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
  static Pointer<void> nil = Pointer.fromAddress(0);

  static int lastId;

  static int init({bool isLocal = false, double volume = 1.0, String url}) {
    windowsInit();
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
      _library.lookup<NativeFunction<Int32 Function(Uint32, Uint32, Uint32, Pointer<void>, Pointer<void>)>>("BASS_StreamCreate").asFunction();
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
      final int Function(Pointer<Utf8>, int, int, Pointer<void>, Pointer<void>) BASS_StreamCreateURL =
        _library.lookup<NativeFunction<Uint32 Function(Pointer<Utf8>, Uint32, Uint32, Pointer<void>, Pointer<void>)>>("BASS_StreamCreateURL").asFunction();
      final Pointer<Utf8> charPointer = Utf8.toUtf8(url);
      chan = BASS_StreamCreateURL(charPointer, 0,
          BASS_MUSIC_LOOP | BASS_MUSIC_RAMPS | floatable, nil, nil);
    }

    if (chan != 0) {
      final int Function(int, int) BASS_ChannelPlay =
        _library.lookup<NativeFunction<Int32 Function(Uint32, Int8)>>("BASS_ChannelPlay").asFunction();
      BASS_ChannelPlay(chan, 0);
      lastId = chan;
    }

    return chan;
  }

  static int pause(int id) {
    if (_library == null || id == 0) return 0;
    final int Function(int) BASS_ChannelPause =
      _library.lookup<NativeFunction<Int32 Function(Uint32)>>("BASS_ChannelPause").asFunction();
    BASS_ChannelPause(id);
    return 1;
  }

  static int resume(int id) {
    if (_library == null || id == 0) return 0;
    final int Function(int, int) BASS_ChannelPlay =
      _library.lookup<NativeFunction<Int32 Function(Uint32, Int8)>>("BASS_ChannelPlay").asFunction();
    BASS_ChannelPlay(id, 1);
    return 1;
  }

  static int setPosition(int id, int position) {
    if (_library == null || id == 0) return 0;
    final int Function(int, int, int) BASS_ChannelSetPosition =
      _library.lookup<NativeFunction<Int32 Function(Uint32, Int64, Uint32)>>("BASS_ChannelSetPosition").asFunction();
    BASS_ChannelSetPosition(id, position, 0);
    return 1;
  }

  static int stop(int id) {
    if (_library == null || id == 0) return 0;
    final int Function(int) BASS_ChannelStop =
      _library.lookup<NativeFunction<Int32 Function(Uint32)>>("BASS_ChannelStop").asFunction();
    final void Function(int) BASS_MusicFree =
       _library.lookup<NativeFunction<Void Function(Uint32)>>("BASS_MusicFree").asFunction();
    final void Function(int) BASS_StreamFree =
      _library.lookup<NativeFunction<Void Function(Uint32)>>("BASS_StreamFree").asFunction();
    BASS_ChannelStop(id);
    BASS_MusicFree(id);
    BASS_StreamFree(id);
    return 1;
  }

  static void free(int id) {
    if (_library == null || isInit != true) return;
    stop(id);
    final int Function() BASS_Free =
     _library.lookup<NativeFunction<Int64 Function()>>("BASS_Free").asFunction();
    BASS_Free();
    isInit = false;
  }

  static String evalJs(int id, String code) {
    if (_library == null) return '';
    List<int> units = Utf8Codec().encode(code);
    final data = malloc(id, units);
    final Pointer<Uint8> Function(int, Pointer<Uint8>, int) nativeEvalJS = _library
        .lookup<NativeFunction<Pointer<Uint8> Function(Int64, Pointer<Uint8>, Int32)>>(
            "js_eval")
        .asFunction();
    final resp = nativeEvalJS(id, data, units.length);
    final int Function(int) nativeResultJS =
        _library.lookup<NativeFunction<Int32 Function(Int64)>>("js_result").asFunction();
    final resultLen = nativeResultJS(id);
    final result = cStringToString(resp, resultLen);
    return result;
  }

  static Pointer<Uint8> malloc(int id, List<int> units) {
    final Pointer<Uint8> Function(int, int) jsMalloc = _library
        .lookup<NativeFunction<Pointer<Uint8> Function(Int64, Int32)>>("js_malloc")
        .asFunction();
    Pointer<Uint8> str = jsMalloc(id, units.length + 1);
    for (int i = 0; i < units.length; ++i) {
      str.elementAt(i).value = units[i];
    }
    str.elementAt(units.length).value = 0;
    return str.cast();
  }

  static String cStringToString(Pointer<Uint8> str, int len) {
    if (str == null || len <= 0) return null;
    List<int> units = List(len);
    for (int i = 0; i < len; ++i) units[i] = str.elementAt(i).value;
    return Utf8Codec().decode(units);
  }
}
