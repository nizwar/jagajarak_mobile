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
        if (application.notifSink != null) {
            try {
                @SuppressLint("CommitPrefEdits") SharedPreferences.Editor sprefEdit = application.getSharedPreferences(FLUTTER_SHAREDPREF, Context.MODE_PRIVATE).edit();
                switch(result.notification.payload.additionalData.get("kondisi").toString()){
                    case "odp":
                        application.notifSink.success("odp");
                        sprefEdit.putString("flutter.kondisi","odp");
                        break;
                    case "pdp":
                        application.notifSink.success("pdp");
                        sprefEdit.putString("flutter.kondisi","pdp");
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
    }


}
