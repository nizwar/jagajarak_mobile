import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jagajarak/gui/screen/loginScreen.dart';
import 'package:provider/provider.dart';
import 'package:jagajarak/core/provider/DeviceProvider.dart';
import 'package:jagajarak/core/res/warna.dart';
import 'package:jagajarak/core/utils/services.dart';
import 'core/provider/UserProvider.dart';
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
        Provider(create: (context) => DeviceProvider()),
        Provider(create: (context) => UserProvider()),
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

  StreamController _osStream = StreamController();

  @override
  void didChangeDependencies() {
    _initEverything();
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
      return Consumer<UserProvider>(
        builder: (context, value, child) {
          if (value.isLogedIn ?? false) {
            if (_ready) {
              return MainScreen();
            } else {
              return InputMacScreen(
                rootState: this,
              );
            }
          } else {
            return LoginScreen(
              state: this,
            );
          }
        },
      );
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
    var deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    await Future.delayed(Duration(seconds: 2));

    Preferences preferences = await Preferences.init(context);
    if (preferences.getToken() != null) {
      await userProvider.initUser(context);
      String kondisi = await preferences.getKondisi();
      if (kondisi != null) { 
        await preferences.deleteKondisi();
      }
    }

    await deviceProvider.init(context);
    if ((deviceProvider.mac != null) && (deviceProvider.startServiceOnStart ?? false)) {
      await Services(context).startService();
    }

    await _initStream();

    setState(() {
      _ready = deviceProvider.mac != null;
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

  Future _initStream() async {
    Preferences preferences = await Preferences.init(context);
    _osStream.stream.listen((event) {
      showAlert(event);
      preferences.deleteKondisi();
    });
    _osStream.addStream(EventChannel("os_status").receiveBroadcastStream());
  }
}
