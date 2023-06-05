package org.thingsboard.app

import android.app.Activity
import android.net.Uri
import android.os.Bundle
import android.util.Log

class TbWebCallbackActivity: Activity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    if (BuildConfig.DEBUG) {
    Log.d("ViewRootImpl", "updateLoggingLevel: 1")
    Log.d("FrameMetricsObserver", "updateLoggingLevel: 1")
}

    val url = intent?.data
    val scheme = url?.scheme

    if (scheme != null) {
        TbWebAuthHandler.callbacks.remove(scheme)?.success(url.toString())
    }

    finish()
  }
}
