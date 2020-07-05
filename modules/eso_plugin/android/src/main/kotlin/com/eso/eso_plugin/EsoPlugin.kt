package com.eso.eso_plugin

import androidx.annotation.NonNull;
import android.util.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** EsoPlugin */
public class EsoPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "eso_plugin")
    channel.setMethodCallHandler(this);
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "eso_plugin")
      channel.setMethodCallHandler(EsoPlugin())
      methodChannel = channel;
    }

    @JvmStatic
    private var methodChannel: MethodChannel? = null

    @JvmStatic
    var enabledCaptureVolumeKeyboard = false

    @JvmStatic
    fun doVolumeKeyboardInc() {
      Log.d("aaa", "keyboard_Volume_inc")
      methodChannel?.invokeMethod("keyboard_Volume_inc", 1)
    }

    @JvmStatic
    fun doVolumeKeyboardDec() {
      Log.d("aaa", "keyboard_Volume_dec")
      methodChannel?.invokeMethod("keyboard_Volume_dec", 1)
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "captureVolumeKeyboard") {
      this.captureVolumeKeyboard(call.arguments as Int);
      result.success(true);
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun captureVolumeKeyboard(state: Int) {
    enabledCaptureVolumeKeyboard = state == 1
  }



}
