import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jagajarak/core/utils/mainUtils.dart';
import 'package:jagajarak/core/utils/preferences.dart';
import 'package:jagajarak/gui/screen/alertScreen.dart';
import 'package:provider/provider.dart';
import 'package:jagajarak/core/provider/DeviceProvider.dart';
import 'package:jagajarak/core/res/warna.dart';
import 'package:jagajarak/core/utils/services.dart';

import 'gui/screen/inputMacScreen.dart';
import 'gui/screen/mainScreen.dart';

main() {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    Provider(
      create: (context) => DeviceProvider(),
      child: MaterialApp(
        title: "Jaga Jarak",
        debugShowCheckedModeBanner: false,
        home: Root(),
        theme: ThemeData(
          appBarTheme: AppBarTheme(textTheme: Typography.whiteCupertino),
          primaryColor: primaryColor,
          accentColor: accentColor,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.light(secondary: secondaryColor, surface: Colors.grey.shade100),
          backgroundColor: Colors.white,
        ),
      ),
    ),
  );
}

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  bool _initialized = false;
  bool _ready = false;
  StreamController _osStream = StreamController();

  @override
  void didChangeDependencies() {
    _initEverything();
    _osStream.addStream(EventChannel("os_status").receiveBroadcastStream());
    Preferences.init(context).then((value) {
      String kondisi = value.shared.getString("kondisi");
      if (kondisi != null) {
        _showAlert(kondisi);
        value.shared.remove("kondisi");
      }
    });
    _osStream.stream.listen((event) {
      Preferences.init(context).then((value) {
        String kondisi = value.shared.getString("kondisi");
        if (kondisi != null) {
          value.shared.remove("kondisi");
        }
      });
      _showAlert(event);
    });

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _osStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = _splashWidget();
    if (_initialized) {
      if (_ready) {
        body = MainScreen();
      } else {
        body = InputMacScreen();
      }
    }
    return body;
  }

  Widget _splashWidget() {
    return Scaffold(
      body: Center(
          child: Image.asset(
        "assets/images/logo.png",
        height: 100,
        color: primaryColor,
      )),
    );
  }

  Future _initEverything() async {
    var provider = Provider.of<DeviceProvider>(context, listen: false);
    await Future.delayed(Duration(seconds: 2));

    await provider.init(context);
    if ((provider.mac != null) && (provider.startServiceOnStart ?? false)) {
      await Services(context).startService();
    }
    setState(() {
      _ready = provider.mac != null;
      _initialized = true;
    });
  }

  void _showAlert(String kondisi) {
    switch (kondisi.toLowerCase()) {
      case "odp":
        startScreen(
            context,
            AlertScreen(
              title: "Orang Dalam Pengawasan (ODP) Ditemukan!",
              subtitle: "Perhatian!, Orang Dalam Pengawasan (ODP) terdeteksi berada disekitarmu, Segera tinggalkan area atau tetap menjaga jarak aman dengan siapapun!",
            ));
        break;
      case "pdp":
        startScreen(
            context,
            AlertScreen(
              title: "Pasien Dalam Perawatan (PDP) Ditemukan!",
              subtitle: "Perhatian!, Pasien dalam perawatan (PDP) terdeteksi berada disekitarmu, Bersegeralah untuk meninggalkan Area!",
            ));
        break;
    }
  }
}
