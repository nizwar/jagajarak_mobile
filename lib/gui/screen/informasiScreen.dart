import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:jagajarak/core/res/string.dart';
import 'package:jagajarak/core/utils/services.dart';
import 'package:jagajarak/gui/components/CustomDivider.dart';

class InformasiScreen extends StatefulWidget {
  @override
  _InformasiScreenState createState() => _InformasiScreenState();
}

class _InformasiScreenState extends State<InformasiScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _last = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width - 60,
        height: 40,
        margin: EdgeInsets.only(bottom: 20),
        child: FlatButton(
          color: Theme.of(context).primaryColor,
          child: Text(
            _last ? "Tutup" : "Lanjutkan",
            style: TextStyle(color: Colors.white),
          ),
          shape: StadiumBorder(),
          onPressed: () {
            if (_last)
              Navigator.pop(context);
            else
              _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            PageView(
              controller: _pageController,
              onPageChanged: (i) {
                if (i < 4)
                  setState(() {
                    _last = false;
                  });
                else
                  setState(() {
                    _last = true;
                  });
              },
              children: <Widget>[
                _page(
                  "assets/images/illustration/1.png",
                  "Cara Menggunakan!",
                  informasi1,
                  StreamBuilder(
                    stream: Services(context).streamServiceStatus(),
                    initialData: "stop",
                    builder: (context, snapshot) {
                      return FlatButton(
                        shape: StadiumBorder(),
                        disabledColor: Colors.grey,
                        child: Text(
                          "Mulai Layanan Sekarang!",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: (snapshot.data ?? "stop") == "stop" ? Theme.of(context).primaryColor : Colors.grey.shade400,
                        onPressed: (snapshot.data ?? "stop")== "stop"
                            ? () async {
                                await Services(context).startService();
                                setState(() {});
                              }
                            : null,
                      );
                    },
                  ),
                ),
                _page("assets/images/illustration/2.png", "Dapatkan Notifikasi", informasi2, null),
                _page("assets/images/illustration/3.png", "Tenang Saja", informasi3, null),
                _page("assets/images/illustration/4.png", "Privasi Untuk Kamu", informasi4, null),
                _page(
                    "assets/images/illustration/5.png",
                    "Ayo Bagikan!",
                    informasi5,
                    FlatButton(
                      color: Theme.of(context).primaryColor,
                      shape: StadiumBorder(),
                      child: Text(
                        "Bagikan Sekarang!",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        FlutterShare.share(
                          title: "Jaga Jarak",
                          text: "Yuk! gunakan aplikasi Jaga Jarak untuk mendapatkan notifikasi ODP atau PDP yang ada disekitarmu!",
                          linkUrl: "https://github.com/nizwar/jagajarak",
                          chooserTitle: "Bagikan Jaga Jarak melalui",
                        );
                      },
                    ))
              ],
            ),
            Positioned(
              child: CloseButton(),
              top: 10,
              left: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _page(String assets, String title, String message, Widget button) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(top: 20, left: 20, bottom: 80, right: 20),
        children: <Widget>[
          Image.asset(
            assets,
            height: 200,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            textAlign: TextAlign.center,
          ),
          Divider(),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          ColumnDivider(),
          button != null ? Center(child: button) : Container()
        ],
      ),
    );
  }
}
