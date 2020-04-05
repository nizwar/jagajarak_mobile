package id.nizwar.jagajarak;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.onesignal.OSNotificationOpenResult;
import com.onesignal.OneSignal;

import org.json.JSONException;

import static android.content.ContentValues.TAG;
import static id.nizwar.jagajarak.BlueReceiver.FLUTTER_SHAREDPREF;

public class OnesignalNotifHandler implements OneSignal.NotificationOpenedHandler {
    private final Application application;

    OnesignalNotifHandler(Application application) {
        this.application = application;
    }


    @Override
    public void notificationOpened(OSNotificationOpenResult result) {

    }


}
