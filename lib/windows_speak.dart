import 'dart:ffi';
import 'package:ffi/ffi.dart';

const CLSID_SpVoice = '{96749377-3391-11D2-9EE3-00C04F797396}';

const IID_ISpVoice = '{6C44DF74-72B9-4992-A1EC-EF996E0422D4}';

final ptr = COMObject.allocate().addressOf;
int _speak(
  Pointer<Utf16> pwcs,
  int dwFlags,
  int pulStreamNumber,
) =>
    Pointer<
            NativeFunction<
                Int32 Function(
      Pointer obj,
      Pointer<Utf16> pwcs,
      Uint32 dwFlags,
      Uint32 pulStreamNumber,
    )>>.fromAddress(ptr.ref.vtable.elementAt(20).value)
        .asFunction<
            int Function(
      Pointer obj,
      Pointer<Utf16> pwcs,
      int dwFlags,
      int pulStreamNumber,
    )>()(ptr.ref.lpVtbl, pwcs, dwFlags, pulStreamNumber);

windowsSpeak(String s) {
  // Initialize COM
  var hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  if (FAILED(hr)) {
    throw "WindowsException(hr)";
  }

  hr = CoCreateInstance(
    GUID.fromString(CLSID_SpVoice).addressOf,
    nullptr,
    CLSCTX_ALL,
    GUID.fromString(IID_ISpVoice).addressOf,
    ptr,
  );

  _speak(Utf16.toUtf16(s), 0, NULL);
  if (FAILED(hr)) throw "失败";
  CoUninitialize();
}

const COINIT_APARTMENTTHREADED = 0x2;

const NULL = 0;

/// @nodoc
const CLSCTX_INPROC_SERVER = 0x1;

/// @nodoc
const CLSCTX_INPROC_HANDLER = 0x2;

/// @nodoc
const CLSCTX_LOCAL_SERVER = 0x4;

/// @nodoc
const CLSCTX_INPROC_SERVER16 = 0x8;

/// @nodoc
const CLSCTX_REMOTE_SERVER = 0x10;

/// @nodoc
const CLSCTX_ALL = CLSCTX_INPROC_SERVER |
    CLSCTX_INPROC_HANDLER |
    CLSCTX_LOCAL_SERVER |
    CLSCTX_REMOTE_SERVER;

// *** COM STRUCTS ***

// typedef struct _GUID {
//     unsigned long  Data1;
//     unsigned short Data2;
//     unsigned short Data3;
//     unsigned char  Data4[ 8 ];
// } GUID;

/// Represents a globally unique identifier (GUID).
///
/// {@category Struct}
class GUID extends Struct {
  @Uint32()
  int Data1;
  @Uint16()
  int Data2;
  @Uint16()
  int Data3;
  @Uint64()
  int Data4;

  factory GUID.allocate() => allocate<GUID>().ref
    ..Data1 = 0
    ..Data2 = 0
    ..Data3 = 0
    ..Data4 = 0;

  /// Create GUID from common {FDD39AD0-238F-46AF-ADB4-6C85480369C7} format
  factory GUID.fromString(String guidString) {
    assert(guidString.length == 38);
    final guid = allocate<GUID>().ref;
    guid.Data1 = int.parse(guidString.substring(1, 9), radix: 16);
    guid.Data2 = int.parse(guidString.substring(10, 14), radix: 16);
    guid.Data3 = int.parse(guidString.substring(15, 19), radix: 16);

    // final component is pushed on the stack in reverse order per x64
    // calling convention. This is a funky workaround until FFI supports
    // passing structs by value.
    final rawString = guidString.substring(35, 37) +
        guidString.substring(33, 35) +
        guidString.substring(31, 33) +
        guidString.substring(29, 31) +
        guidString.substring(27, 29) +
        guidString.substring(25, 27) +
        guidString.substring(22, 24) +
        guidString.substring(20, 22);

    // We need to split this to avoid overflowing a signed int.parse()
    guid.Data4 = (int.parse(rawString.substring(0, 4), radix: 16) << 48) +
        int.parse(rawString.substring(4, 16), radix: 16);

    return guid;
  }

  /// Print GUID in common {FDD39AD0-238F-46AF-ADB4-6C85480369C7} format
  @override
  String toString() {
    final comp1 = (Data4 & 0xFF).toRadixString(16).padLeft(2, '0') +
        ((Data4 & 0xFF00) >> 8).toRadixString(16).padLeft(2, '0');

    // This is hacky as all get-out :)
    final comp2 = ((Data4 & 0xFF0000) >> 16).toRadixString(16).padLeft(2, '0') +
        ((Data4 & 0xFF000000) >> 24).toRadixString(16).padLeft(2, '0') +
        ((Data4 & 0xFF00000000) >> 32).toRadixString(16).padLeft(2, '0') +
        ((Data4 & 0xFF0000000000) >> 40).toRadixString(16).padLeft(2, '0') +
        ((Data4 & 0xFF000000000000) >> 48).toRadixString(16).padLeft(2, '0') +
        (BigInt.from(Data4 & 0xFF00000000000000).toUnsigned(64) >> 56)
            .toRadixString(16)
            .padLeft(2, '0');

    return '{${Data1.toRadixString(16).padLeft(8, '0').toUpperCase()}-'
        '${Data2.toRadixString(16).padLeft(4, '0').toUpperCase()}-'
        '${Data3.toRadixString(16).padLeft(4, '0').toUpperCase()}-'
        '${comp1.toUpperCase()}-'
        '${comp2.toUpperCase()}}';
  }
}

/// A representation of a generic COM object. All Dart COM objects inherit from
/// this class.
///
/// {@category com}
class COMObject extends Struct {
  Pointer<IntPtr> lpVtbl;

  Pointer<IntPtr> get vtable => Pointer.fromAddress(lpVtbl.value);

  factory COMObject.allocate() => allocate<COMObject>().ref..lpVtbl = allocate<IntPtr>();
}

final _ole32 = DynamicLibrary.open('ole32.dll');

final CoInitializeEx = _ole32.lookupFunction<
    Int32 Function(Pointer<Void> pvReserved, Uint32 dwCoInit),
    int Function(Pointer<Void> pvReserved, int dwCoInit)>('CoInitializeEx');

/// Creates a single uninitialized object of the class associated with a
/// specified CLSID. Call CoCreateInstance when you want to create only one
/// object on the local system. To create a single object on a remote
/// system, call the CoCreateInstanceEx function. To create multiple
/// objects based on a single CLSID, call the CoGetClassObject function.
///
/// ```c
/// HRESULT CoCreateInstance(
///   REFCLSID  rclsid,
///   LPUNKNOWN pUnkOuter,
///   DWORD     dwClsContext,
///   REFIID    riid,
///   LPVOID    *ppv
/// );
/// ```
/// {@category ole32}
final CoCreateInstance = _ole32.lookupFunction<
    Int32 Function(Pointer<GUID> rclsid, Pointer<IntPtr> pUnkOuter, Uint32 dwClsContext,
        Pointer<GUID> riid, Pointer<COMObject> ppv),
    int Function(Pointer<GUID> rclsid, Pointer<IntPtr> pUnkOuter, int dwClsContext,
        Pointer<GUID> riid, Pointer<COMObject> ppv)>('CoCreateInstance');

/// Closes the COM library on the current thread, unloads all DLLs loaded
/// by the thread, frees any other resources that the thread maintains, and
/// forces all RPC connections on the thread to close.
///
/// ```c
/// void CoUninitialize();
/// ```
/// {@category ole32}
final CoUninitialize =
    _ole32.lookupFunction<Void Function(), void Function()>('CoUninitialize');

// #define FAILED(hr) (((HRESULT)(hr)) < 0)
bool FAILED(int result) => result < 0;
