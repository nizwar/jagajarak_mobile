import 'package:flutter/material.dart';
import 'package:jagajarak/core/utils/mainUtils.dart';
import 'package:jagajarak/gui/screen/informasiScreen.dart';
import 'package:jagajarak/gui/screen/page/berandaPage.dart';
import 'package:jagajarak/gui/screen/page/pengaturanPage.dart';
import 'package:jagajarak/gui/screen/qrScannerScreen.dart';
import 'package:line_icons/line_icons.dart';
import 'package:ndialog/ndialog.dart';

import 'myQrScreen.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _curIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<BottomNav> _listBottomNav = [
      BottomNav(
        bottomNavItem: BottomNavigationBarItem(icon: Icon(LineIcons.home), title: Text("Beranda")),
        page: BerandaPage(),
      ),
      BottomNav(
        bottomNavItem: BottomNavigationBarItem(icon: Icon(LineIcons.gear), title: Text("Pengaturan")),
        page: PengaturanPage(),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Jaga Jarak",
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: "Pemindaian",
            icon: Icon(
              LineIcons.qrcode,
              color: Colors.white,
            ),
            onPressed: () {
              NAlertDialog(
                title: Text("Pilih Aksi"),
                dialogStyle: DialogStyle(
                  titleDivider: true,
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatButton(
                        onPressed: () {
                          startScreen(context, QRScannerScreen());
                        },
                        child: Text("Pindai kode QR")),
                    FlatButton(
                        onPressed: () {
                          startScreen(context, MyQRScreen());
                        },
                        child: Text("Kode QR saya")),
                  ],
                ),
              ).show(context);
            },
          ),
          IconButton(
            tooltip: "Informasi Jaga Jarak",
            icon: Icon(
              LineIcons.question_circle,
              color: Colors.white,
            ),
            onPressed: () {
              startScreen(context, InformasiScreen());
            },
          ),
        ],
        elevation: 0,
      ),
      body: _listBottomNav[_curIndex].page,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        items: _listBottomNav.map((item) => item.bottomNavItem).toList(),
        currentIndex: _curIndex,
        backgroundColor: Colors.transparent,
        onTap: (index) => setState(() {
          _curIndex = index;
        }),
      ),
    );
  }
}

class BottomNav {
  final Widget page;
  final BottomNavigationBarItem bottomNavItem;

  BottomNav({@required this.page, @required this.bottomNavItem});
}
