package io.abner.flutter_js

import de.prosiebensat1digital.oasisjsbridge.JsBridge
import de.prosiebensat1digital.oasisjsbridge.JsBridgeError

import kotlinx.coroutines.Dispatchers
import android.util.Log
import de.prosiebensat1digital.oasisjsbridge.JsonObjectWrapper

class JSEngine(context: android.content.Context) {

    private lateinit var runtime: JsBridge

    var runtimeInitialized = false
    init {
        runtime = JsBridge(context)
        runtime!!.start()

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