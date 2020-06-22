package id.nizwar.jagajarak;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.onesignal.OneSignal;

import org.json.JSONException;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;

import static android.content.ContentValues.TAG;
import static id.nizwar.jagajarak.BlueReceiver.FLUTTER_SHAREDPREF;

public class Application extends FlutterApplication implements PluginRegistrantCallback {
    EventChannel.EventSink osStream;
    EventChannel.EventSink serviceStream;
    EventChannel.EventSink locSignalStream;

    @Override
    public void registerWith(PluginRegistry registry) {

    }

    @Override
    public void onCreate() {
        OneSignal.startInit(this)
                .inFocusDisplaying(OneSignal.OSInFocusDisplayOption.Notification)
                .unsubscribeWhenNotificationsAreDisabled(true)
                .setNotificationReceivedHandler(notification -> {  
                    if (notification.isAppInFocus) {
                        if (osStream != null) {
                            try {
                                switch(notification.payload.additionalData.get("kondisi").toString()){
                                    case "odp":
                                        osStream.success("odp");
                                        break;
                                    case "pdp":
                                        osStream.success("pdp");
                                        break;
                                }
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            Log.d(TAG, notification.payload.additionalData.toString());
                            Log.d(TAG, "Sink not null");
                        } else {
                            Log.d(TAG, "Sink is null");
                        }
                    }
                })
                .setNotificationOpenedHandler(result -> {
                    if (osStream != null) {
                        try {
                            @SuppressLint("CommitPrefEdits") SharedPreferences.Editor sprefEdit = getSharedPreferences(FLUTTER_SHAREDPREF, Context.MODE_PRIVATE).edit();
                            switch (result.notification.payload.additionalData.get("kondisi").toString()) {
                                case "odp":
                                    osStream.success("odp");
                                    sprefEdit.putString("flutter.kondisi", "odp");
                                    break;
                                case "pdp":
                                    osStream.success("pdp");
                                    sprefEdit.putString("flutter.kondisi", "pdp");
                                    break;
                            }
                            sprefEdit.apply();
                            sprefEdit.commit();
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        Log.d(TAG, "Sink not null");
                    } else {
                        Log.d(TAG, "Sink is null");
                    }
                })
                .init();
        OneSignal.enableSound(true);
        OneSignal.enableVibrate(true);
        super.onCreate();
    }
}
