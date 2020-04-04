import 'package:flutter/material.dart';

class AlertScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const AlertScreen({Key key, this.title, this.subtitle}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(20),
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  Image.asset("assets/images/signal.gif", height: 150,),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Positioned(
              child: CloseButton(),
              left: 10,
              top: 10,
            )
          ],
        ),
      ),
    );
  }
}
