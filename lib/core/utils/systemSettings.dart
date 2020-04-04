import 'package:flutter/services.dart';

class SystemSettings {
  MethodChannel _channel = const MethodChannel("setting");

  Future<void> openDeviceInfo() async {
    await _channel.invokeMethod("device_info");
  }
  Future<void> setupOS() async {
    await _channel.invokeMethod("setupOS");
  }
}
