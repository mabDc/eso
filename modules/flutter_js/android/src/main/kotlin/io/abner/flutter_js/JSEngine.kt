package io.abner.flutter_js

import de.prosiebensat1digital.oasisjsbridge.JsBridge
import de.prosiebensat1digital.oasisjsbridge.JsBridgeError

import kotlinx.coroutines.Dispatchers
import android.util.Log
import de.prosiebensat1digital.oasisjsbridge.JsValue.Companion.fromNativeFunction1

import de.prosiebensat1digital.oasisjsbridge.JsonObjectWrapper
import okhttp3.OkHttpClient
import okhttp3.Request.Builder

class JSEngine(context: android.content.Context) {

    private lateinit var runtime: JsBridge

    var runtimeInitialized = false
    init {
        runtime = JsBridge(context)
        runtime!!.start()
        fromNativeFunction1<String, String?>(runtime) { url: String ->
            try {
                OkHttpClient().newCall(Builder().url(url).build()).execute().body?.string()
            } catch (e: Exception) {
                null
            }
        }.assignToGlobal("HTTPExtension_getString")
        runtime.evaluateNoRetVal("var http = {}; http.get = HTTPExtension_getString;")
        val errorListener = object : JsBridge.ErrorListener(Dispatchers.Main) {
            override fun onError(error: JsBridgeError) {
                Log.e("MainActivity", error.errorString())
            }
        }
        runtime!!.registerErrorListener(errorListener)
    }



    fun eval(script: String): JsonObjectWrapper {
        return runtime!!.evaluateBlocking(script, JsonObjectWrapper::class.java) as JsonObjectWrapper
    }

    fun release() {
        runtime!!.release()

    }

}