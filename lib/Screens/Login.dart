import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:incognito/Models/FirestoreRepo.dart';
import 'package:incognito/Models/SharedPreferenceRepo.dart';
import 'package:incognito/Screens/Home.dart';
import 'package:incognito/widgets/ReusableWidgets.dart';
import 'package:incognito/widgets/flip_card.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with WidgetsBindingObserver {
  bool isLoading;
  bool isLoggedIn;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.ensureVisualUpdate();
    WidgetsBinding.instance.addObserver(this);
    isLoading = false;
    isLoggedIn = false;
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: !isLoading
                ? MaterialButton(
                    enableFeedback: true,
                    onPressed: handleSignIn,
                    child: Text(
                      'SIGN IN WITH GOOGLE',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    color: Color(0xffdd4b39),
                    highlightColor: Color(0xffff7f7f),
                    splashColor: Colors.transparent,
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0),
                  )
                : reusableWidget().indicator(context),
          ),
        ],
      ),
    );
  }

  Future<void> handleSignIn() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    // google sign-in
    FirebaseUser firebaseUser;
    try {
      firebaseUser = await googleSignInFireBase();
    } catch (Exception) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
    if (firebaseUser != null) {
      // Check if already exist
      List<DocumentSnapshot> documents = await isUserAlreadyExist(firebaseUser);

      if (documents.length == 0) {
        // New User in Database
        createNewUser(firebaseUser);
        // set user info in preference
        setUser(firebaseUser, "lightTheme");
        Fluttertoast.showToast(msg: "Welcome " + firebaseUser.displayName);
      } else {
        // set user info in preference
        await setExistingUser(documents);
        Fluttertoast.showToast(msg: "Welcome Back " + documents[0]['userName']);
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      Navigator.push(
        context,
        FadeRoute(
          page: Home(currentUserId: firebaseUser.uid),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: "Something Went Wrong.\nPlease Try Again.");
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
