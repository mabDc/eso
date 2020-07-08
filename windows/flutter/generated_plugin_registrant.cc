//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <path_provider_fde/path_provider_plugin.h>
#include <url_launcher_fde/url_launcher_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  PathProviderPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PathProviderPlugin"));
  UrlLauncherPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherPlugin"));
}
