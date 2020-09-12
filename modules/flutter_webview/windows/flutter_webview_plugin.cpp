/*
 * @Description: 
 * @Author: ekibun
 * @Date: 2020-08-20 23:25:54
 * @LastEditors: ekibun
 * @LastEditTime: 2020-08-25 22:49:04
 */
#include "include/flutter_webview/flutter_webview_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <flutter/method_result_functions.h>

#include "offscreen.hpp"

namespace
{

  class FlutterWebviewPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    FlutterWebviewPlugin();

    virtual ~FlutterWebviewPlugin();

  private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  };

  std::shared_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel;
  void invokeChannelMethod(std::string name, flutter::EncodableValue args, int64_t webview)
  {
    auto map = new flutter::EncodableMap();
    (*map)[std::string("webview")] = webview;
    (*map)[std::string("args")] = args;
    
    channel->InvokeMethod(
        name,
        std::make_unique<flutter::EncodableValue>(map),
        nullptr);
  }

  const flutter::EncodableValue &ValueOrNull(const flutter::EncodableMap &map, const char *key)
  {
    static flutter::EncodableValue null_value;
    auto it = map.find(flutter::EncodableValue(key));
    if (it == map.end())
    {
      return null_value;
    }
    return it->second;
  }

  HWND hWnd;

  // static
  void FlutterWebviewPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        registrar->messenger(), "soko.ekibun.flutter_webview",
        &flutter::StandardMethodCodec::GetInstance());

    hWnd = registrar->GetView()->GetNativeWindow();

    auto plugin = std::make_unique<FlutterWebviewPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  FlutterWebviewPlugin::FlutterWebviewPlugin() {}

  FlutterWebviewPlugin::~FlutterWebviewPlugin() {}

  void FlutterWebviewPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    // Replace "getPlatformVersion" check with your plugin's method.
    // See:
    // https://github.com/flutter/engine/tree/master/shell/platform/common/cpp/client_wrapper/include/flutter
    // and
    // https://github.com/flutter/engine/tree/master/shell/platform/glfw/client_wrapper/include/flutter
    // for the relevant Flutter APIs.
    if (method_call.method_name().compare("create") == 0)
    {
      new webview::Offscreen(hWnd, channel, result.release());
    }
    else if (method_call.method_name().compare("navigate") == 0)
    {
      flutter::EncodableMap args = *std::get_if<flutter::EncodableMap>(method_call.arguments());
      webview::Offscreen *wv = (webview::Offscreen *)std::get<int64_t>(ValueOrNull(args, "webview"));
      std::string url = std::get<std::string>(ValueOrNull(args, "url"));
      flutter::EncodableValue response = (wv && wv->navigate(url));
      result->Success(&response);
    }
    else if (method_call.method_name().compare("evaluate") == 0)
    {
      flutter::EncodableMap args = *std::get_if<flutter::EncodableMap>(method_call.arguments());
      webview::Offscreen *wv = (webview::Offscreen *)std::get<int64_t>(ValueOrNull(args, "webview"));
      std::string script = std::get<std::string>(ValueOrNull(args, "script"));
      if(!(wv && wv->evaluate(script, result.release()))){
        result->Error(webview::TAG, "Error at evaluate");
      }
    }
    else if (method_call.method_name().compare("setUserAgent") == 0)
    {
      flutter::EncodableMap args = *std::get_if<flutter::EncodableMap>(method_call.arguments());
      webview::Offscreen *wv = (webview::Offscreen *)std::get<int64_t>(ValueOrNull(args, "webview"));
      std::string ua = std::get<std::string>(ValueOrNull(args, "ua"));
      if(!(wv && wv->callDevToolsProtocolMethod("Network.setUserAgentOverride", "{\"userAgent\":\"" + ua + "\"}", result.release()))){
        result->Error(webview::TAG, "Error at evaluate");
      }
    }
    else if (method_call.method_name().compare("close") == 0)
    {
      webview::Offscreen *wv = (webview::Offscreen *)*std::get_if<int64_t>(method_call.arguments());
      delete wv;
      result->Success();
    }
    else
    {
      result->NotImplemented();
    }
  }

} // namespace

void FlutterWebviewPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  FlutterWebviewPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
