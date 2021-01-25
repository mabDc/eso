#include "include/windows_speak/windows_speak_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>
#include <sapi.h>
#include <future>

namespace
{

  class WindowsSpeakPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    WindowsSpeakPlugin();

    virtual ~WindowsSpeakPlugin();

  private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  };

  // static
  void WindowsSpeakPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "windows_speak",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<WindowsSpeakPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  WindowsSpeakPlugin::WindowsSpeakPlugin() {}

  WindowsSpeakPlugin::~WindowsSpeakPlugin() {}

  std::wstring string2wstring(const std::string &str)
  {
    std::wstring result;
    int len = MultiByteToWideChar(CP_UTF8, 0, str.c_str(), str.size(), NULL, 0);
    if (len < 0)
      return result;
    wchar_t *buffer = new wchar_t[len + 1];
    if (buffer == NULL)
      return result;
    MultiByteToWideChar(CP_UTF8, 0, str.c_str(), str.size(), buffer, len);
    buffer[len] = '\0';
    result.append(buffer);
    delete[] buffer;
    return result;
  }

  bool speak(const std::string &s)
  {
    ISpVoice *pVoice = NULL;
    //COM初始化
    if (FAILED(::CoInitialize(NULL)))
    {
      return false;
    }
    else
    {
      //获取ISpVoice接口
      HRESULT hr = CoCreateInstance(CLSID_SpVoice, NULL, CLSCTX_ALL, IID_ISpVoice, (void **)&pVoice);
      if (SUCCEEDED(hr))
      {
        hr = pVoice->Speak(string2wstring(s).c_str(), 0, NULL);
        pVoice->Release();
        pVoice = NULL;
        //千万不要忘记：
        ::CoUninitialize();
        return true;
      }
      ::CoUninitialize();
      return false;
    }
  }

  void WindowsSpeakPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (method_call.method_name().compare("getPlatformVersion") == 0)
    {
      std::ostringstream version_stream;
      version_stream << "Windows ";
      if (IsWindows10OrGreater())
      {
        version_stream << "10+";
      }
      else if (IsWindows8OrGreater())
      {
        version_stream << "8";
      }
      else if (IsWindows7OrGreater())
      {
        version_stream << "7";
      }
      result->Success(flutter::EncodableValue(version_stream.str()));
    }
    else if (method_call.method_name().compare("speak") == 0)
    {
      const auto s = *std::get_if<std::string>(method_call.arguments());
      // std::async(std::launch::deferred, speak, s);
      std::thread th = std::thread(speak, s);
      th.join();
      // if (std::async(std::launch::async, speak, s).get())
      // {
      //   result->Error("WindowsSpeakException", "COM初始化失败");
      // }
      // result->Success(flutter::EncodableValue(true));
    }
    else
    {
      result->NotImplemented();
    }
  }

} // namespace

void WindowsSpeakPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
  WindowsSpeakPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
