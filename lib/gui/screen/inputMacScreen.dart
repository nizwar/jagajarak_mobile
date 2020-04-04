import 'package:flutter/material.dart';
import 'package:jagajarak/core/res/string.dart';
import 'package:jagajarak/core/res/warna.dart';
import 'package:jagajarak/core/utils/bluetooth.dart';
import 'package:jagajarak/core/utils/macInput.dart';
import 'package:jagajarak/core/utils/mainUtils.dart';
import 'package:jagajarak/core/utils/preferences.dart';
import 'package:jagajarak/core/utils/systemSettings.dart';
import 'package:jagajarak/gui/components/CustomDivider.dart';
import 'package:jagajarak/gui/screen/mainScreen.dart';
import 'package:toast/toast.dart';

class InputMacScreen extends StatefulWidget {
  final String macAddress;

  const InputMacScreen({Key key, this.macAddress}) : super(key: key);
  @override
  InputMacScreenState createState() => InputMacScreenState();
}

class InputMacScreenState extends State<InputMacScreen> {
  final TextEditingController _etMac = TextEditingController();
  final MacInput _macInput = MacInput();

  @override
  void initState() {
    if (widget.macAddress != null)
      _etMac.text = widget.macAddress;
    else
      Bluetooth(context).getMacAddress().then((value) {
        print("Done");
        print(value.toString());
        if (value != null) _etMac.text = value;
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(30),
                children: <Widget>[
                  Image.asset(
                    "assets/images/illustration/connected.png",
                    height: 150,
                  ),
                  Text(
                    "Taukah kamu?",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  ColumnDivider(
                    space: 3,
                  ),
                  Text(
                    informasiMacBluetooth,
                    style: TextStyle(fontSize: 12),
                  ),
                  ColumnDivider(
                    space: 20,
                  ),
                  TextField(
                    controller: _etMac,
                    textAlign: TextAlign.center,
                    maxLength: 17,
                    onChanged: (val) => _macInput.macChange(val, _etMac),
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade300,
                      filled: true,
                      border: InputBorder.none,
                      counter: Container(),
                      hintText: "AB:CD:EF:12:34:56",
                    ),
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Lihat MAC Bluetooth",
                        style: TextStyle(color: primaryColor, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onTap: () async {
                      await SystemSettings().openDeviceInfo();
                    },
                  ),
                  ColumnDivider(),
                  SizedBox(
                    height: 40,
                    child: FlatButton(
                      color: primaryColor,
                      child: Text(
                        "Simpan",
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: StadiumBorder(),
                      onPressed: _simpanMac,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: widget.macAddress != null ? CloseButton() : Container(),
            )
          ],
        ),
      ),
    );
  }

  void _simpanMac() async {
    if (_etMac.text.length == 17) {
      if (!(await showMessage(context, title: perhatian, message: "Apa Bluetooth MAC Address yang kamu masukan sudah benar?", actions: [
            FlatButton(
              child: Text("Sudah Benar!"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            FlatButton(
              child: Text("Belum"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ])) ??
          false) return;

      (await Preferences.init(context)).saveMacBluetooth(_etMac.text);
      Toast.show("Detil Mac berhasil disimpan", context, duration: 2);
      if (widget.macAddress == null)
        replaceScreen(context, MainScreen());
      else
        Navigator.pop(context);
    } else {
      showMessage(context, title: perhatian, message: "Sepertinya MAC Addressmu tidak valid.");
      return;
    }
  }
}
