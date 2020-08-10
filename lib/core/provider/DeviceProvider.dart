import 'package:flutter/material.dart';
import 'package:jagajarak/core/utils/preferences.dart';
import 'package:jagajarak/core/utils/systemSettings.dart';

class DeviceProvider extends ChangeNotifier {
  String mac;
  String health;
  String userName;
  // bool service = false;
  bool startServiceOnStart = false;

  String get getMac => mac;
  String get getHealth => health;
  String get getUserName => userName;

  DeviceProvider({this.mac, this.health, this.userName});

  void setMac(String value) {
    this.mac = value;
    notifyListeners();
  }

  void setHealth(String value) {
    this.health = value;
    notifyListeners();
  }

  void setUsername(String value) {
    this.userName = value;
    notifyListeners();
  }

  Future<DeviceProvider> init(BuildContext context) async {
    Preferences preferences = await Preferences.init(context);
    health = preferences.getHealth() ?? "healthy";
    mac = preferences.getMacBluetooth();
    userName = preferences.getUserName();
    startServiceOnStart = preferences.getServiceOnStart();

    if (mac != null) SystemSettings().setupOS();

    notifyListeners();
    return DeviceProvider(mac: mac, health: health, userName: userName);
  }
}
