import 'package:cloud_firestore/cloud_firestore.dart';

Stream<QuerySnapshot> userListSnapShots() =>
    Firestore.instance.collection('users').snapshots();

Stream<QuerySnapshot> chatMessageStream(String groupChatId) {
  return Firestore.instance
      .collection('messages')
      .document(groupChatId)
      .collection(groupChatId)
      .orderBy('timestamp', descending: true)
      .limit(20)
      .snapshots();
}
