package id.nizwar.jagajarak_id;

import com.onesignal.OSNotificationOpenResult;
import com.onesignal.OneSignal;

public class OnesignalNotifHandler implements OneSignal.NotificationOpenedHandler {
    private final Application application;

    OnesignalNotifHandler(Application application) {
        this.application = application;
    }


    @Override
    public void notificationOpened(OSNotificationOpenResult result) {

    }


}
