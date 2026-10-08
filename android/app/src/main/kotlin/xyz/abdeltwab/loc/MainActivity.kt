package xyz.abdeltwab.loc

import android.content.Intent
import android.net.Uri
import android.app.LocaleManager
import android.os.Build
import android.os.LocaleList
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

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
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "xyz.abdeltwab.loc/power",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isBatteryExempt" -> result.success(isBatteryExempt())
                "requestBatteryExemption" -> {
                    if (isBatteryExempt()) {
                        result.success(true)
                    } else {
                        openBatteryExemption()
                        // User decision happens in system UI; UI refreshes
                        // status on return via didChangeDependencies.
                        result.success(false)
                    }
                }

                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "xyz.abdeltwab.loc/settings",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openNotificationSettings" -> {
                    openNotificationSettings()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "xyz.abdeltwab.loc/locale",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getApplicationLocale" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        val locales = getSystemService(LocaleManager::class.java).applicationLocales
                        result.success(
                            mapOf(
                                "supported" to true,
                                "languageCode" to locales.takeUnless { it.isEmpty }?.get(0)?.language,
                            )
                        )
                    } else {
                        result.success(mapOf("supported" to false))
                    }
                }

                "setApplicationLocale" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        val languageCode = call.arguments as? String
                        val locales = if (languageCode == null) {
                            LocaleList.getEmptyLocaleList()
                        } else {
                            LocaleList.forLanguageTags(languageCode)
                        }
                        getSystemService(LocaleManager::class.java).applicationLocales = locales
                    }
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
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
        intent?.action == Intent.ACTION_VIEW && intent.data?.scheme == "geo" -> intent.data?.toString()
        intent?.action == Intent.ACTION_SEND && intent.type?.startsWith("text/") == true -> intent.getCharSequenceExtra(
            Intent.EXTRA_TEXT
        )?.toString()

        else -> null
    }

    private fun isBatteryExempt(): Boolean {
        val manager = getSystemService(POWER_SERVICE) as? PowerManager ?: return true
        return manager.isIgnoringBatteryOptimizations(packageName)
    }

    private fun openAppSettings() {
        try {
            startActivity(
                Intent(
                    Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.parse("package:$packageName"),
                ),
            )
        } catch (_: Exception) {
        }
    }

    private fun openBatteryExemption() {
        try {
            startActivity(
                Intent(
                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                    Uri.parse("package:$packageName"),
                ),
            )
        } catch (_: Exception) {
            openAppSettings()
        }
    }

    private fun openNotificationSettings() {
        try {
            startActivity(
                Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                },
            )
        } catch (_: Exception) {
            openAppSettings()
        }
    }

}
