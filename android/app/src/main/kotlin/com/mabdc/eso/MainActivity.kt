package com.mabdc.eso

import io.flutter.embedding.android.FlutterActivity
import com.eso.eso_plugin.EsoPlugin
import android.view.KeyEvent
import android.util.Log


class MainActivity: FlutterActivity() {

  /**
   * 按键事件
   */
  override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
    when (keyCode) {
      KeyEvent.KEYCODE_VOLUME_UP -> {
        if (volumeKeyPage(0)) {
          return true
        }
      }
      KeyEvent.KEYCODE_VOLUME_DOWN -> {
        if (volumeKeyPage(1)) {
          return true
        }
      }
    }
    return super.onKeyDown(keyCode, event)
  }

  /**
   * 音量键翻页
   */
  private fun volumeKeyPage(direction: Int): Boolean {
    // Log.d("ESO Plugin", "volumnKeyPage")
    // Log.d("ESO Plugin", EsoPlugin.enabledCaptureVolumeKeyboard.toString())
    if (EsoPlugin.enabledCaptureVolumeKeyboard == true) {
      if (direction == 0)
        EsoPlugin.doVolumeKeyboardDec()
      else
        EsoPlugin.doVolumeKeyboardInc()
      return true
    }
    return false
  }
}
