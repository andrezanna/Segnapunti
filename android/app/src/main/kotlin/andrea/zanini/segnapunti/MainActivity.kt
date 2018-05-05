package andrea.zanini.segnapunti

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity(): FlutterActivity() {
    private val CHANNEL = "andrea.zanini.segnapunti/system_version"


    override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSystemVersion") {
                val systemVersion = getSystemVersion()
                result.success(systemVersion)

            } else {
                result.notImplemented()
            }
        }
    }


    internal fun getSystemVersion(): String {
        return "" + android.os.Build.VERSION.RELEASE
    }
}
