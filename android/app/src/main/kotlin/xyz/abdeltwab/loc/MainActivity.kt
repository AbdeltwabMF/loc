package xyz.abdeltwab.loc

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private var geoIntentSink: EventChannel.EventSink? = null
    private var pendingGeoUri: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingGeoUri = geoUri(intent)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "xyz.abdeltwab.loc/geo_intents",
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                geoIntentSink = events
                pendingGeoUri?.let(events::success)
                pendingGeoUri = null
            }

            override fun onCancel(arguments: Any?) {
                geoIntentSink = null
            }
        })
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        geoUri(intent)?.let { uri ->
            val sink = geoIntentSink
            if (sink == null) {
                pendingGeoUri = uri
            } else {
                sink.success(uri)
            }
        }
    }

    private fun geoUri(intent: Intent?): String? = intent
        ?.takeIf { it.action == Intent.ACTION_VIEW && it.data?.scheme == "geo" }
        ?.data
        ?.toString()
}
