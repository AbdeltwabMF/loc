package xyz.abdeltwab.loc

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private var geoIntentSink: EventChannel.EventSink? = null
    private var pendingLocation: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingLocation = sharedLocation(intent)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "xyz.abdeltwab.loc/geo_intents",
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                geoIntentSink = events
                pendingLocation?.let(events::success)
                pendingLocation = null
            }

            override fun onCancel(arguments: Any?) {
                geoIntentSink = null
            }
        })
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        sharedLocation(intent)?.let { location ->
            val sink = geoIntentSink
            if (sink == null) {
                pendingLocation = location
            } else {
                sink.success(location)
            }
        }
    }

    private fun sharedLocation(intent: Intent?): String? = when {
        intent?.action == Intent.ACTION_VIEW && intent.data?.scheme == "geo" ->
            intent.data?.toString()
        intent?.action == Intent.ACTION_SEND && intent.type?.startsWith("text/") == true ->
            intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        else -> null
    }
}
