import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:jagajarak/core/provider/UserProvider.dart';
import 'package:jagajarak/core/res/warna.dart';
import 'package:jagajarak/core/utils/mainUtils.dart';
import 'package:jagajarak/gui/screen/statusScreen.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _qrState = false;
  @override
  Widget build(BuildContext context) {
    print("Test");
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: QRBarScannerCamera(
                    qrCodeCallback: (value) async {
                      if (!_qrState) {
                        // log(value);
                        setState(() {
                          _qrState = true;
                        });
                        try {
                          DocumentSnapshot resp = await ProgressDialog.future<DocumentSnapshot>(
                            context,
                            future: Firestore.instance.collection("pengguna").document(value).get(),
                            title: Text("Memuat informasi"),
                            message: Text("Tunggu sebentar..."),
                          );

                          if (!resp.exists) {
                            await showMessage(context, title: "Pengguna tidak ditemukan", message: "Sepertinya kamu memindai kode qr yang tidak valid");
                          } else {
                            await startScreen(
                                context,
                                StatusScreen(
                                  status: resp.data["status"],
                                ));
                          }
                        } catch (e) {
                          await showMessage(context, title: "Pengguna tidak ditemukan", message: "Sepertinya kamu memindai kode qr yang tidak valid");
                        }
                        setState(() {
                          _qrState = false;
                        });
                      }
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  color: primaryColor,
                  child: Text(
                    "Silahkan pindai kode qr pengguna lain untuk melihat status kondisinya, jangan lupa untuk menggunakan masker dan selalu tetap jaga jarak!",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: CloseButton(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
