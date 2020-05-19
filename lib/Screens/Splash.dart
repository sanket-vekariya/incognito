import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:incognito/Screens/Home.dart';
import 'package:incognito/Screens/Login.dart';
import 'package:incognito/widgets/flip_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  Splash({Key key}) : super(key: key);

  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;
  var _visible = true;
  final int splashDuration = 2;

  AnimationController animationController;
  Animation<double> animation;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.ensureVisualUpdate();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 2),
    );
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() {
      if (mounted) {
        this.setState(() {});
      }
    });
    animationController.forward();
    if (mounted) {
      setState(() {
        _visible = !_visible;
      });
    }
    countDownTime();
  }

  countDownTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Timer(
      Duration(seconds: splashDuration),
      () async {
        isLoggedIn = await googleSignIn.isSignedIn();
        var uid = await prefs.getString('id');
        if (isLoggedIn) {
          Navigator.pushReplacement(
            context,
            FadeRoute(
              page: Home(currentUserId: uid),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            ScaleRoute(page: Login()),
          );
        }
      },
    );
  }

  @override
  dispose() {
    animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            new Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 30.0),
                  child: new Image.asset(
                    'assets/images/glogo.png',
                    height: 25.0,
                    fit: BoxFit.scaleDown,
                  ),
                )
              ],
            ),
            new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlutterLogo(
                  size: animation.value * 2000,
                ),
//                new Image.asset(
//                  'assets/images/glogo.png',
//                  width: animation.value * 250,
//                  height: animation.value * 250,
//                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
