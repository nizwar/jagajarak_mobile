import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jagajarak/core/models/location.dart';
import 'package:jagajarak/core/models/model.dart';

class User extends Model {
  String nohp;
  String status;
  String token;
  LocationData lastLocation;
  DocumentReference reference;

  User({this.nohp, this.status, this.lastLocation, @required this.token}) {
    reference = Firestore.instance.collection("pengguna").document(token);
  }

  @override
  Map<String, dynamic> toJson() => {
        "nohp": nohp,
        "status": nohp,
        "token": token,
        "last_location": lastLocation,
      };
}
