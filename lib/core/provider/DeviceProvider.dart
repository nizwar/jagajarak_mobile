import 'package:flutter/material.dart';
import 'package:jagajarak/core/utils/preferences.dart';
import 'package:jagajarak/core/utils/systemSettings.dart';

class DeviceProvider extends ChangeNotifier {
  String mac;
  String health;
  String userName;
  // bool service = false;
  bool startServiceOnStart = false;

  DeviceProvider({this.mac, this.health, this.userName});

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
