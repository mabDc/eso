// from sapi51.h
//     MIDL_INTERFACE("6C44DF74-72B9-4992-A1EC-EF996E0422D4")
//     ISpVoice : public ISpEventSource
//     {
//     public:
//         virtual HRESULT STDMETHODCALLTYPE SetOutput(
//             /* [in] */ IUnknown *pUnkOutput,
//             /* [in] */ BOOL fAllowFormatChanges) = 0;

//         virtual HRESULT STDMETHODCALLTYPE GetOutputObjectToken(
//             /* [out][annotation] */
//             _Outptr_  ISpObjectToken **ppObjectToken) = 0;

//         virtual HRESULT STDMETHODCALLTYPE GetOutputStream(
//             /* [out] */ ISpStreamFormat **ppStream) = 0;

//         virtual HRESULT STDMETHODCALLTYPE Pause( void) = 0;

//         virtual HRESULT STDMETHODCALLTYPE Resume( void) = 0;

//         virtual HRESULT STDMETHODCALLTYPE SetVoice(
//             /* [in] */ ISpObjectToken *pToken) = 0;

//         virtual HRESULT STDMETHODCALLTYPE GetVoice(
//             /* [out][annotation] */
//             _Outptr_  ISpObjectToken **ppToken) = 0;

//         virtual HRESULT STDMETHODCALLTYPE Speak(
//             /* [string][in][annotation] */
//             _In_opt_  LPCWSTR pwcs,
//             /* [in] */ DWORD dwFlags,
//             /* [out][annotation] */
//             _Out_opt_  ULONG *pulStreamNumber) = 0;   //20

//         virtual HRESULT STDMETHODCALLTYPE SpeakStream(
//             /* [in] */ IStream *pStream,
//             /* [in] */ DWORD dwFlags,
//             /* [out][annotation] */
//             _Out_opt_  ULONG *pulStreamNumber) = 0;   //21

//         virtual HRESULT STDMETHODCALLTYPE GetStatus(
//             /* [out] */ SPVOICESTATUS *pStatus,
//             /* [out][annotation] */
//             _Outptr_  LPWSTR *ppszLastBookmark) = 0;   //22

//         virtual HRESULT STDMETHODCALLTYPE Skip(
//             /* [string][in] */ LPCWSTR pItemType,
//             /* [in] */ long lNumItems,
//             /* [out] */ ULONG *pulNumSkipped) = 0;     //23

//         virtual HRESULT STDMETHODCALLTYPE SetPriority(
//             /* [in] */ SPVPRIORITY ePriority) = 0;    //24

//         virtual HRESULT STDMETHODCALLTYPE GetPriority(
//             /* [out] */ SPVPRIORITY *pePriority) = 0;   //25

//         virtual HRESULT STDMETHODCALLTYPE SetAlertBoundary(
//             /* [in] */ SPEVENTENUM eBoundary) = 0;         //26

//         virtual HRESULT STDMETHODCALLTYPE GetAlertBoundary(
//             /* [out] */ SPEVENTENUM *peBoundary) = 0;     //27

//         virtual HRESULT STDMETHODCALLTYPE SetRate(
//             /* [in] */ long RateAdjust) = 0;             // 28

//         virtual HRESULT STDMETHODCALLTYPE GetRate(
//             /* [out] */ long *pRateAdjust) = 0;          //29

//         virtual HRESULT STDMETHODCALLTYPE SetVolume(
//             /* [in] */ USHORT usVolume) = 0;             //30

//         virtual HRESULT STDMETHODCALLTYPE GetVolume(
//             /* [out] */ USHORT *pusVolume) = 0;            //31

//         virtual HRESULT STDMETHODCALLTYPE WaitUntilDone(
//             /* [in] */ ULONG msTimeout) = 0;               //32

//         virtual HRESULT STDMETHODCALLTYPE SetSyncSpeakTimeout(
//             /* [in] */ ULONG msTimeout) = 0;               //33

//         virtual HRESULT STDMETHODCALLTYPE GetSyncSpeakTimeout(
//             /* [out] */ ULONG *pmsTimeout) = 0;            //34

//         virtual /* [local] */ HANDLE STDMETHODCALLTYPE SpeakCompleteEvent( void) = 0;     //35

//         virtual /* [local] */ HRESULT STDMETHODCALLTYPE IsUISupported(
//             /* [in] */ LPCWSTR pszTypeOfUI,
//             /* [in] */ void *pvExtraData,
//             /* [in] */ ULONG cbExtraData,
//             /* [out] */ BOOL *pfSupported) = 0;

//         virtual /* [local] */ HRESULT STDMETHODCALLTYPE DisplayUI(
//             /* [in] */ HWND hwndParent,
//             /* [in] */ LPCWSTR pszTitle,
//             /* [in] */ LPCWSTR pszTypeOfUI,
//             /* [in] */ void *pvExtraData,
//             /* [in] */ ULONG cbExtraData) = 0;

//     };

import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

class ISapi extends IUnknown {
// vtable begins at 13, is 30 entries long.
  ISapi(Pointer<COMObject> ptr) : super(ptr);

  int Pause() => Pointer<
              NativeFunction<
                  Int32 Function(
        Pointer obj,
      )>>.fromAddress(ptr.ref.vtable.elementAt(16).value)
          .asFunction<
              int Function(
        Pointer obj,
      )>()(ptr.ref.lpVtbl);

  int Resume() => Pointer<
              NativeFunction<
                  Int32 Function(
        Pointer obj,
      )>>.fromAddress(ptr.ref.vtable.elementAt(17).value)
          .asFunction<
              int Function(
        Pointer obj,
      )>()(ptr.ref.lpVtbl);

  int Speak(
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
}

const CLSID_SpVoice = '{96749377-3391-11D2-9EE3-00C04F797396}';

const IID_ISpVoice = '{6C44DF74-72B9-4992-A1EC-EF996E0422D4}';

class Sapi {
  final ISapi iSapi;
  bool hasFree = false;

  static Sapi _sapi;

  factory Sapi.createInstance() => _sapi ??= Sapi._();

  Sapi._() : iSapi = ISapi(COMObject.createFromID(CLSID_SpVoice, IID_ISpVoice));

  final SVSFlagsAsync = 1;
  final SVSFPurgeBeforeSpeak = 2;

  static int speakStatic(List l) {
    final int address = l[0];
    final String s = l[1];
    final ptr = Pointer<COMObject>.fromAddress(address);
    final iSapi = ISapi(ptr);
    final pwcs = s.toNativeUtf16();
    try {
      return iSapi.Speak(pwcs, 2, NULL);
    } finally {
      free(pwcs);
    }
  }

  Future<int> speakIsolate(final String s) async {
    stop();
    iSapi.ptr = COMObject.createFromID(CLSID_SpVoice, IID_ISpVoice);
    hasFree = false;
    return compute(speakStatic, [iSapi.ptr.address, s]);
  }

  int speakAsync(String s) {
    final pwcs = s.toNativeUtf16();
    try {
      final hr = iSapi.Speak(pwcs, SVSFlagsAsync | SVSFPurgeBeforeSpeak, NULL);
      if (FAILED(hr)) {
        throw WindowsException(hr);
      } else {
        final hr = iSapi.Resume();
        if (FAILED(hr)) {
          throw WindowsException(hr);
        } else {
          return hr;
        }
      }
    } finally {
      free(pwcs);
    }
  }

  int pause() {
    try {
      final hr = iSapi.Pause();
      if (FAILED(hr)) {
        throw WindowsException(hr);
      } else {
        return hr;
      }
    } finally {}
  }

  int resume() {
    try {
      final hr = iSapi.Resume();
      if (FAILED(hr)) {
        throw WindowsException(hr);
      } else {
        return hr;
      }
    } finally {}
  }

  void stop() => dispose();

  void dispose() {
    if (!hasFree) {
      iSapi.Pause();
      free(iSapi.ptr);
      CoUninitialize();
      hasFree = true;
    }
  }
}
