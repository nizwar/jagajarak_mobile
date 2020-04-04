import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

class Bluetooth {
  final BuildContext context;
  final MethodChannel _channel = MethodChannel("bluetooth");

  Bluetooth(this.context);

  Future<String> getMacAddress() async {
    var resp = await _channel.invokeMethod("get_address"); 
    return resp;
  } 
}
