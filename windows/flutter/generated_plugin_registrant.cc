//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_qjs/flutter_qjs_plugin.h>
#include <flutter_webview/flutter_webview_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <webview_windows/webview_windows_plugin.h>
#include <windows_speak/windows_speak_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterQjsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterQjsPlugin"));
  FlutterWebviewPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterWebviewPlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WebviewWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WebviewWindowsPlugin"));
  WindowsSpeakPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowsSpeakPlugin"));
}
