package com.example.movie_app


import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "deep_link_channel"
    private var pendingLink: String? = null
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // if we stored a pending link (from onCreate before channel init) send it now
        pendingLink?.let {
            methodChannel?.invokeMethod("handleDeepLink", it)
            pendingLink = null
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val data = intent?.dataString
        if (data != null) {
            if (methodChannel != null) {
                methodChannel?.invokeMethod("handleDeepLink", data)
            } else {
                // methodChannel not yet ready — store pending
                pendingLink = data
            }
        }
    }
}