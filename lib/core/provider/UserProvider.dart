import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jagajarak/core/models/user.dart';
import 'package:jagajarak/core/utils/preferences.dart';

class UserProvider extends ChangeNotifier {
  User _user;
  bool _logedin;

  bool get isLogedIn => _logedin;

  User get getUser => _user;

  UserProvider();
  void setUser(BuildContext context, User user) async {
    _user = user;

    Preferences resp = await Preferences.init(context);
    resp.saveToken(user.token);
    _logedin = true;

    notifyListeners();
  }

  Future<User> initUser(BuildContext context) async {
    Preferences resp = await Preferences.init(context);
    var getUserDetail = await Firestore.instance.collection("pengguna").document(resp.getToken()).get();

    User user = User(
      nohp: getUserDetail.data["nohp"],
      status: getUserDetail.data["status"],
      token: resp.getToken(),
    );

    _user = user;
    _logedin = true;

    notifyListeners();
    return user;
  }
}
