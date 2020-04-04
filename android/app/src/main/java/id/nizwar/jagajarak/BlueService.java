package id.nizwar.jagajarak;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.IBinder;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class BlueService extends Service  {
    BluetoothAdapter blueAdapter;
    final int NOTIFICATION_ID = 1;
    final String CHANNEL_ID = "JagaJarakFlutterNotificaion";
    ScheduledExecutorService scheduleTaskExecutor = Executors.newScheduledThreadPool(5);

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public boolean onUnbind(Intent intent) {
        try {
            unregisterReceiver(new BlueReceiver());
        }catch (RuntimeException ignored){
        }
        return super.onUnbind(intent);
    }

    @Override
    public void onDestroy() {
        try {
            unregisterReceiver(new BlueReceiver());
        }catch (RuntimeException ignored){
        }
        super.onDestroy();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        blueAdapter = BluetoothAdapter.getDefaultAdapter();
        if (blueAdapter == null) {
            Toast.makeText(this, "Bluetooth mati, layanan dihentikan", Toast.LENGTH_SHORT).show();
            stopService(intent);
        }

        IntentFilter filter = new IntentFilter();
        filter.addAction(BluetoothDevice.ACTION_FOUND);
        filter.addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
        filter.addAction(BluetoothAdapter.ACTION_STATE_CHANGED);
        filter.addAction(BluetoothDevice.ACTION_BOND_STATE_CHANGED);
        registerReceiver(new BlueReceiver(), filter);
        startForeground(intent);
        return super.onStartCommand(intent, flags, startId);
    }


    private void startForeground(Intent intent) {
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this, 0, notificationIntent, 0
        );

        if (blueAdapter == null) {
            Toast.makeText(this, "Bluetooth mati, layanan dihentikan", Toast.LENGTH_SHORT).show();
            stopService(intent);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationManager notificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            NotificationChannel notificationChannel = new NotificationChannel(CHANNEL_ID, CHANNEL_ID, NotificationManager.IMPORTANCE_DEFAULT);
            notificationChannel.setDescription(CHANNEL_ID);
            notificationChannel.setSound(null, null);
            assert notificationManager != null;
            notificationManager.createNotificationChannel(notificationChannel);
            startForeground(
                    NOTIFICATION_ID, new NotificationCompat.Builder(this, CHANNEL_ID)
                            .setOngoing(true)
                            .setSmallIcon(R.drawable.ic_logo)
                            .setContentText(getString(R.string.app_name) + " - Layanan sedang berjalan")
                            .setContentIntent(pendingIntent)
                            .build()
            );
        }
        scheduleTaskExecutor.scheduleAtFixedRate(this::nearbyDevice, 0, 30, TimeUnit.SECONDS);
    }

    private void nearbyDevice() {
        if (blueAdapter.isDiscovering()) {
            blueAdapter.cancelDiscovery();
        }
        if (!blueAdapter.startDiscovery()) {
            Toast.makeText(this, "Gagal melakukan pemindaian titik singgung", Toast.LENGTH_SHORT).show();
        }
    }
}
