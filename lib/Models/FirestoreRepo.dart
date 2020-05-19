import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// create new user in FireStore Database
void createNewUser(FirebaseUser fireBaseUser) {
  Firestore.instance.collection('users').document(fireBaseUser.uid).setData({
    'userName': fireBaseUser.displayName,
    'photoUrl': fireBaseUser.photoUrl,
    'id': fireBaseUser.uid,
    'email': fireBaseUser.email,
    'status': "Hey There I Am Using Incognito", // default status
    'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
    'chattingWith': null
  });
}

// if this return list length == 0, user not available, else available
Future<List<DocumentSnapshot>> isUserAlreadyExist(
    FirebaseUser fireBaseUser) async {
  final QuerySnapshot result = await Firestore.instance
      .collection('users')
      .where('id', isEqualTo: fireBaseUser.uid)
      .getDocuments();
  final List<DocumentSnapshot> documents = result.documents;
  return documents;
}

// Google Auth returns FireBaseUser
Future<FirebaseUser> googleSignInFireBase() async {
  GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
  GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  FirebaseUser firebaseUser =
      (await FirebaseAuth.instance.signInWithCredential(credential)).user;
  return firebaseUser;
}

Future insertMessageInDatabase(String content, int type, String id,
    String groupChatId, String peerId, String peerAvatar) async {
  var documentReference = Firestore.instance
      .collection('messages')
      .document(groupChatId)
      .collection(groupChatId)
      .document(DateTime.now().millisecondsSinceEpoch.toString());

  Firestore.instance.runTransaction((transaction) async {
    await transaction.set(
      documentReference,
      {
        'idFrom': id,
        'idTo': peerId,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': content.trim(),
        'type': type
      },
    );
  });
}
