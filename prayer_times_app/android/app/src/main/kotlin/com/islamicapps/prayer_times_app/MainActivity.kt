package com.islamicapps.prayer_times_app

import android.media.MediaPlayer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var player: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "update" -> {
                        @Suppress("UNCHECKED_CAST")
                        val args = call.arguments as? Map<String, Any?>
                        if (args == null) {
                            result.error("args", "بيانات الودجت ناقصة", null)
                            return@setMethodCallHandler
                        }
                        MoqoutaWidgets.save(this, args)
                        MoqoutaWidgets.updateAll(this)
                        MoqoutaWidgets.schedule(this)
                        result.success(null)
                    }
                    "playTakbeer" -> {
                        playTakbeer()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun playTakbeer() {
        player?.release()
        player = MediaPlayer.create(this, R.raw.takbeer)?.apply {
            setOnCompletionListener { media ->
                media.release()
                if (player === media) player = null
            }
            start()
        }
    }

    override fun onDestroy() {
        player?.release()
        player = null
        super.onDestroy()
    }

    companion object {
        const val CHANNEL = "com.islamicapps.prayer_times_app/widget"
    }
}
