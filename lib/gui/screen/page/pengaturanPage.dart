import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';
import 'package:provider/provider.dart';
import 'package:jagajarak/core/provider/DeviceProvider.dart';
import 'package:jagajarak/core/utils/mainUtils.dart';
import 'package:jagajarak/core/utils/preferences.dart';
import 'package:jagajarak/gui/components/CustomDivider.dart';
import 'package:jagajarak/gui/screen/inputMacScreen.dart';

class PengaturanPage extends StatefulWidget {
  @override
  _PengaturanPageState createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  @override
  Widget build(BuildContext context) {
    DeviceProvider provider = Provider.of(context);
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 18, top: 20),
          child: Row(
            children: <Widget>[
              Text(
                "Umum",
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
              RowDivider(),
              Expanded(
                child: Divider(),
              )
            ],
          ),
        ),
        Consumer<DeviceProvider>(
          builder: (context, provider, child) {
            return ListTile(
              title: Text("Nama Kamu"),
              subtitle: Text(provider.userName != null ? (provider.userName.trim().length > 0 ? provider.userName.trim() : "Anonim") : "Anonim"),
              onTap: () async {
                _changName(provider);
              },
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(left: 18, top: 20),
          child: Row(
            children: <Widget>[
              Text(
                "Sistem",
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
              RowDivider(),
              Expanded(
                child: Divider(),
              )
            ],
          ),
        ),
        Consumer<DeviceProvider>(
          builder: (context, provider, child) {
            return ListTile(
              title: Text("MAC Address"),
              subtitle: Text(provider.mac),
              onTap: () async {
                await startScreen(
                  context,
                  InputMacScreen(
                    macAddress: provider.mac,
                  ),
                );
              },
            );
          },
        ),
        SwitchListTile(
          title: Text("Layanan Saat Dijalankan"),
          subtitle: Text("Layanan otomatis dijalankan saat kamu membuka aplikasi."),
          value: provider.startServiceOnStart,
          onChanged: (value) async {
            await (await Preferences.init(context)).saveServiceOnStart(value); 
            setState(() {});
          },
        )
      ],
    );
  }

  void _changName(provider) async {
    await showDialog(
        context: context,
        builder: (context) {
          TextEditingController _etNama = TextEditingController(text: provider.userName ?? "");
          return NAlertDialog(
            title: Text("Masukan Namamu"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text("Nama hanya akan ditampilkan di aplikasi ini, Tidak akan disebarkan kesiapapun."),
                ColumnDivider(),
                Text(
                  "Kosongkan jika kamu mau menjadi Anonim",
                  style: TextStyle(fontSize: 10),
                ),
                ColumnDivider(),
                TextField(
                  controller: _etNama,
                  maxLength: 18,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.shade300,
                    filled: true,
                    border: InputBorder.none,
                    counter: Container(),
                    hintText: "Masukan nama kamu disini",
                  ),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Simpan"),
                onPressed: () async {
                  (await Preferences.init(context)).saveUserName(_etNama.text.trim());
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Batal"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
    setState(() {});
  }
}
