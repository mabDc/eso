//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <file_chooser/file_chooser_plugin.h>
#include <flutter_js/flutter_js_plugin.h>
#include <flutter_webview/flutter_webview_plugin.h>
#include <url_launcher_windows/url_launcher_plugin.h>
#include <windows_speak/windows_speak_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FileChooserPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FileChooserPlugin"));
  FlutterJsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterJsPlugin"));
  FlutterWebviewPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterWebviewPlugin"));
  UrlLauncherPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherPlugin"));
  WindowsSpeakPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowsSpeakPlugin"));
}
