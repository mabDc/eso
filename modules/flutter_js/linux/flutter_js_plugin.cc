#include "include/flutter_js/flutter_js_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>
#include <iostream>
#include <map>
#include "quickjs/quickjspp.hpp"

#define FLUTTER_JS_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_js_plugin_get_type(), \
                              FlutterJsPlugin))

struct _FlutterJsPlugin
{
  GObject parent_instance;
};

G_DEFINE_TYPE(FlutterJsPlugin, flutter_js_plugin, g_object_get_type())

std::map<int, qjs::Context *> jsEngineMap;
const char kCommandKey[] = "command";
const char kEngineIdKey[] = "engineId";

// Called when a method call is received from Flutter.
static void flutter_js_plugin_handle_method_call(
    FlutterJsPlugin *self,
    FlMethodCall *method_call)
{
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar *method = fl_method_call_get_name(method_call);
  FlValue *args = fl_method_call_get_args(method_call);
  std::cout << method << std::endl;

  if (strcmp(method, "getPlatformVersion") == 0)
  {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else if (strcmp(method, "initEngine") == 0)
  {
    int engineId = fl_value_get_int(args);
    // qjs::Runtime *runtime = new qjs::Runtime();
    // qjs::Context *context = new qjs::Context(*runtime);
    // export classes as a module
    // auto &module = context->addModule("WindowsBaseMoudle");
    // module.function<&println>("println").function<&httpGet>("httpGet");
    // // import module
    // context->eval("import * as windowsBaseMoudle from 'WindowsBaseMoudle';"
    //               "globalThis.windowsBaseMoudle = windowsBaseMoudle;",
    //               "<import>", JS_EVAL_TYPE_MODULE);
    // context->eval("console = {};"
    //               "console.log = function(s) { return windowsBaseMoudle.println(s); };"
    //               "http = {};"
    //               "http.get = function(s) { return windowsBaseMoudle.httpGet(s); };");
    // jsEngineMap[engineId] = context;
    g_autoptr(FlValue) result = fl_value_new_int(engineId);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else if (strcmp(method, "evaluate") == 0)
  {
    FlValue *commandValue = fl_value_lookup_string(args, kCommandKey);
    std::string command = fl_value_get_string(commandValue);
    FlValue *engineIdValue = fl_value_lookup_string(args, kEngineIdKey);
    int engineId = fl_value_get_int(engineIdValue);
    auto ctx = jsEngineMap.at(engineId);
    try
    {
      auto resultJS = ctx->eval(command);
      g_autoptr(FlValue) result = fl_value_new_string(resultJS.toJSON().c_str());
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    }
    catch (qjs::exception)
    {
      auto exc = ctx->getException();
      std::string err = (std::string)exc;
      if ((bool)exc["stack"])
        err += "\n" + (std::string)exc["stack"];
      std::cerr << err << std::endl;
      g_autoptr(FlValue) result = fl_value_new_string(err.c_str());
      response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
      // result->Error("FlutterJSException", err);
    }
  }
  else if (strcmp(method, "close") == 0)
  {
    FlValue *engineIdValue = fl_value_lookup_string(args, kEngineIdKey);
    int engineId = fl_value_get_int(engineIdValue);
    if (jsEngineMap.count(engineId))
    {
      delete jsEngineMap.at(engineId);
      jsEngineMap.erase(engineId);
    }
  }
  else
  {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void flutter_js_plugin_dispose(GObject *object)
{
  G_OBJECT_CLASS(flutter_js_plugin_parent_class)->dispose(object);
  jsEngineMap.clear();
}

static void flutter_js_plugin_class_init(FlutterJsPluginClass *klass)
{
  G_OBJECT_CLASS(klass)->dispose = flutter_js_plugin_dispose;
}

static void flutter_js_plugin_init(FlutterJsPlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data)
{
  FlutterJsPlugin *plugin = FLUTTER_JS_PLUGIN(user_data);
  flutter_js_plugin_handle_method_call(plugin, method_call);
}

void flutter_js_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
  FlutterJsPlugin *plugin = FLUTTER_JS_PLUGIN(
      g_object_new(flutter_js_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "io.abner.flutter_js",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
