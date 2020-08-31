package io.abner.flutter_js

import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import kotlinx.coroutines.runBlocking
import android.os.Looper
import android.os.Handler

/** FlutterJsPlugin */
class FlutterJsPlugin: FlutterPlugin, MethodCallHandler {
  private var applicationContext: android.content.Context? = null
  private var methodChannel: MethodChannel? = null
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    onAttachedToEngine(flutterPluginBinding.applicationContext, flutterPluginBinding.binaryMessenger)
  }

  private fun onAttachedToEngine(applicationContext: android.content.Context, messenger: BinaryMessenger) {
    this.applicationContext = applicationContext
    methodChannel = MethodChannel(messenger, "io.abner.flutter_js")
    methodChannel!!.setMethodCallHandler(this)
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val instance = FlutterJsPlugin()
      instance.onAttachedToEngine(registrar.context(), registrar.messenger())
    }

    private var jsEngineMap = mutableMapOf<Int, JSEngine>()
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "initEngine") {
      Log.d("FlutterJS", call.arguments.toString())
      val engineId = call.arguments as Int
      jsEngineMap[engineId] = JSEngine(applicationContext!!)
      result.success(engineId)
    } else if (call.method == "evaluate") {
      Thread {
        //runBlocking {
          try {
            Log.d("FlutterJs", call.arguments.toString())
            val jsCommand: String = call.argument<String>("command")!!
            val engineId: Int = call.argument<Int>("engineId")!!
            val resultJS = jsEngineMap[engineId]!!.eval(jsCommand)
            Handler(Looper.getMainLooper()).post {
              result.success(resultJS.toString())
              // Call the desired channel message here.
            }
          } catch (e: Exception) {
            Handler(Looper.getMainLooper()).post {
              result.error("FlutterJSException", e.message + e.toString(), null)
            }
          }

        //}
        }.start();
      } else if (call.method == "close") {
        if (call.hasArgument("engineId")) {
          val engineId: Int = call.argument<Int>("engineId")!!
          if (jsEngineMap.containsKey(engineId)) {
            val jsEngine = jsEngineMap[engineId]!!
            jsEngine.release()
            jsEngineMap.remove(engineId)
          }
        }
      } else {
        result.notImplemented()
      }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    jsEngineMap.forEach { engine -> engine.value.release() }
  }
}
