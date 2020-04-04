import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

Future startScreen(BuildContext context, Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (context) => screen));

Future replaceScreen(BuildContext context, Widget screen) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => screen));

Future showMessage(BuildContext context, {String title, String message, List<Widget> actions}) => showDialog(
      context: context,
      builder: (context) => NAlertDialog(
        title: title != null ? Text(title) : null,
        content: message != null ? SingleChildScrollView(child: Text(message)) : null,
        actions: actions != null
            ? actions
            : [
                FlatButton(
                  child: Text("Mengerti"),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
      ),
    );
