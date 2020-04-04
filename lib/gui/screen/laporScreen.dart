import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:jagajarak/core/provider/DeviceProvider.dart';
import 'package:jagajarak/core/res/string.dart';
import 'package:jagajarak/core/res/warna.dart';
import 'package:jagajarak/core/utils/mainUtils.dart';
import 'package:jagajarak/core/utils/preferences.dart';
import 'package:jagajarak/gui/components/CustomDivider.dart';

class LaporScreen extends StatefulWidget {
  @override
  _LaporScreenState createState() => _LaporScreenState();
}

class _LaporScreenState extends State<LaporScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  Color buttonColor = primaryColor;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  switch (page) {
                    case 1:
                      buttonColor = Theme.of(context).accentColor;
                      break;
                    case 2:
                      buttonColor = Colors.red;
                      break;
                    default:
                      buttonColor = Theme.of(context).primaryColor;
                      break;
                  }
                  _page = page;
                });
              },
              children: <Widget>[
                _template(
                  "assets/images/illustration/healthy.png",
                  "Sehat",
                  "Saya menyatakan bahwa saya berada dikondisi Sehat dan tidak mengalami gejala apapun.",
                  Theme.of(context).primaryColor,
                ),
                _template(
                  "assets/images/illustration/odp.png",
                  "Orang Dalam Pengawasan",
                  "Saya menyatakan bahwa saya berada dikondisi Orang Dalam Pengawasan (ODP) Covid19.",
                  Theme.of(context).accentColor,
                ),
                _template(
                  "assets/images/illustration/pdp.png",
                  "Pasien Dalam Perawatan",
                  "Saya menyatakan bahwa saya berada dikondisi Pasien Dalam Perawatan (PDP) Covid19.",
                  Colors.red,
                ),
              ],
            ),
            Positioned(
              left: 10,
              top: 10,
              child: CloseButton(),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 20),
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                color: buttonColor,
                shape: StadiumBorder(),
                child: Icon(
                  Icons.navigate_before,
                  color: Colors.white,
                ),
                onPressed: () {
                  _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
            ),
            RowDivider(
              space: 20,
            ),
            FlatButton(
              color: buttonColor,
              shape: StadiumBorder(),
              child: Text("TERAPKAN", style: TextStyle(color: Colors.white)),
              onPressed: saveHealth,
            ),
            RowDivider(
              space: 20,
            ),
            Expanded(
              child: FlatButton(
                color: buttonColor,
                shape: StadiumBorder(),
                child: Icon(
                  Icons.navigate_next,
                  color: Colors.white,
                ),
                onPressed: () {
                  _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _template(String assets, String title, String subtitle, Color titleColor) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 100),
        children: <Widget>[
          Image.asset(
            assets,
            height: 200,
          ),
          ColumnDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: titleColor),
                  textAlign: TextAlign.center,
                ),
                ColumnDivider(
                  space: 3,
                ),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future saveHealth() async {
    DeviceProvider provider = Provider.of(context, listen: false);
    if (provider.mac == null) {
      await showMessage(context, title: perhatian, message: "Sepertinya terjadi kesalahan");
    }
    String status = "healthy";
    var konfir = await showMessage(
      context,
      title: "Perhatian",
      message: "Pastikan kamu mengisi dengan jujur, Yakin menerapkan kondisi?",
      actions: [
        FlatButton(
          child: Text("Yakin"),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        FlatButton(
          child: Text("Tidak Yakin"),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ],
    );
    if (!(konfir ?? false)) return;
    switch (_page) {
      case 0:
        status = "healthy";
        await showMessage(context, title: "Kamu Sehat!", message: healthMsg);
        break;
      case 1:
        status = "odp";
        await showMessage(context, title: perhatian, message: odpMsg);
        break;
      case 2:
        status = "pdp";
        await showMessage(context, title: perhatian, message: pdpMsg);
        break;
      default:
        status = "healthy";
    }

    Preferences pref = await Preferences.init(context);
    await ProgressDialog.future(
      context,
      title: Text("Mengunggah Informasi"),
      message: Text("Tunggu sejenak..."),
      future: pref.saveHealthStatus(status),
    );

    await showMessage(this.context, message: "Kondisi mu berhasil diperbarui", title: "Perhatian");
    await (await Preferences.init(context)).saveHealthStatus(status);
    Navigator.pop(context);
  }
}
