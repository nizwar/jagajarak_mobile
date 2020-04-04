import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

class Services {
  final BuildContext context;
  final MethodChannel _channel = MethodChannel("service");
  final EventChannel _streamChannel = EventChannel("service_stream");

  Services(this.context);

  Stream<String> streamServiceStatus(){
    return _streamChannel.receiveBroadcastStream().cast<String>();
  }

  Future<bool> startService() async {
    var resp = await _channel.invokeMethod("start"); 
    return resp;
  }

  Future<bool> checkService() async {
    var resp = await _channel.invokeMethod("check"); 
    return resp;
  }

  Future<bool> stopService() async {
    var resp = await _channel.invokeMethod("stop"); 
    return resp;
  }
}
