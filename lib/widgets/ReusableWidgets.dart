import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:incognito/Models/SharedPreferenceRepo.dart';
import 'package:incognito/Screens/Login.dart';
import 'package:incognito/widgets/flip_card.dart';

class DrawerListTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final VoidCallback onTilePressed;

  const DrawerListTile({Key key, this.iconData, this.title, this.onTilePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTilePressed,
      dense: true,
      leading: Icon(
        iconData,
        color: Theme.of(context).textTheme.body1.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).textTheme.body1.color,
        ),
      ),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onYesPressed;
  final VoidCallback onNoPressed;

  const LogoutDialog(
      {Key key,
      @required this.title,
      this.body,
      this.onYesPressed,
      this.onNoPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 200,
      title: title != null ? Text(title ?? "") : null,
      content: body != null ? Text(body ?? "") : null,
      actions: <Widget>[
        onYesPressed != null
            ? MaterialButton(
                child: Text("Yes"),
                onPressed: onYesPressed,
              )
            : null,
        onNoPressed != null
            ? MaterialButton(
                child: Text("No"),
                onPressed: onNoPressed,
              )
            : null,
      ],
    );
  }
}

class reusableWidget {
  Future<Null> openDialog(BuildContext context) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit App',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Icon(
                            Icons.check_circle,
                          ),
                          margin: EdgeInsets.only(right: 10.0),
                        ),
                        Text(
                          'YES',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Icon(
                            Icons.cancel,
                          ),
                          margin: EdgeInsets.only(right: 10.0),
                        ),
                        Text(
                          'CANCEL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  Future<Null> logoutDialog(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Sign-Out?',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure?',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      handleSignOut(context);
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Icon(
                            Icons.check_circle,
                          ),
                          margin: EdgeInsets.only(right: 10.0),
                        ),
                        Text(
                          'YES',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Icon(
                            Icons.cancel,
                          ),
                          margin: EdgeInsets.only(right: 10.0),
                        ),
                        Text(
                          'NO',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future<void> handleSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().disconnect();
    await GoogleSignIn().signOut();
    clearSharedPreference();
    Navigator.pushAndRemoveUntil(
      context,
      FadeRoute(
        page: Login(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Widget indicator(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor:
            AlwaysStoppedAnimation<Color>(Theme.of(context).indicatorColor),
      ),
    );
  }
}
