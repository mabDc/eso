package soko.ekibun.flutter_webview

import android.annotation.SuppressLint
import android.content.Context
import android.os.Handler
import android.webkit.*
import io.flutter.plugin.common.MethodChannel

class Offscreen(context: Context, private val _id: Int, private val channel: MethodChannel) : WebView(context) {
  val uiHandler: Handler = Handler{true}
  
  fun finish() {
    onPause()
    clearCache(true)
    clearHistory()
    destroy()
  }

  private fun invokeChannelMethod(name: String, args: Any?) {
    if(Thread.currentThread() != uiHandler.looper.thread){
      uiHandler.post{ invokeChannelMethod(name, args) }
      return
    }
    channel.invokeMethod(name, hashMapOf("webview" to _id, "args" to args))
  }

  init {
    @SuppressLint("SetJavaScriptEnabled")
    settings.javaScriptEnabled = true
    settings.useWideViewPort = true
    settings.loadWithOverviewMode = true
    settings.domStorageEnabled = true
    settings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
    settings.blockNetworkImage = true
    webViewClient = object : WebViewClient() {
      override fun onPageFinished(view: WebView?, url: String?) {
        super.onPageFinished(view, url)
        invokeChannelMethod("onNavigationCompleted", null)
      }
      override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
        if (!url.startsWith("http")) {
          return true
        }
        return false
      }
      override fun shouldInterceptRequest(view: WebView, request: WebResourceRequest): WebResourceResponse? {
        val url = request.url.toString()
        invokeChannelMethod("onRequest", hashMapOf<String, Any?>(
          "url" to url,
          "method" to request.method,
          "headers" to ArrayList<HashMap<String, String>>(request.requestHeaders.map { hashMapOf(it.key to it.value) })
        ))
        return super.shouldInterceptRequest(view, request)
      }
    }
  }
}
