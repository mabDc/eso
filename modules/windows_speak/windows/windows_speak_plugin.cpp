#include "include/windows_speak/windows_speak_plugin.h"

#include <sapi.h>
#pragma comment(lib, "Ole32.lib") //CoInitialize CoCreateInstance需要调用ole32.dll
#pragma comment(lib, "SAPI.lib")  //sapi.lib在SDK的lib目录,必需正确配置

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
    int len = MultiByteToWideChar(CP_UTF8, 0, str.c_str(), (int)str.size(), NULL, 0);
    if (len < 0)
      return result;
    wchar_t *buffer = new wchar_t[len + 1];
    if (buffer == NULL)
      return result;
    MultiByteToWideChar(CP_UTF8, 0, str.c_str(), (int)str.size(), buffer, len);
    buffer[len] = '\0';
    result.append(buffer);
    delete[] buffer;
    return result;
  }

  struct ThreadParam
  {
    std::string str;
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result;
  };

  static ISpVoice *pVoice = NULL;

  bool speak(const std::string &s)
  {
    if (FAILED(::CoInitialize(NULL)))
    {
      return false;
    }
    if (pVoice != NULL)
    {
      pVoice->Pause();
      pVoice = NULL;
    }
    //获取ISpVoice接口
    HRESULT hr = CoCreateInstance(CLSID_SpVoice, NULL, CLSCTX_ALL, IID_ISpVoice, (void **)&pVoice);
    if (FAILED(hr))
    {
      pVoice = NULL;
      return false;
    }
    hr = pVoice->Speak(string2wstring(s).c_str(), 0, NULL);
    ::CoInitialize(NULL);
    if (FAILED(hr))
    {
      return false;
    }
    return true;
  }

  DWORD WINAPI ThreadProc(LPVOID lpParam)
  {
    ThreadParam *threadParam = (ThreadParam *)lpParam;
    threadParam->result->Success(flutter::EncodableValue(speak(threadParam->str)));
    delete threadParam;
    return 0;
  }

  void WindowsSpeakPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (method_call.method_name().compare("release") == 0)
    {
      if (pVoice == NULL)
      {
        result->Success(flutter::EncodableValue(false));
      }
      else if (FAILED(::CoInitialize(NULL)))
      {
        result->Success(flutter::EncodableValue(false));
      }
      else
      {
        pVoice->Pause();
        pVoice = NULL;
        ::CoUninitialize();
        result->Success(flutter::EncodableValue(true));
      }
    }
    else if (method_call.method_name().compare("speak") == 0)
    {
      const auto s = *std::get_if<std::string>(method_call.arguments());
      DWORD threadID;
      CreateThread(
          NULL,                                  // SD
          0,                                     // initial stack size
          (LPTHREAD_START_ROUTINE)ThreadProc,    // thread function
          new ThreadParam{s, std::move(result)}, // thread argument
          0,                                     // creation option
          &threadID                              // thread identifier
      );
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
