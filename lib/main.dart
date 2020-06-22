import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:jagajarak/core/provider/DeviceProvider.dart';
import 'package:jagajarak/core/res/warna.dart';
import 'package:jagajarak/core/utils/services.dart';
import 'core/provider/ServiceProvider.dart';
import 'core/utils/mainUtils.dart';
import 'core/utils/preferences.dart';
import 'gui/screen/alertScreen.dart';
import 'gui/screen/inputMacScreen.dart';
import 'gui/screen/mainScreen.dart';

main() {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (context) => DeviceProvider(),
        ),
        Provider(
          create: (context) => ServiceProvider(),
        ),
      ],
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
  RootState createState() => RootState();
}

class RootState extends State<Root> {
  bool _initialized = false;
  bool _ready = false;


  @override
  void didChangeDependencies() {
    _initEverything();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = _splashWidget();
    if (_initialized) {
      if (_ready) {
        body = MainScreen();
      } else {
        body = InputMacScreen(
          rootState: this,
        );
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

  void setReady(bool value) {
    setState(() {
      _initialized = true;
      _ready = value;
    });
  }

  Future _initEverything() async {
    var provider = Provider.of<DeviceProvider>(context, listen: false);
    //Kondisi
    Preferences preferences = await Preferences.init(context);
    String kondisi = preferences.getKondisi();
    if (kondisi != null) {
      showAlert(kondisi);
      await preferences.deleteKondisi();
    }

    await provider.init(context);
    if ((provider.mac != null) && (provider.startServiceOnStart ?? false)) {
      await Services.startService();
    }

    _initStream();

    setState(() {
      _ready = provider.mac != null;
      _initialized = true;
    });
  }

  void showAlert(String kondisi) {
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

  Future _initStream() {
    ServiceProvider serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    serviceProvider.oneSignalService().listen(_oneSignalCallback);
    serviceProvider.locationService().listen(_locSignalCallback);
  }

  void _oneSignalCallback(signal) async {
    Preferences preferences = await Preferences.init(context);
    showAlert(signal);
    preferences.deleteKondisi();
  }

  void _locSignalCallback(signal) async {
    Preferences preferences = await Preferences.init(context);
    try {
      if (signal != null) {
        if (signal == 1) {
          Geolocator geoLoc = Geolocator();
          if (!(await geoLoc.isLocationServiceEnabled())) {
            Services.stopService();
            Services.showToast("Tidak bisa melanjutkan layanan sebab Layanan lokasi dimatikan");
          }

          var lastLoc = preferences.getMyLastLocation();
          var nowLoc = await geoLoc.getCurrentPosition();
          var distance = await geoLoc.distanceBetween(nowLoc.latitude, nowLoc.longitude, lastLoc.latitude, lastLoc.longitude);

          if (distance > 5.6) {
            preferences.saveMyLastLocation(nowLoc.latitude, nowLoc.longitude);
            Services.showToast("5 Meter tercapai, Disini upload lokasi baru");
            //Todo: Tambahkan fungsi upload lokasi disini
          }
        }
      }
    } catch (e) {}
  }
}
