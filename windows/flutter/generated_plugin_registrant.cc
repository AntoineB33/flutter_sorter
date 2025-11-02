//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_js/flutter_js_plugin.h>
#include <hotkey_manager_windows/hotkey_manager_windows_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterJsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterJsPlugin"));
  HotkeyManagerWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("HotkeyManagerWindowsPluginCApi"));
}
