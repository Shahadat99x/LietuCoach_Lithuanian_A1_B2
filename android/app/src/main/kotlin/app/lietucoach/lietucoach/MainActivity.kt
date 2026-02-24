package app.lietucoach.lietucoach

import io.flutter.embedding.android.FlutterActivity

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

import android.Manifest // Not needed but avoiding breaking imports
import android.content.Intent
import android.os.Bundle
import android.util.Log

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "app.lietucoach/pad"
    private val EVENT_CHANNEL = "app.lietucoach/pad_progress"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("OAUTH", "onCreate data=" + intent?.dataString)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d("OAUTH", "onNewIntent data=" + intent.dataString)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        val eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)

        PadMethodChannelHandler(this, methodChannel, eventChannel)
    }
}
