import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:incognito/Models/streamSnapShots.dart';
import 'package:incognito/Screens/Chat.dart';
import 'package:incognito/Screens/Drawer.dart';
import 'package:incognito/widgets/ReusableWidgets.dart';
import 'package:incognito/widgets/routings.dart';

class Home extends StatelessWidget {
  final String currentUserId;

  Home({Key key, @required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Incognito',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: DrawerScreen(),
      body: HomeScreen(
        currentUserId: currentUserId,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({Key key, @required this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  HomeScreenState({Key key, @required this.currentUserId});

  final String currentUserId;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isLoading = false;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.ensureVisualUpdate();
    WidgetsBinding.instance.ensureFrameCallbacksRegistered();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    registerNotification();
    configLocalNotification();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance
          .collection('users')
          .document(currentUserId)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'io.incognito' : 'ios.io.incognito',
      'Flutter chat demo',
      'notification without payload',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  Future<bool> onBackPress() {
    reusableWidget().openDialog(context);
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            Container(
              child: StreamBuilder(
                stream: userListSnapShots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: reusableWidget().indicator(context),
                    );
                  } else {
                    return ListView.separated(
                      shrinkWrap: false,
                      separatorBuilder: (context, _) => Divider(
                        height: 0,
                        indent: 20,
                        endIndent: 20,
                        thickness: 1,
                        color: Theme.of(context).splashColor,
                      ),
                      itemBuilder: (context, index) => userListItems(
                          context, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                },
              ),
            ),
            Positioned(
              child: isLoading
                  ? Center(
                      child: reusableWidget().indicator(context),
                    )
                  : Container(),
            )
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  Widget userListItems(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return ListTile(
        leading: document['photoUrl'] != null
            ? CachedNetworkImage(
                width: 50,
                height: 50,
                imageUrl: document['photoUrl'],
                fadeInCurve: Curves.bounceIn,
                fadeOutCurve: Curves.bounceOut,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: 50,
                    width: 50,
                  ),
                ),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Icon(Icons.error),
              )
            : Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_circle,
                ),
              ),
        title: Text(
          document['userName'],
        ),
        subtitle: Text(
          '${document['status'] ?? 'Not available'}',
        ),
        onTap: () => Navigator.push(
          context,
          FadeRoute(
            page: Chat(
              peerId: document.documentID,
              peerAvatar: document['photoUrl'],
              userName: document['userName'],
            ),
          ),
        ),
      );
    }
  }
}
