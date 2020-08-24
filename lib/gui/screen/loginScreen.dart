import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jagajarak/core/models/user.dart';
import 'package:jagajarak/core/provider/UserProvider.dart';
import 'package:jagajarak/core/res/warna.dart';
import 'package:jagajarak/gui/components/CustomDivider.dart';
import 'package:jagajarak/main.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class LoginScreen extends StatefulWidget {
  final RootState state;

  const LoginScreen({Key key, @required this.state}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseAuth _firebaseAuth;
  UserProvider _userProvider;
  final TextEditingController _hpText = TextEditingController();

  @override
  void initState() {
    _firebaseAuth = FirebaseAuth.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_userProvider == null) _userProvider = Provider.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(10),
            shrinkWrap: true,
            children: <Widget>[
              Image.asset(
                "assets/images/illustration/phone_number.png",
                height: 150,
              ),
              ColumnDivider(),
              Text(
                "Nomor HP Dibutuhkan!",
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
                "Masukan nomor HP mu untuk terhubung dengan informasi pengecekan COVID19",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              ColumnDivider(
                space: 20,
              ),
              Center(
                child: SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _hpText,
                    textAlign: TextAlign.center,
                    maxLength: 15,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade300,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      counter: Container(),
                      hintText: "Nomor Handphone...",
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    onSubmitted: _loginHP,
                  ),
                ),
              ),
              ColumnDivider(),
              Center(
                child: SizedBox(
                  height: 40,
                  width: 150,
                  child: FlatButton(
                    child: Text(
                      "Lanjutkan",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: primaryColor,
                    shape: StadiumBorder(),
                    onPressed: () => _loginHP(_hpText.text),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _loginHP(String nohp) {
    if (nohp == null || nohp.trim().length < 10) {
      return Toast.show("Masukan Nomor Handphone dengan benar!", context, duration: 2);
    }
    if (nohp.startsWith("0")) {
      nohp = "+62" + nohp.substring(1);
    } else if (nohp.startsWith("62")) {
      nohp = "+" + nohp;
    }
    ProgressDialog progressDialog = ProgressDialog(
      context,
      title: Text("Sedang Memuat"),
      message: Text("Tunggu Sebentar..."),
    );

    progressDialog.show();
    try {
      _firebaseAuth
          .verifyPhoneNumber(
        phoneNumber: nohp,
        timeout: Duration(minutes: 1),
        verificationCompleted: (phoneAuthCredential) async {
          progressDialog.dismiss();
          var resp = await _submitOTP(phoneAuthCredential);
          if (resp ?? false) {
            Navigator.pop(context);
          }
          widget.state.setState(() {});
        },
        verificationFailed: (error) {
          progressDialog.dismiss();
          NAlertDialog(
            title: Text("Peringatan"),
            content: Text(error.message),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Close"),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
              )
            ],
          ).show(context);
        },
        codeSent: (verificationId, [forceResendingToken]) async {
          progressDialog.dismiss();
          final TextEditingController _etOTP = TextEditingController();
          final FocusNode focusNode = FocusNode();
          await NAlertDialog(
            title: Row(
              children: <Widget>[
                Expanded(child: Text("Konfirmasi")),
                SizedBox(
                  height: 30,
                  width: 30,
                  child: FlatButton(
                    padding: EdgeInsets.only(),
                    child: Icon(
                      Icons.close,
                      size: 20,
                    ),
                    shape: CircleBorder(side: BorderSide(color: Colors.grey)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
            dismissable: false,
            dialogStyle: DialogStyle(
              titleDivider: true,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Kami telah mengirim pesan kode OTP melalui SMS untuk melakukan verifikasi kepemilikan\n\nMasukan kode OTP"),
                ColumnDivider(space: 5),
                TextField(
                  onSubmitted: (value) async {
                    focusNode.unfocus();
                    if (value.trim() == "") return Toast.show("Masukan OTP untuk melanjutkan", context);
                    AuthCredential authCredential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: value.trim());
                    var resp = await _submitOTP(authCredential);
                    Navigator.pop(context, resp ?? false);
                  },
                  controller: _etOTP,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade300,
                    filled: true,
                    border: InputBorder.none,
                    counter: Container(),
                    hintText: "Kode OTP...",
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Konfirmasi",
                  style: TextStyle(color: Colors.white),
                ),
                color: primaryColor,
                onPressed: () async {
                  focusNode.unfocus();
                  if (_etOTP.text.trim() == "") return Toast.show("Masukan OTP untuk melanjutkan", context);
                  AuthCredential authCredential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: _etOTP.text.trim());
                  var resp = await _submitOTP(authCredential);

                  Navigator.pop(context, resp ?? false);
                },
              )
            ],
          ).show(context);
          widget.state.setState(() {});
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      )
          .catchError((e) {
        print(e);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _submitOTP(AuthCredential authCredential) async {
    var resp = await ProgressDialog.future(
      context,
      future: FirebaseAuth.instance.signInWithCredential(authCredential),
      title: Text("Mengirim Informasi"),
      message: Text("Tunggu Sebentar..."),
    ).catchError((error) async {
      log(error.toString());
      if (error.code == "ERROR_INVALID_VERIFICATION_CODE") {
        await NAlertDialog(
          title: Text("Terjadi Galat"),
          content: Text("Kode OTP yang anda masukan salah"),
          actions: <Widget>[
            FlatButton(
              child: Text("Mengerti"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ).show(context);
      }
    });
    if (resp == null) {
      NAlertDialog(
        title: Text("Terjadi Galat"),
        content: Text("Sepertinya saat ini anda belum bisa login melalui aplikasi ini!"),
        actions: <Widget>[
          FlatButton(
            child: Text("Mengerti"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ).show(context);
      return false;
    }

    var cekPengguna = await Firestore.instance.collection("pengguna").document(resp.user.uid).get();
    if (!cekPengguna.exists) {
      await Firestore.instance.collection("pengguna").document(resp.user.uid).setData({
        "nohp": resp.user.phoneNumber,
        "status": "sehat",
      });
      UserProvider userProvider = Provider.of(context, listen: false);
      userProvider.setUser(
        context,
        User(
          token: resp.user.uid,
          nohp: resp.user.phoneNumber,
          status: "sehat",
        ),
      );
    } else {
      UserProvider userProvider = Provider.of(context, listen: false);
      userProvider.setUser(
        context,
        User(
          token: resp.user.uid,
          nohp: cekPengguna?.data["nohp"] ?? "Tidak Tersedia",
          status: cekPengguna?.data["status"] ?? "Sehat",
        ),
      );
    }

    return true;
  }
}
