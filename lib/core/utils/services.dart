import 'package:flutter/services.dart';

class Services {
//  final BuildContext context;
  static MethodChannel _channel = MethodChannel("service");
  static EventChannel _streamChannel = EventChannel("service_stream");
  static EventChannel _streamOsStatus = EventChannel("os_status");
  static EventChannel _streamLocSignal = EventChannel("locsignal_stream");

//  Services(this.context);

  static Stream<String> streamServiceStatus() {
    //Stream layanan aplikasi, apakah ON atau OFF
    return _streamChannel.receiveBroadcastStream().cast<String>();
  }

  static Stream streamLocSignal() {
    //Stream untuk mendapatkan sinyal kapan mengambil informasi lokasi terbaru
    return _streamLocSignal.receiveBroadcastStream();
  }

  static Stream<String> streamOsStatus() {
    //Stream Notifikasi Onesignal
    return _streamOsStatus.receiveBroadcastStream().cast<String>();
  }

  static Future<bool> startService() async {
    var resp = await _channel.invokeMethod("start");
    return resp;
  }

  static Future<bool> checkService() async {
    var resp = await _channel.invokeMethod("check");
    return resp;
  }

  static Future<bool> stopService() async {
    var resp = await _channel.invokeMethod("stop");
    return resp;
  }

  static Future<bool> showToast(String message) async {
    var resp = await _channel.invokeMethod("toast", message);
    return resp;
  }
}
