import 'package:flutter/material.dart';
import 'package:jagajarak/gui/components/CustomDivider.dart';

class StatusScreen extends StatefulWidget {
  final String status;

  const StatusScreen({Key key, this.status}) : super(key: key);
  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  @override
  Widget build(BuildContext context) {
    String health = (widget.status ?? "healthy").toLowerCase();
    Color bgHealthColor = Colors.grey;
    String peringatan = "Pengguna yang anda pindai berstatus " + health;
    String imageAssets = "assets/images/illustration/healthy.png";
    switch (health) {
      case "healthy":
        health = "Sehat";
        bgHealthColor = Theme.of(context).primaryColor;
        imageAssets = "assets/images/illustration/healthy.png";
        break;
      case "sehat":
        health = "Sehat";
        bgHealthColor = Theme.of(context).primaryColor;
        peringatan = "Pengguna yang anda pindah berstatus sehat!";
        imageAssets = "assets/images/illustration/healthy.png";
        break;
      case "odp":
        health = "Orang Dalam Pengawasan";
        bgHealthColor = Theme.of(context).accentColor;
        peringatan = "Pengguna yang anda pindai berstatus ODP, mohon himbau untuk mengenakan masker dan menjaga jarak!";
        imageAssets = "assets/images/illustration/odp.png";
        break;
      case "pdp":
        health = "Pasien Dalam Perawatan";
        bgHealthColor = Colors.red;
        peringatan = "Pengguna yang anda pindai berstatus PDP, mohon dihimbau untuk kembali dan tidak melanjutkan aktifitas diluar rumah!";
        imageAssets = "assets/images/illustration/pdp.png";
        break;
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 10,
              left: 10,
              child: CloseButton(),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Image.asset(
                      imageAssets,
                      height: 200,
                    ),
                    Text(
                      health,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ColumnDivider(
                      space: 5,
                    ),
                    Text(
                      peringatan,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
