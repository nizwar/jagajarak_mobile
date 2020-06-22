import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jagajarak/core/utils/services.dart';

class ServiceProvider extends ChangeNotifier{
  Stream oneSignalService() => Services.streamOsStatus();
  Stream locationService() => Services.streamLocSignal();
  Stream service() => Services.streamServiceStatus();


  ServiceProvider();

}