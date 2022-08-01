package cloud.logsnx.mobile

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.GeneratedPluginRegistrant

class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
        //FlutterFirebaseMessagingService.setPluginRegistrant(this)
            //BackgroundFetchPlugin.setPluginRegistrant(this);

    }

    override fun registerWith(registry: PluginRegistry) {
        //FirebaseCloudMessagingPluginRegistrant.registerWith(registry);
    }
}