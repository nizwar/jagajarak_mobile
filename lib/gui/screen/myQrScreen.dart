import 'package:flutter/material.dart';
import 'package:jagajarak/core/provider/UserProvider.dart';
import 'package:jagajarak/gui/components/CustomDivider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQRScreen extends StatefulWidget {
  @override
  _MyQRScreenState createState() => _MyQRScreenState();
}

class _MyQRScreenState extends State<MyQRScreen> {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of(context);
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            alignment: Alignment.center, 
            children: <Widget>[
              Positioned(
                child: CloseButton(),
                top: 20,
                left: 20,
              ),
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                top: 0,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView(
                      shrinkWrap: true,
                      physics: BouncingScrollPhysics(),
                      children: <Widget>[
                        Center(
                          child: QrImage(
                            data: userProvider.getUser.token,
                            size: 200,
                          ),
                        ),
                        ColumnDivider(),
                        Text(
                          "QR Code",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        ColumnDivider(
                          space: 5,
                        ),
                        Text(
                          "Tunjukan Kode QRmu kepada petugas atau pihak yang memiliki hak atau kepentingan untuk melakukannya!",
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
