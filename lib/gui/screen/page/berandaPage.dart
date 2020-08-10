import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jagajarak/core/provider/UserProvider.dart';
import 'package:jagajarak/core/utils/preferences.dart';
import 'package:provider/provider.dart';
import 'package:jagajarak/core/provider/DeviceProvider.dart';
import 'package:jagajarak/core/res/string.dart';
import 'package:jagajarak/core/utils/services.dart';
import 'package:jagajarak/gui/components/CustomDivider.dart';

class BerandaPage extends StatefulWidget {
  @override
  _BerandaPageState createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  @override
  Widget build(BuildContext context) {
    DeviceProvider provider = Provider.of(context);
    Widget body = Container();
    if (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height) {
      body = SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 50),
        child: _body(provider, context),
      );
    } else {
      body = Center(
        child: FittedBox(
          alignment: Alignment.center,
          child: _body(provider, context),
        ),
      );
    }
    return body;
  }

  Widget _body(DeviceProvider provider, BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection("pengguna").document(userProvider.getUser.token).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            String health = (snapshot.data?.data["status"] ?? "healthy").toLowerCase();
            Color bgHealthColor = Colors.grey;
            String peringatan = healthMsg;
            Preferences.init(context).then((value) {
              value.saveHealthStatus(snapshot.data?.data["status"]);
            });
            switch (health) {
              case "healthy":
                health = "Sehat";
                bgHealthColor = Theme.of(context).primaryColor;
                peringatan = healthMsg;
                break;
              case "sehat":
                health = "Sehat";
                bgHealthColor = Theme.of(context).primaryColor;
                peringatan = healthMsg;
                break;
              case "odp":
                health = "Orang Dalam Pengawasan";
                bgHealthColor = Theme.of(context).accentColor;
                peringatan = odpMsg;
                break;
              case "pdp":
                health = "Pasien Dalam Perawatan";
                bgHealthColor = Colors.red;
                peringatan = pdpMsg;
                break;
            }
            return Column(
              children: <Widget>[
                Image.asset("assets/images/illustration/social_distance.png", height: 150),
                ColumnDivider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                        text: "Selamat datang,\n",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      TextSpan(
                        text: provider.userName != null ? (provider.userName.trim().length > 0 ? provider.userName.trim() : "Anonim") : "Anonim",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: bgHealthColor),
                      ),
                    ]),
                  ),
                ),
                ColumnDivider(),
                Text(
                  "Kondisimu saat ini adalah",
                  textAlign: TextAlign.center,
                ),
                ColumnDivider(
                  space: 4,
                ),
                Center(
                  child: SizedBox(
                    height: 40,
                    child: FlatButton(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      color: bgHealthColor,
                      shape: StadiumBorder(),
                      child: Text(
                        health,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () async {
                        // await startScreen(context, LaporScreen());
                        // setState(() {});
                      },
                    ),
                  ),
                ),
                ClipPath(
                  clipper: Segitiga(),
                  child: Container(
                    color: bgHealthColor,
                    height: 20,
                    width: 20,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: bgHealthColor),
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width - 50,
                  child: Text(
                    peringatan,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                ColumnDivider(
                  space: 40,
                )
              ],
            );
          },
        ),
        StreamLayananWidget(
          key: UniqueKey(),
        ),
        ColumnDivider(
          space: 20,
        ),
      ],
    );
  }
}

class StreamLayananWidget extends StatefulWidget {
  const StreamLayananWidget({Key key}) : super(key: key);
  @override
  _StreamLayananWidgetState createState() => _StreamLayananWidgetState();
}

class _StreamLayananWidgetState extends State<StreamLayananWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Services(context).streamServiceStatus(),
      initialData: "stop",
      builder: (context, snapshot) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 100,
              width: 100,
              child: RaisedButton(
                shape: CircleBorder(),
                elevation: 5,
                color: ((snapshot.data ?? "stop") == "stop") ? Theme.of(context).primaryColor : Theme.of(context).accentColor,
                child: Icon(
                  Icons.fingerprint,
                  color: Colors.white,
                  size: 60,
                ),
                onPressed: () async {
                  if ((snapshot.data ?? "stop") == "stop") {
                    await Services(context).startService();
                  } else {
                    await Services(context).stopService();
                  }
                  setState(() {});
                },
              ),
            ),
            ColumnDivider(
              space: 5,
            ),
            Text(
              ((snapshot.data ?? "stop") == "stop") ? "Mulai Layanan" : "Hentikan Layanan",
              style: TextStyle(
                color: ((snapshot.data ?? "stop") == "stop") ? Theme.of(context).primaryColor : Theme.of(context).accentColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class Segitiga extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo((size.width / 2), 5);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
