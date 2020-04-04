package id.nizwar.jagajarak;

import com.onesignal.OneSignal;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;

public class Application extends FlutterApplication implements PluginRegistrantCallback {
    EventChannel.EventSink notifSink;

    @Override
    public void registerWith(PluginRegistry registry) {

    }

    @Override
    public void onCreate() {
        OneSignal.startInit(this)
                .inFocusDisplaying(OneSignal.OSInFocusDisplayOption.Notification)
                .unsubscribeWhenNotificationsAreDisabled(true)
                .setNotificationOpenedHandler(new OnesignalNotifHandler(this ))
                .init();
        OneSignal.enableSound(true);
        OneSignal.enableVibrate(true);
        super.onCreate();
    }
}
