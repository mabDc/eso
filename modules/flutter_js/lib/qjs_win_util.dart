import 'dart:convert';
import 'dart:io';
import 'dart:ffi';

// by yangyxd 2020.07.13
class QJsWindowsUtil {
  static DynamicLibrary _library;

  static void windowsInit() {
    if (_library != null) return;
    final dll = "qjs.dll";
    try {
      _library = DynamicLibrary.open(dll);
    } catch (e) {
      stderr.writeln('Failed to load $dll');
      rethrow;
    }
  }

  static int initJS() {
    windowsInit();
    if (_library == null) return -1;
    final int Function() nativeInitJS =
        _library.lookup<NativeFunction<Int64 Function()>>("js_init").asFunction();
    return nativeInitJS();
  }

  static int freeJs(int id) {
    if (_library == null) return -1;
    final int Function(int) nativeFreeJS =
        _library.lookup<NativeFunction<Int64 Function(Int64)>>("js_free").asFunction();
    return nativeFreeJS(id);
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
