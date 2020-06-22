import 'package:flutter/material.dart';
import 'package:jagajarak/core/utils/mainUtils.dart';
import 'package:jagajarak/gui/screen/informasiScreen.dart';
import 'package:jagajarak/gui/screen/page/berandaPage.dart';
import 'package:jagajarak/gui/screen/page/pengaturanPage.dart';
import 'package:jagajarak/gui/screen/page/riwayatPage.dart';
import 'package:line_icons/line_icons.dart';

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
        bottomNavItem: BottomNavigationBarItem(icon: SizedBox(height: 40, child: CircleAvatar(child: Icon(LineIcons.qrcode))), title: Container()),
        page: BerandaPage(),
      ),
      BottomNav(
        bottomNavItem: BottomNavigationBarItem(icon: Icon(LineIcons.users), title: Text("Catatan")),
        page: RiwayatPage(),
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
            tooltip: "Informasi Jaga Jarak",
            onPressed: () {
              startScreen(context, InformasiScreen());
            },
            icon: Icon(
              LineIcons.question_circle,
              color: Colors.white,
            ),
          ),
        ],
        elevation: 0,
      ),
      body: _listBottomNav[_curIndex].page,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        items: _listBottomNav.map((item) => item.bottomNavItem).toList(),
        currentIndex: _curIndex,
        backgroundColor: Colors.white,
        onTap: (index) => setState(() {
          if (index == 1) {
            return;
          }
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
