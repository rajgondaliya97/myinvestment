package com.infinite.wealth

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.infinite.wealth/deeplink"
    private val TAG = "MainActivity"
    private var methodChannel: MethodChannel? = null
    private var lastProcessedUri: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            if (call.method == "getInitialLink") {
                result.success(intent?.data?.toString())
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "🔗 [Native] onCreate called")
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d(TAG, "🔗 [Native] onNewIntent called")
        setIntent(intent)
        handleIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        Log.d(TAG, "🔗 [Native] onResume called")
        Log.d(TAG, "🔗 [Native] Intent in onResume: ${intent?.data}")

        // CRITICAL: Process intent again on resume
        // This catches deep links when returning from MetaMask
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val action = intent?.action
        val data = intent?.data

        Log.d(TAG, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        Log.d(TAG, "🔍 [Native] handleIntent called")
        Log.d(TAG, "🔍 [Native] Action: $action")
        Log.d(TAG, "🔍 [Native] Data: $data")
        Log.d(TAG, "🔍 [Native] Intent: $intent")
        Log.d(TAG, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        if (Intent.ACTION_VIEW == action && data != null) {
            val deepLink = data.toString()

            // Prevent duplicate processing
            if (deepLink == lastProcessedUri) {
                Log.d(TAG, "⚠️ [Native] Duplicate deep link, skipping: $deepLink")
                return
            }

            lastProcessedUri = deepLink

            Log.d(TAG, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            Log.d(TAG, "🔗 [Native] DEEP LINK RECEIVED!")
            Log.d(TAG, "🔗 [Native] URI: $deepLink")
            Log.d(TAG, "🔗 [Native] Scheme: ${data.scheme}")
            Log.d(TAG, "🔗 [Native] Host: ${data.host}")
            Log.d(TAG, "🔗 [Native] Path: ${data.path}")
            Log.d(TAG, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

            // 🔥 CRITICAL: Show toast to confirm deep link received
            runOnUiThread {
                Toast.makeText(
                    this,
                    "Deep link received: ${data.scheme}://${data.host}",
                    Toast.LENGTH_SHORT
                ).show()
            }

            // Send to Flutter via MethodChannel
            methodChannel?.invokeMethod("onDeepLink", deepLink)?.also {
                Log.d(TAG, "✅ [Native] Deep link sent to Flutter successfully")
            } ?: Log.e(TAG, "❌ [Native] MethodChannel is null!")
        } else {
            Log.d(TAG, "🔗 [Native] No deep link in intent")
        }
    }
}