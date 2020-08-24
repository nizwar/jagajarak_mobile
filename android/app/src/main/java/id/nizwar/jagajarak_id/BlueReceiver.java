package id.nizwar.jagajarak_id;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
import android.widget.Toast;

import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;


import static android.content.ContentValues.TAG;

public class BlueReceiver extends BroadcastReceiver {
    static final String FLUTTER_SHAREDPREF = "FlutterSharedPreferences";
    ArrayList<String> coveredDevices = new ArrayList<>();
    ArrayList<String> pingedDevices = new ArrayList<>();

    final Application application;

    boolean requestFinished = true;

    public BlueReceiver(Application application) {
        this.application = application;
    }


    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        assert action != null;
        SharedPreferences sharedPreferences = context.getSharedPreferences(FLUTTER_SHAREDPREF, Context.MODE_PRIVATE);
        switch (action) {
            case BluetoothDevice.ACTION_FOUND:
                BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);
                assert device != null;
                if (pingedDevices.contains(device.getAddress())) return;
                if (!coveredDevices.contains(device.getAddress()))
                    coveredDevices.add(device.getAddress());
                break;
            case BluetoothAdapter.ACTION_DISCOVERY_FINISHED:
                if (!requestFinished) return;
                String health = sharedPreferences.getString("flutter.health", "healthy");
                switch (health.toLowerCase()) {
                    case "odp":
                        sendNotif(context, "Perhatian", "Orang Dalam Pantauan (ODP) terdeteksi berada disekitarmu, Demi kemanan, segeralah menjauh dari area ini atau jaga jarak anda dengan siapapun.", health);
                        break;
                    case "pdp":
                        sendNotif(context, "Bahaya!", "Pasien Dalam Perawatan (PDP) terdeteksi berada disekitarmu, Demi kemanan, segeralah menjauh dari area ini.", health);
                        break;
                    case "healthy":
                        break;
                    default:
                        coveredDevices.clear();
                }
                Log.d(TAG, "Discovery Finished");
                break;
            case BluetoothAdapter.ACTION_STATE_CHANGED:
                if (!BluetoothAdapter.getDefaultAdapter().isEnabled()) {
                    Toast.makeText(context, "Bluetooth mati, layanan dihentikan", Toast.LENGTH_SHORT).show();
                    context.stopService(new Intent(context, BlueService.class));
                    if (application != null)
                        if (application.serviceStream != null)
                            application.serviceStream.success("stop");
                }
                Log.d(TAG, "State Changed");
                break;
        }
    }

    public void sendNotif(final Context context, String title, String message, String kondisi) {
        if (coveredDevices.size() == 0) return;
        try {
            JSONObject jsonObject = new JSONObject();
            JSONArray allDevices = new JSONArray();
            for (int i = 0; i < coveredDevices.size(); i++) {
                allDevices.put(new JSONObject().put("field", "tag").put("key", "mac").put("relation", "=").put("value", coveredDevices.get(i)));
                if (coveredDevices.size() > 1 && i < coveredDevices.size() - 1)
                    allDevices.put(new JSONObject().put("operator", "OR"));
            }
            jsonObject.put("app_id", BuildConfig.OS_APPID);
            jsonObject.put("filters", allDevices);
            jsonObject.put("headings", new JSONObject().put("en", title));
            jsonObject.put("contents", new JSONObject().put("en", message));
            jsonObject.put("data", new JSONObject().put("kondisi", kondisi));

            requestFinished = false;
            Volley.newRequestQueue(context).add(new JsonObjectRequest("https://onesignal.com/api/v1/notifications", jsonObject, response -> {
                Log.d(TAG, response.toString());
                pingedDevices.addAll(coveredDevices);
                coveredDevices.clear();
                requestFinished = true;
            }, error -> {
                Log.d(TAG, new String(error.networkResponse.data));
            }) {
                @Override
                public Map<String, String> getHeaders() {
                    Map<String, String> header = new HashMap<>();
                    header.put("Authorization", "Basic " + BuildConfig.OS_SECRET);
                    return header;
                }
            });

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

}
