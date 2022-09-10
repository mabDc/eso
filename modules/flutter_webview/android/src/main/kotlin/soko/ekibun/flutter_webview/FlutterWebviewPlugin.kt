package soko.ekibun.flutter_webview

import androidx.annotation.NonNull

import java.util.ArrayList
import android.content.Context

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FlutterWebviewPlugin */
class FlutterWebviewPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context : Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "soko.ekibun.flutter_webview")
    channel.setMethodCallHandler(this)
  }

  private val webviews by lazy { ArrayList<Offscreen?>() }  

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "create") {
      val id = webviews.indexOfFirst { it == null }
      if(id < 0){
        webviews.add(Offscreen(context, webviews.size, channel))
        result.success(webviews.size - 1)
      }else{
        webviews.set(id, Offscreen(context, id, channel))
        result.success(id)
      }
    } else if (call.method == "navigate") {
      val id = call.argument<Int>("webview")!!
      val url = call.argument<String>("url")
      webviews[id]?.loadUrl(url)
      result.success(webviews[id] != null)
    } else if (call.method == "setCookies") {
      val id = call.argument<Int>("webview")!!
      val url = call.argument<String>("url")
      val cookies = call.argument<String>("cookies")
      val cookieManager = android.webkit.CookieManager.getInstance();
      cookieManager.setCookie(url, cookies)
      result.success(webviews[id] != null)
    } else if (call.method == "setUserAgent") {
      val id = call.argument<Int>("webview")!!
      val ua = call.argument<String>("ua")
      webviews[id]?.settings?.userAgentString = ua
      result.success(webviews[id] != null)
    } else if (call.method == "evaluate") {
      val id = call.argument<Int>("webview")!!
      val script = call.argument<String>("script")
      webviews[id]?.let { webview ->
        webview.evaluateJavascript(script) { res ->
          webview.uiHandler.post { result.success(res) }
        }
      }
    } else if (call.method == "close") {
      val id = call.arguments<Int>()!!
      webviews[id]?.finish()
      webviews[id] = null
      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
