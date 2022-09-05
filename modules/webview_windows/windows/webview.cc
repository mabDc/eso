#include "webview.h"

#include <atlstr.h>
#include <fmt/core.h>
#include <wrl.h>
#include <codecvt>
#include <iostream>

#include "util/composition.desktop.interop.h"
#include "webview_host.h"

using namespace Microsoft::WRL;

std::wstring to_lpwstr(const std::string s)
{
  int n = MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, NULL, 0);
  wchar_t *ws = new wchar_t[n];
  MultiByteToWideChar(CP_UTF8, 0, s.c_str(), -1, ws, n);
  auto wstr = std::wstring(ws, n);
  delete ws;
  return wstr;
}

std::string from_lpwstr(wchar_t *wchar)
{
  std::string szDst;
  wchar_t *wText = wchar;
  DWORD dwNum = WideCharToMultiByte(CP_UTF8, NULL, wText, -1, NULL, 0, NULL, FALSE);
  char *psText;
  psText = new char[dwNum];
  WideCharToMultiByte(CP_UTF8, NULL, wText, -1, psText, dwNum, NULL, FALSE);
  szDst = psText;
  delete[] psText;
  return szDst;
}

namespace
{

  inline auto towstring(std::string_view str)
  {
    return std::wstring(str.begin(), str.end());
  }

  inline void ConvertColor(COREWEBVIEW2_COLOR &webview_color, int32_t color)
  {
    webview_color.B = color & 0xFF;
    webview_color.G = (color >> 8) & 0xFF;
    webview_color.R = (color >> 16) & 0xFF;
    webview_color.A = (color >> 24) & 0xFF;
  }

  std::wstring get_utf16(const std::string &str, int codepage)
  {
    if (str.empty())
      return std::wstring();
    int sz = MultiByteToWideChar(codepage, 0, &str[0], (int)str.size(), 0, 0);
    std::wstring res(sz, 0);
    MultiByteToWideChar(codepage, 0, &str[0], (int)str.size(), &res[0], sz);
    return res;
  }

  inline WebviewPermissionKind CW2PermissionKindToPermissionKind(
      COREWEBVIEW2_PERMISSION_KIND kind)
  {
    using k = COREWEBVIEW2_PERMISSION_KIND;
    switch (kind)
    {
    case k::COREWEBVIEW2_PERMISSION_KIND_MICROPHONE:
      return WebviewPermissionKind::Microphone;
    case k::COREWEBVIEW2_PERMISSION_KIND_CAMERA:
      return WebviewPermissionKind::Camera;
    case k::COREWEBVIEW2_PERMISSION_KIND_GEOLOCATION:
      return WebviewPermissionKind::GeoLocation;
    case k::COREWEBVIEW2_PERMISSION_KIND_NOTIFICATIONS:
      return WebviewPermissionKind::Notifications;
    case k::COREWEBVIEW2_PERMISSION_KIND_OTHER_SENSORS:
      return WebviewPermissionKind::OtherSensors;
    case k::COREWEBVIEW2_PERMISSION_KIND_CLIPBOARD_READ:
      return WebviewPermissionKind::ClipboardRead;
    default:
      return WebviewPermissionKind::Unknown;
    }
  }

  inline COREWEBVIEW2_PERMISSION_STATE WebViewPermissionStateToCW2PermissionState(
      WebviewPermissionState state)
  {
    using s = COREWEBVIEW2_PERMISSION_STATE;
    switch (state)
    {
    case WebviewPermissionState::Allow:
      return s::COREWEBVIEW2_PERMISSION_STATE_ALLOW;
    case WebviewPermissionState::Deny:
      return s::COREWEBVIEW2_PERMISSION_STATE_DENY;
    default:
      return s::COREWEBVIEW2_PERMISSION_STATE_DEFAULT;
    }
  }

} // namespace

Webview::Webview(
    wil::com_ptr<ICoreWebView2CompositionController> composition_controller,
    WebviewHost *host, HWND hwnd, bool owns_window, bool offscreen_only)
    : composition_controller_(std::move(composition_controller)),
      host_(host),
      hwnd_(hwnd),
      owns_window_(owns_window)
{
  webview_controller_ =
      composition_controller_.try_query<ICoreWebView2Controller3>();

  if (!webview_controller_ ||
      FAILED(webview_controller_->get_CoreWebView2(webview_.put())))
  {
    return;
  }

  webview_controller_->put_BoundsMode(COREWEBVIEW2_BOUNDS_MODE_USE_RAW_PIXELS);
  webview_controller_->put_ShouldDetectMonitorScaleChanges(FALSE);
  webview_controller_->put_RasterizationScale(1.0);

  wil::com_ptr<ICoreWebView2Settings> settings;
  if (SUCCEEDED(webview_->get_Settings(settings.put())))
  {
    settings2_ = settings.try_query<ICoreWebView2Settings2>();

    settings->put_IsStatusBarEnabled(FALSE);
    settings->put_AreDefaultContextMenusEnabled(FALSE);
  }

  EnableSecurityUpdates();
  RegisterEventHandlers();

  is_valid_ = CreateSurface(host->compositor(), hwnd, offscreen_only);
}

Webview::~Webview()
{
  if (owns_window_)
  {
    DestroyWindow(hwnd_);
  }
}

bool Webview::CreateSurface(
    winrt::com_ptr<ABI::Windows::UI::Composition::ICompositor> compositor,
    HWND hwnd, bool offscreen_only)
{
  winrt::com_ptr<ABI::Windows::UI::Composition::IContainerVisual> root;
  if (FAILED(compositor->CreateContainerVisual(root.put())))
  {
    return false;
  }

  surface_ = root.try_as<ABI::Windows::UI::Composition::IVisual>();
  assert(surface_);

  // initial size. doesn't matter as we resize the surface anyway.
  surface_->put_Size({1280, 720});
  surface_->put_IsVisible(true);

  // Create on-screen window for debugging purposes
  if (!offscreen_only)
  {
    window_target_ = util::TryCreateDesktopWindowTarget(compositor, hwnd);
    auto composition_target =
        window_target_
            .try_as<ABI::Windows::UI::Composition::ICompositionTarget>();
    if (composition_target)
    {
      composition_target->put_Root(surface_.get());
    }
  }

  winrt::com_ptr<ABI::Windows::UI::Composition::IVisual> webview_visual;
  compositor->CreateContainerVisual(
      reinterpret_cast<ABI::Windows::UI::Composition::IContainerVisual **>(
          webview_visual.put()));

  auto webview_visual2 =
      webview_visual.try_as<ABI::Windows::UI::Composition::IVisual2>();
  if (webview_visual2)
  {
    webview_visual2->put_RelativeSizeAdjustment({1.0f, 1.0f});
  }

  winrt::com_ptr<ABI::Windows::UI::Composition::IVisualCollection> children;
  root->get_Children(children.put());
  children->InsertAtTop(webview_visual.get());
  composition_controller_->put_RootVisualTarget(webview_visual2.get());

  webview_controller_->put_IsVisible(true);

  return true;
}

void Webview::EnableSecurityUpdates()
{
  if (SUCCEEDED(webview_->CallDevToolsProtocolMethod(L"Security.enable", L"{}",
                                                     nullptr)) &&
      SUCCEEDED(webview_->GetDevToolsProtocolEventReceiver(
          L"Security.securityStateChanged",
          &devtools_protocol_event_receiver_)))
  {
    devtools_protocol_event_receiver_->add_DevToolsProtocolEventReceived(
        Callback<ICoreWebView2DevToolsProtocolEventReceivedEventHandler>(
            [this](ICoreWebView2 *sender,
                   ICoreWebView2DevToolsProtocolEventReceivedEventArgs *args)
                -> HRESULT
            {
              if (devtools_protocol_event_callback_)
              {
                wil::unique_cotaskmem_string json_args;
                if (args->get_ParameterObjectAsJson(&json_args) == S_OK)
                {
                  std::string json = CW2A(json_args.get(), CP_UTF8);
                  devtools_protocol_event_callback_(json.c_str());
                }
              }

              return S_OK;
            })
            .Get(),
        &event_registrations_.devtools_protocol_event_token_);
  }
}

void Webview::RegisterEventHandlers()
{
  if (!webview_)
  {
    return;
  }

  webview_->add_ContentLoading(
      Callback<ICoreWebView2ContentLoadingEventHandler>(
          [this](ICoreWebView2 *sender, IUnknown *args) -> HRESULT
          {
            if (loading_state_changed_callback_)
            {
              loading_state_changed_callback_(WebviewLoadingState::Loading);
            }

            return S_OK;
          })
          .Get(),
      &event_registrations_.content_loading_token_);

  webview_->add_NavigationCompleted(
      Callback<ICoreWebView2NavigationCompletedEventHandler>(
          [this](ICoreWebView2 *sender, IUnknown *args) -> HRESULT
          {
            if (loading_state_changed_callback_)
            {
              loading_state_changed_callback_(
                  WebviewLoadingState::NavigationCompleted);
            }

            return S_OK;
          })
          .Get(),
      &event_registrations_.navigation_completed_token_);

  webview_->add_HistoryChanged(
      Callback<ICoreWebView2HistoryChangedEventHandler>(
          [this](ICoreWebView2 *sender, IUnknown *args) -> HRESULT
          {
            if (history_changed_callback_)
            {
              BOOL can_go_back;
              BOOL can_go_forward;
              sender->get_CanGoBack(&can_go_back);
              sender->get_CanGoForward(&can_go_forward);
              history_changed_callback_({can_go_back, can_go_forward});
            }

            return S_OK;
          })
          .Get(),
      &event_registrations_.history_changed_token_);

  webview_->add_SourceChanged(
      Callback<ICoreWebView2SourceChangedEventHandler>(
          [this](ICoreWebView2 *sender, IUnknown *args) -> HRESULT
          {
            LPWSTR wurl;
            if (url_changed_callback_ && webview_->get_Source(&wurl) == S_OK)
            {
              std::string url = CW2A(wurl, CP_UTF8);
              url_changed_callback_(url);
            }

            return S_OK;
          })
          .Get(),
      &event_registrations_.source_changed_token_);

  webview_->add_DocumentTitleChanged(
      Callback<ICoreWebView2DocumentTitleChangedEventHandler>(
          [this](ICoreWebView2 *sender, IUnknown *args) -> HRESULT
          {
            LPWSTR wtitle;
            if (document_title_changed_callback_ &&
                webview_->get_DocumentTitle(&wtitle) == S_OK)
            {
              std::string title = CW2A(wtitle, CP_UTF8);
              document_title_changed_callback_(title);
            }

            return S_OK;
          })
          .Get(),
      &event_registrations_.document_title_changed_token_);

  composition_controller_->add_CursorChanged(
      Callback<ICoreWebView2CursorChangedEventHandler>(
          [this](ICoreWebView2CompositionController *sender,
                 IUnknown *args) -> HRESULT
          {
            HCURSOR cursor;
            if (cursor_changed_callback_ &&
                sender->get_Cursor(&cursor) == S_OK)
            {
              cursor_changed_callback_(cursor);
            }
            return S_OK;
          })
          .Get(),
      &event_registrations_.cursor_changed_token_);

  webview_controller_->add_GotFocus(
      Callback<ICoreWebView2FocusChangedEventHandler>(
          [this](ICoreWebView2Controller *sender, IUnknown *args) -> HRESULT
          {
            if (focus_changed_callback_)
            {
              focus_changed_callback_(true);
            }
            return S_OK;
          })
          .Get(),
      &event_registrations_.got_focus_token_);

  webview_controller_->add_LostFocus(
      Callback<ICoreWebView2FocusChangedEventHandler>(
          [this](ICoreWebView2Controller *sender, IUnknown *args) -> HRESULT
          {
            if (focus_changed_callback_)
            {
              focus_changed_callback_(false);
            }
            return S_OK;
          })
          .Get(),
      &event_registrations_.lost_focus_token_);

  webview_->add_WebMessageReceived(
      Callback<ICoreWebView2WebMessageReceivedEventHandler>(
          [this](ICoreWebView2 *sender,
                 ICoreWebView2WebMessageReceivedEventArgs *args) -> HRESULT
          {
            wil::unique_cotaskmem_string wmessage;
            if (web_message_received_callback_ &&
                args->get_WebMessageAsJson(&wmessage) == S_OK)
            {
              const std::string message = CW2A(wmessage.get(), CP_UTF8);
              web_message_received_callback_(message);
            }

            return S_OK;
          })
          .Get(),
      &event_registrations_.web_message_received_token_);

  webview_->add_PermissionRequested(
      Callback<ICoreWebView2PermissionRequestedEventHandler>(
          [this](ICoreWebView2 *sender,
                 ICoreWebView2PermissionRequestedEventArgs *args) -> HRESULT
          {
            if (!permission_requested_callback_)
            {
              return S_OK;
            }

            wil::unique_cotaskmem_string wuri;
            COREWEBVIEW2_PERMISSION_KIND kind =
                COREWEBVIEW2_PERMISSION_KIND_UNKNOWN_PERMISSION;
            BOOL is_user_initiated = false;

            if (args->get_Uri(&wuri) == S_OK &&
                args->get_PermissionKind(&kind) == S_OK &&
                args->get_IsUserInitiated(&is_user_initiated) == S_OK)
            {
              wil::com_ptr<ICoreWebView2Deferral> deferral;
              args->GetDeferral(deferral.put());

              const std::string uri = CW2A(wuri.get(), CP_UTF8);
              permission_requested_callback_(
                  uri, CW2PermissionKindToPermissionKind(kind),
                  is_user_initiated == TRUE,
                  [deferral = std::move(deferral),
                   args = std::move(args)](WebviewPermissionState state)
                  {
                    args->put_State(
                        WebViewPermissionStateToCW2PermissionState(state));
                    deferral->Complete();
                  });
            }

            return S_OK;
          })
          .Get(),
      &event_registrations_.permission_requested_token_);

  webview_->add_NewWindowRequested(
      Callback<ICoreWebView2NewWindowRequestedEventHandler>(
          [this](ICoreWebView2 *sender,
                 ICoreWebView2NewWindowRequestedEventArgs *args) -> HRESULT
          {
            switch (popup_window_policy_)
            {
            case WebviewPopupWindowPolicy::Deny:
              args->put_Handled(TRUE);
              break;
            case WebviewPopupWindowPolicy::ShowInSameWindow:
              args->put_NewWindow(webview_.get());
              args->put_Handled(TRUE);
              break;
            }

            return S_OK;
          })
          .Get(),
      &event_registrations_.new_windows_requested_token_);
}

void Webview::SetSurfaceSize(size_t width, size_t height)
{
  if (!IsValid())
  {
    return;
  }

  if (surface_ && width > 0 && height > 0)
  {
    surface_->put_Size({(float)width, (float)height});

    RECT bounds;
    bounds.left = 0;
    bounds.top = 0;
    bounds.right = static_cast<LONG>(width);
    bounds.bottom = static_cast<LONG>(height);

    if (webview_controller_->put_Bounds(bounds) != S_OK)
    {
      std::cerr << "Setting webview bounds failed." << std::endl;
    }

    if (surface_size_changed_callback_)
    {
      surface_size_changed_callback_(width, height);
    }
  }
}

bool Webview::OpenDevTools()
{
  if (!IsValid())
  {
    return false;
  }
  webview_->OpenDevToolsWindow();
  return true;
}

bool Webview::ClearCookies()
{
  if (!IsValid())
  {
    return false;
  }
  return webview_->CallDevToolsProtocolMethod(L"Network.clearBrowserCookies",
                                              L"{}", nullptr) == S_OK;
}

bool Webview::ClearCache()
{
  if (!IsValid())
  {
    return false;
  }

  return webview_->CallDevToolsProtocolMethod(L"Network.clearBrowserCache",
                                              L"{}", nullptr) == S_OK;
}

bool Webview::SetCacheDisabled(bool disabled)
{
  if (!IsValid())
  {
    return false;
  }
  std::string json = fmt::format("{{\"disableCache\":{}}}", disabled);
  return webview_->CallDevToolsProtocolMethod(L"Network.setCacheDisabled",
                                              towstring(json).c_str(),
                                              nullptr) == S_OK;
}

void Webview::SetPopupWindowPolicy(WebviewPopupWindowPolicy policy)
{
  popup_window_policy_ = policy;
}

bool Webview::SetUserAgent(const std::string &user_agent)
{
  if (settings2_)
  {
    return settings2_->put_UserAgent(towstring(user_agent).c_str()) == S_OK;
  }
  return false;
}

bool Webview::SetBackgroundColor(int32_t color)
{
  if (!IsValid())
  {
    return false;
  }

  COREWEBVIEW2_COLOR webview_color;
  ConvertColor(webview_color, color);

  // Semi-transparent backgrounds are not supported.
  // Valid alpha values are 0 or 255.
  if (webview_color.A > 0)
  {
    webview_color.A = 0xFF;
  }

  return webview_controller_->put_DefaultBackgroundColor(webview_color) == S_OK;
}

void Webview::SetCursorPos(double x, double y)
{
  if (!IsValid())
  {
    return;
  }

  POINT point;
  point.x = static_cast<LONG>(x);
  point.y = static_cast<LONG>(y);
  last_cursor_pos_ = point;

  // https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.774.44
  composition_controller_->SendMouseInput(
      COREWEBVIEW2_MOUSE_EVENT_KIND::COREWEBVIEW2_MOUSE_EVENT_KIND_MOVE,
      virtual_keys_.state(), 0, point);
}

void Webview::SetPointerButtonState(WebviewPointerButton button, bool is_down)
{
  if (!IsValid())
  {
    return;
  }

  COREWEBVIEW2_MOUSE_EVENT_KIND kind;
  switch (button)
  {
  case WebviewPointerButton::Primary:
    virtual_keys_.set_isLeftButtonDown(is_down);
    kind = is_down ? COREWEBVIEW2_MOUSE_EVENT_KIND_LEFT_BUTTON_DOWN
                   : COREWEBVIEW2_MOUSE_EVENT_KIND_LEFT_BUTTON_UP;
    break;
  case WebviewPointerButton::Secondary:
    virtual_keys_.set_isRightButtonDown(is_down);
    kind = is_down ? COREWEBVIEW2_MOUSE_EVENT_KIND_RIGHT_BUTTON_DOWN
                   : COREWEBVIEW2_MOUSE_EVENT_KIND_RIGHT_BUTTON_UP;
    break;
  case WebviewPointerButton::Tertiary:
    virtual_keys_.set_isMiddleButtonDown(is_down);
    kind = is_down ? COREWEBVIEW2_MOUSE_EVENT_KIND_MIDDLE_BUTTON_DOWN
                   : COREWEBVIEW2_MOUSE_EVENT_KIND_MIDDLE_BUTTON_UP;
    break;
  default:
    kind = static_cast<COREWEBVIEW2_MOUSE_EVENT_KIND>(0);
  }

  composition_controller_->SendMouseInput(kind, virtual_keys_.state(), 0,
                                          last_cursor_pos_);
}

void Webview::SendScroll(double delta, bool horizontal)
{
  // delta * 6 gives me a multiple of WHEEL_DELTA (120)
  constexpr auto kScrollMultiplier = 6;

  auto offset = static_cast<short>(delta * kScrollMultiplier);

  // TODO Remove this workaround
  //
  // For some reason, the composition controller only handles mousewheel events
  // if a mouse button is down.
  // -> Emulate a down button while sending the wheel event (a virtual key
  //    doesn't work)
  composition_controller_->SendMouseInput(
      COREWEBVIEW2_MOUSE_EVENT_KIND_X_BUTTON_DOWN,
      COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS_NONE, 0, last_cursor_pos_);

  if (horizontal)
  {
    composition_controller_->SendMouseInput(
        COREWEBVIEW2_MOUSE_EVENT_KIND_HORIZONTAL_WHEEL, virtual_keys_.state(),
        offset, last_cursor_pos_);
  }
  else
  {
    composition_controller_->SendMouseInput(COREWEBVIEW2_MOUSE_EVENT_KIND_WHEEL,
                                            virtual_keys_.state(), offset,
                                            last_cursor_pos_);
  }

  composition_controller_->SendMouseInput(
      COREWEBVIEW2_MOUSE_EVENT_KIND_X_BUTTON_UP,
      COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS_NONE, 0, last_cursor_pos_);
}

void Webview::SetScrollDelta(double delta_x, double delta_y)
{
  if (!IsValid())
  {
    return;
  }

  if (delta_x != 0.0)
  {
    SendScroll(delta_x, true);
  }
  if (delta_y != 0.0)
  {
    SendScroll(delta_y, false);
  }
}

void Webview::LoadUrl(const std::string &url)
{
  if (IsValid())
  {

    webview_->Navigate(towstring(url).c_str());
  }
}

void Webview::LoadStringContent(const std::string &content)
{
  if (IsValid())
  {
    webview_->NavigateToString(get_utf16(content, CP_UTF8).c_str());
  }
}

bool Webview::Stop()
{
  if (!IsValid())
  {
    return false;
  }
  return SUCCEEDED(webview_->CallDevToolsProtocolMethod(L"Page.stopLoading",
                                                        L"{}", nullptr));
}

bool Webview::Reload()
{
  if (!IsValid())
  {
    return false;
  }
  return SUCCEEDED(webview_->Reload());
}

bool Webview::GoBack()
{
  if (!IsValid())
  {
    return false;
  }
  return SUCCEEDED(webview_->GoBack());
}

bool Webview::CanGoBack()
{
  if (!IsValid())
  {
    return false;
  }
  BOOL canGoBack;
  webview_->get_CanGoBack(&canGoBack);
  return canGoBack;
}


bool Webview::GoForward()
{
  if (!IsValid())
  {
    return false;
  }
  return SUCCEEDED(webview_->GoForward());
}

bool Webview::CanGoForward()
{
  if (!IsValid())
  {
    return false;
  }
  BOOL canGoForward;
  webview_->get_CanGoForward(&canGoForward);
  return canGoForward;
}



void Webview::GetCookies(const std::string &url, GetCookiesCallback callback)
{
  if (!IsValid())
  {
    return;
  }

  wil::com_ptr<ICoreWebView2CookieManager> cookieManager;
  reinterpret_cast<ICoreWebView2_2 *>(webview_.get())->get_CookieManager(cookieManager.put());
  
  std::wstring uri = to_lpwstr(url);
  OutputDebugString((std::wstring(L"uri:") + uri).c_str());

  cookieManager->GetCookies(
      uri.c_str(), Callback<ICoreWebView2GetCookiesCompletedHandler>(
                       [this, uri, callback](HRESULT error_code, ICoreWebView2CookieList *list) -> HRESULT
                       {
                         std::string result;
                         UINT cookie_list_size;
                         list->get_Count(&cookie_list_size);

                         for (UINT i = 0; i < cookie_list_size; i++)
                         {
                           wil::com_ptr<ICoreWebView2Cookie> cookie;
                           list->GetValueAtIndex(i, &cookie);
                           LPWSTR name_ptr;
                           cookie->get_Name(&name_ptr);
                           LPWSTR value_ptr;
                           cookie->get_Value(&value_ptr);

                           result += from_lpwstr(name_ptr) + "=" + from_lpwstr(value_ptr) + ";";

                           //  OutputDebugString((std::wstring(L"name:") + std::wstring(name_ptr) + std::wstring(L"value:") + std::wstring(value_ptr)).c_str());
                         }
                         if (cookie_list_size > 0)
                         {
                           result = result.substr(0, result.size() - 1);
                         }
                         OutputDebugStringA((std::string("result:") + result).c_str());
                         callback(result);

                         return S_OK;
                       })
                       .Get());
}

void Webview::ExecuteScript(const std::string &script,
                            ScriptExecutedCallback callback)
{
  if (IsValid())
  {
    if (SUCCEEDED(webview_->ExecuteScript(
            get_utf16(script, CP_UTF8).c_str(),
            Callback<ICoreWebView2ExecuteScriptCompletedHandler>(
                [callback](HRESULT result, PCWSTR _)
                {
                  callback(SUCCEEDED(result));
                  return S_OK;
                })
                .Get())))
    {
      return;
    }
  }

  callback(false);
}

bool Webview::PostWebMessage(const std::string &json)
{
  if (!IsValid())
  {
    return false;
  }
  return webview_->PostWebMessageAsJson(towstring(json).c_str()) == S_OK;
}

bool Webview::Suspend()
{
  if (!IsValid())
  {
    return false;
  }

  wil::com_ptr<ICoreWebView2_3> webview;
  webview = webview_.query<ICoreWebView2_3>();
  if (!webview)
  {
    return false;
  }

  webview_controller_->put_IsVisible(false);
  return webview->TrySuspend(
             Callback<ICoreWebView2TrySuspendCompletedHandler>(
                 [](HRESULT error_code, BOOL is_successful) -> HRESULT
                 {
                   return S_OK;
                 })
                 .Get()) == S_OK;
}

bool Webview::Resume()
{
  if (!IsValid())
  {
    return false;
  }

  wil::com_ptr<ICoreWebView2_3> webview;
  webview = webview_.query<ICoreWebView2_3>();
  if (!webview)
  {
    return false;
  }
  return webview->Resume() == S_OK &&
         webview_controller_->put_IsVisible(true) == S_OK;
}
