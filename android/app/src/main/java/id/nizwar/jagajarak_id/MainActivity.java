package id.nizwar.jagajarak_id;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.ActivityManager;
import android.app.AlertDialog;
import android.bluetooth.BluetoothAdapter;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.provider.Settings;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.onesignal.OneSignal;

import org.json.JSONObject;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static id.nizwar.jagajarak_id.BlueReceiver.FLUTTER_SHAREDPREF;

public class MainActivity extends FlutterActivity {
    private static final int REQUEST_PERMISSION = 2;
    private static final int RESPONSE_REQUEST_PERMISSION = 0;
    boolean isServicesActive = false;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState, @Nullable PersistableBundle persistentState) {
        super.onCreate(savedInstanceState, persistentState);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        Application application = (Application) getApplication();

        GeneratedPluginRegistrant.registerWith(flutterEngine);
        requestPermission();
        if (checkService()) {
            OneSignal.setSubscription(true);
        } else {
            OneSignal.setSubscription(false);
        }
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "service_stream").setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                isServicesActive = checkService();
                application.serviceStream = events;
                if (isServicesActive) {
                    events.success("start");
                } else {
                    events.success("stop");
                }
            }

            @Override
            public void onCancel(Object arguments) {

            }
        });
        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "os_status").setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                application.osStream = events;
            }

            @Override
            public void onCancel(Object arguments) {

            }
        });
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "bluetooth")
                .setMethodCallHandler((call, result) -> {
                    if ("get_address".equals(call.method)) {
                        result.success(getBluetoothMacAddress());
                    }
                });
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "service")
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "check":
                            result.success(checkService());
                            break;
                        case "start":
                            bluetoothOn(result);
                            OneSignal.setSubscription(true);
                            break;
                        case "stop":
                            stopService(new Intent(this, BlueService.class));
                            Toast.makeText(this, "Layanan dihentikan", Toast.LENGTH_SHORT).show();
                            result.success(true);
                            OneSignal.setSubscription(false);
                            break;
                    }
                });
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "setting")
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "device_info":
                            Intent intent = new Intent(Settings.ACTION_DEVICE_INFO_SETTINGS);
                            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                            startActivity(intent);
                            result.success(true);
                            break;
                        case "setupOS":
                            SharedPreferences sharedPreferences = getSharedPreferences(FLUTTER_SHAREDPREF, MODE_PRIVATE);
                            String mac = sharedPreferences.getString("flutter.mac_address", "");
                            setTagOS(mac);
                            result.success(true);
                            break;
                    }
                });
    }

    @SuppressLint("HardwareIds")
    private String getBluetoothMacAddress() {
        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        String bluetoothMacAddress = null;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            try {
                Field mServiceField = bluetoothAdapter.getClass().getDeclaredField("mService");
                mServiceField.setAccessible(true);
                Object btManagerService = mServiceField.get(bluetoothAdapter);
                if (btManagerService != null) {
                    bluetoothMacAddress = (String) btManagerService.getClass().getMethod("getAddress").invoke(btManagerService);
                }
            } catch (NoSuchFieldException ignored) {
            } catch (NoSuchMethodException ignored) {
            } catch (IllegalAccessException ignored) {
            } catch (InvocationTargetException ignored) {
            }
        } else {
            bluetoothMacAddress = bluetoothAdapter.getAddress();
        }
        return bluetoothMacAddress;
    }

    private boolean checkService() {
        ActivityManager manager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        if (manager == null) return false;
        for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
            if (BlueService.class.getName().equals(service.service.getClassName())) {
                return true;
            }
        }
        return false;
    }

    private void bluetoothOn(MethodChannel.Result result) {
        if (!locationPermission()) return;
        SharedPreferences sharedPreferences = getSharedPreferences(FLUTTER_SHAREDPREF, MODE_PRIVATE);
        String mac = sharedPreferences.getString("flutter.mac_address", "");
        if (mac.length() > 0) {
            BluetoothAdapter blueAdapter = BluetoothAdapter.getDefaultAdapter();
            if (blueAdapter == null) {
                Toast.makeText(this, "Mohon aktifkan bluetooth", Toast.LENGTH_SHORT).show();
                result.success(false);
                return;
            }

            if (blueAdapter.isEnabled()) {
                result.success(true);
                startService(new Intent(this, BlueService.class));
                Toast.makeText(this, "Layanan dimulai, mohon untuk tetap waspada.", Toast.LENGTH_SHORT).show();
            } else {
                requestPermission();
                Toast.makeText(this, "Layanan gagal dimulai, untuk melanjutkan, pastikan kamu mengaktifkan Bluetooth.", Toast.LENGTH_SHORT).show();
                result.success(false);
            }
        } else {
            Toast.makeText(this, "Gagal mendapatkan MAC Address yang tersimpan", Toast.LENGTH_SHORT).show();
            result.success(false);
        }
    }

    private void setTagOS(String mac) {
        OneSignal.deleteTag("mac", new OneSignal.ChangeTagsUpdateHandler() {
            @Override
            public void onSuccess(JSONObject tags) {
                OneSignal.sendTag("mac", mac);
            }

            @Override
            public void onFailure(OneSignal.SendTagsError error) {

            }
        });
    }

    private void requestPermission() {
       if (!locationPermission()) return;
        Intent enableBluetoothIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
        startActivityForResult(enableBluetoothIntent, REQUEST_PERMISSION);
    }

    private boolean locationPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {  // Only ask for these permissions on runtime when running Android 6.0 or higher
            if (ContextCompat.checkSelfPermission(getBaseContext(), Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_DENIED) {
                new AlertDialog.Builder(this)
                        .setTitle("Akses Lokasi Dibutuhkan")
                        .setMessage("Untuk mendeteksi perangkat disekitar, Aplikasi membutuhkan akses lokasi")
                        .setOnCancelListener(dialog -> {
                            if (ContextCompat.checkSelfPermission(getBaseContext(), Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                                ActivityCompat.requestPermissions(MainActivity.this,
                                        new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                                        REQUEST_PERMISSION);
                            }
                        })
                        .setPositiveButton("Mengerti", (dialog, which) -> {
                            if (ContextCompat.checkSelfPermission(getBaseContext(), Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                                ActivityCompat.requestPermissions(MainActivity.this,
                                        new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                                        REQUEST_PERMISSION);
                            }
                        }).setNegativeButton("Keluar", (dialog, which) -> {
                            finish();
                        })
                        .show();
                return false;
            }
        }
        return true;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == REQUEST_PERMISSION) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
                requestPermission();
            }
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_PERMISSION && resultCode == RESPONSE_REQUEST_PERMISSION) {
            Toast.makeText(this, "Bluetooth dibutuhkan untuk memindai perangkat diarea sekitar.", Toast.LENGTH_SHORT).show();
        }
        super.onActivityResult(requestCode, resultCode, data);
    }
}
