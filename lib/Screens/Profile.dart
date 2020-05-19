import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:incognito/widgets/ReusableWidgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatelessWidget {
  const Profile({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  State createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  TextEditingController controllerUserName;
  TextEditingController controllerStatus;

  SharedPreferences prefs;

  String id = '';
  String userName = '';
  String status = '';
  String photoUrl = '';

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeUserName = new FocusNode();
  final FocusNode focusNodeStatus = new FocusNode();

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.ensureVisualUpdate();
    WidgetsBinding.instance.addObserver(this);
    readLocal();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    userName = prefs.getString('userName') ?? '';
    status = prefs.getString('status') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    controllerUserName = new TextEditingController(text: userName);
    controllerStatus = new TextEditingController(text: status);

    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (mounted) {
        setState(() {
          avatarImageFile = image;
          isLoading = true;
        });
      }
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = id;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance.collection('users').document(id).updateData({
            'userName': userName,
            'status': status,
            'photoUrl': photoUrl
          }).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
            Fluttertoast.showToast(msg: "Upload success");
          }).catchError((err) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleUpdateData() {
    focusNodeUserName.unfocus();
    focusNodeStatus.unfocus();
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    Firestore.instance.collection('users').document(id).updateData({
      'userName': userName,
      'status': status,
      'photoUrl': photoUrl
    }).then((data) async {
      await prefs.setString('userName', userName);
      await prefs.setString('status', status);
      await prefs.setString('photoUrl', photoUrl);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      Fluttertoast.showToast(msg: "Update success");
    }).catchError((err) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Avatar
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (avatarImageFile == null)
                          ? (photoUrl != ''
                              ? Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child:
                                          reusableWidget().indicator(context),
                                      width: 90.0,
                                      height: 90.0,
                                      padding: EdgeInsets.all(20.0),
                                    ),
                                    imageUrl: photoUrl,
                                    width: 90.0,
                                    height: 90.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(45.0)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 90.0,
                                ))
                          : Material(
                              child: Image.file(
                                avatarImageFile,
                                width: 90.0,
                                height: 90.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(45.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(30.0),
                        iconSize: 30.0,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),

              // Input
              Column(
                children: <Widget>[
                  // Username
                  Container(
                    child: Text(
                      'UserName',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Sweetie',
                        contentPadding: new EdgeInsets.all(5.0),
                      ),
                      controller: controllerUserName,
                      onChanged: (value) {
                        userName = value;
                      },
                      focusNode: focusNodeUserName,
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  // About me
                  Container(
                    child: Text(
                      'About me',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                  ),
                  Container(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Fun, like travel and play PES...',
                        contentPadding: EdgeInsets.all(5.0),
                      ),
                      controller: controllerStatus,
                      onChanged: (value) {
                        status = value;
                      },
                      focusNode: focusNodeStatus,
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              // Button
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: RaisedButton(
                  onPressed: handleUpdateData,
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'UPDATE',
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Theme.of(context).textTheme.body1.color),
                  ),
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        ),

        // Loading
        Positioned(
          child: isLoading
              ? Center(
                  child: reusableWidget().indicator(context),
                )
              : Container(),
        ),
      ],
    );
  }
}
