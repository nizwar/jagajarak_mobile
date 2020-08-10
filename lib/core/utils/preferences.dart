import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jagajarak/core/provider/UserProvider.dart';
import 'package:jagajarak/core/utils/systemSettings.dart';
import 'package:provider/provider.dart';
import 'package:jagajarak/core/provider/DeviceProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final BuildContext context;
  final SharedPreferences shared;

  DeviceProvider _deviceProvider;
  UserProvider _userProvider;

  Preferences(this.context, this.shared) {
    _deviceProvider = Provider.of(context, listen: false);
    _userProvider = Provider.of(context, listen: false);
  }

  Future saveToken(String token) async {
    _userProvider.getUser.token = token;
    await shared.setString("token", token);
  }

  Future saveMacBluetooth(String mac) async {
    _deviceProvider.setMac(mac);
    await shared.setString("mac_address", mac);
    await SystemSettings().setupOS();
  }

  Future saveHealthStatus(String status) async {
    _deviceProvider.setHealth(status);
    await shared.setString("health", status);
  }

  Future saveUserName(String username) async {
    _deviceProvider.setUsername(username);
    await shared.setString("username", username);
  }

  Future saveServiceOnStart(bool value) async {
    _deviceProvider.startServiceOnStart = value;
    await shared.setBool("service_on_start", value);
  }

  Future deleteKondisi() async {
    await shared.remove("kondisi");
  }

  Future clear() async {
    await shared.clear();
    _deviceProvider.init(context);
  }

  String getMacBluetooth() => shared.getString("mac_address");
  String getHealth() => shared.getString("health");
  String getUserName() => shared.getString("username");
  Future<String> getKondisi() async {
    var resp = await Firestore.instance.collection("pengguna").document(_userProvider.getUser.token).get();
    return resp.data["status"] ?? "healthy";
  }

  String getToken() => shared.getString("token");
  bool getServiceOnStart() => shared.getBool("service_on_start") ?? false;

  static Future<Preferences> init(BuildContext context) async {
    return Preferences(context, await SharedPreferences.getInstance());
  }
}
