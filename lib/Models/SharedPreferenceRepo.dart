import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

setUser(FirebaseUser user, String themeName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("id", user.uid) ?? "User Id";
  await prefs.setString("userName", user.displayName) ?? "User Name";
  await prefs.setString("photoUrl", user.photoUrl) ??
      "https://ualr.edu/studentaffairs/files/2020/01/blank-picture-holder.png";
  await prefs.setString("status", "Hey I Am Using Incognito!");
  await prefs.setString("email", user.email) ?? "xxx@yyyy.zzz";

  // for local purpose
  await prefs.setString("theme", themeName);
}

Future setExistingUser(List<DocumentSnapshot> documents) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('id', documents[0]['id']);
  await prefs.setString('userName', documents[0]['userName']);
  await prefs.setString('photoUrl', documents[0]['photoUrl']);
  await prefs.setString('status', documents[0]['status']);
  await prefs.setString('email', documents[0]['email']);
}

Future<String> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getString('id') ?? 0);
}

Future<String> getUserName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getString('userName') ?? 0);
}

Future<String> getPhotoUrl() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getString('photoUrl') ?? 0);
}

Future<String> getStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getString('status') ?? 0);
}

Future<String> getUserEmail() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getString('email') ?? 0);
}

Future<String> getTheme() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getString('theme'));
}

Future<void> setTheme(String theme) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("theme", theme);
}

Future<void> clearSharedPreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}
