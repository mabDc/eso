/// Loading state
// Order must match WebviewLoadingState (see webview.h)
enum LoadingState { none, loading, navigationCompleted }

/// Pointer button type
// Order must match WebviewPointerButton (see webview.h)
enum PointerButton { none, primary, secondary, tertiary }

/// Permission kind
// Order must match WebviewPermissionKind (see webview.h)
enum WebviewPermissionKind {
  unknown,
  microphone,
  camera,
  geoLocation,
  notifications,
  otherSensors,
  clipboardRead
}

enum WebviewPermissionDecision { none, allow, deny }

/// The policy for popup requests.
///
/// [allow] allows popups and will create new windows.
/// [deny] suppresses popups.
/// [sameWindow] displays popup contents in the current WebView.
enum WebviewPopupWindowPolicy { allow, deny, sameWindow }
