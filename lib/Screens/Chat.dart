import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:incognito/Models/streamSnapShots.dart';
import 'package:incognito/Screens/FullScreenImageView.dart';
import 'package:incognito/widgets/ReusableWidgets.dart';
import 'package:incognito/widgets/flip_card.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chat extends StatelessWidget {
  final String peerId;
  final String peerAvatar;
  final String userName;

  const Chat(
      {@required this.peerId,
      @required this.peerAvatar,
      @required this.userName,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onBackPress(context),
      child: ChatScreen(
          peerId: peerId, peerAvatar: peerAvatar, userName: userName),
    );
  }

  Future<bool> onBackPress(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('id') ?? '';
    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'chattingWith': null});
    Navigator.pop(context);
    return Future.value(false);
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String userName;

  const ChatScreen(
      {@required this.peerId,
      @required this.peerAvatar,
      @required this.userName,
      Key key})
      : super(key: key);

  @override
  State createState() => ChatScreenState(
      peerId: peerId, peerAvatar: peerAvatar, userName: userName);
}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  String peerId;
  String peerAvatar;
  String userName;
  String id;

  ChatScreenState(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.userName});

  dynamic touchPosition;
  var listMessage;
  String groupChatId;

  File imageFile;
  bool isLoading;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final apiKey = 'lnK2hMbOU79KoYDSoY9eSIZFaW2WFgd7';

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    focusNode.unfocus();
    groupChatId = '';
    isLoading = false;
    imageUrl = '';
    readLocal();
  }

  readLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'chattingWith': peerId});

    if (mounted) {
      setState(() {});
    }
  }

  Future getImageFromGallery() async {
    focusNode.unfocus();
    imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear);

    if (imageFile != null) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      uploadImageFile();
    } else {
      Fluttertoast.showToast(msg: "No Image Selected");
    }
  }

  Future<void> pickGiphyGif(BuildContext context) async {
    focusNode.unfocus();
    final gif = await GiphyPicker.pickGif(
      showPreviewPage: false,
      context: context,
      apiKey: apiKey,
    );
    onSendMessage(gif.images.previewWebp.url, 2);
  }

  Future uploadImageFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      if (mounted) {
        setState(() {
          isLoading = false;
          onSendMessage(imageUrl, 1);
        });
      }
    }, onError: (err) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    String temp;
    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      if (listMessage.length != null && listMessage.length != 0) {
        print("changedDate length " + listMessage.length.toString());
        temp = listMessage[0]['timestamp'];
      } else {
        temp = DateTime.now().millisecondsSinceEpoch.toString();
      }
      print("changedDate temp " + temp);
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'changedDate': temp.toString(),
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content.trim(),
            'type': type
          },
        );
      });
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);
    }
  }

  Widget buildItem(int index, DocumentSnapshot document, BuildContext context) {
    DateTime lastMessageDate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(document['changedDate']))
            .toUtc();
    DateTime currentMessageDate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(document['timestamp']))
            .toUtc();
    print("difference : " +
        lastMessageDate.difference(DateTime.now().toUtc()).inDays.toString());
    return Column(
      children: <Widget>[
        (lastMessageDate.day - currentMessageDate.day) != 0
            ? Center(
                child: Container(
                  padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).splashColor,
                      borderRadius: BorderRadius.circular(5.0)),
                  child: Text(
                    DateFormat('dd MMM yyyy').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(document['timestamp']))),
                    style: TextStyle(color: Theme.of(context).indicatorColor),
                  ),
                ),
              )
            : SizedBox(),
        (document['idFrom'] == id)
            ? ownMessageRow(document, context, index)
            : otherMessageRow(context, index, document),
      ],
    );
  }

  Widget otherMessageRow(
      BuildContext context, int index, DocumentSnapshot document) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        document['type'] == 0
            ? otherPersonTextMessage(context, document)
            : otherPersonImageGifMessage(context, document)
      ],
    );
  }

  Widget ownMessageRow(
      DocumentSnapshot document, BuildContext context, int index) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        document['type'] == 0
            ? ownTextMessage(context, document, index)
            : ownImageGifMessage(context, document)
      ],
      mainAxisAlignment: MainAxisAlignment.end,
    );
  }

  Widget ownTextMessage(
      BuildContext context, DocumentSnapshot document, int index) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(width: 1),
        color: Theme.of(context).primaryColor,
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: Text(
        document['content'],
        maxLines: 75,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white),
      ),
      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      margin: EdgeInsets.all(5),
    );
  }

  Widget ownImageGifMessage(BuildContext context, DocumentSnapshot document) {
    return Stack(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 1),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
          maxHeight: MediaQuery.of(context).size.width * 0.7,
        ),
        child: InkWell(
          child: Hero(
            tag: document['content'],
            child: Material(
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.45,
                  child: reusableWidget().indicator(context),
                  padding: EdgeInsets.all(70.0),
                ),
                errorWidget: (context, url, error) => Material(
                  child: Image.asset(
                    'assets/images/img_not_available.jpeg',
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                ),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.45,
                imageUrl: document['content'],
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              clipBehavior: Clip.hardEdge,
            ),
          ),
          onTap: () {
            // ignore: unnecessary_statements
            focusNode.hasFocus ? focusNode.unfocus() : null;
            Navigator.push(context,
                FadeRoute(page: FullScreenImageView(url: document['content'])));
          },
        ),
        margin: EdgeInsets.all(5.0),
      ),
      Positioned(
        right: 20,
        bottom: 10,
        child: Text(
          DateFormat('h:mma').format(DateTime.fromMillisecondsSinceEpoch(
              int.parse(document['timestamp']))),
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
      ),
    ]);
  }

  Widget otherPersonProfileImage(int index) {
    return isLastMessageLeft(index)
        ? Material(
            child: CachedNetworkImage(
              placeholder: (context, url) => Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.1,
                    maxHeight: MediaQuery.of(context).size.height * 0.1),
                child: reusableWidget().indicator(context),
                padding: EdgeInsets.all(5.0),
              ),
              imageUrl: peerAvatar,
              width: 35.0,
              height: 35.0,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(18.0),
            ),
            clipBehavior: Clip.hardEdge,
          )
        : Container(width: 35.0);
  }

  Widget otherPersonImageGifMessage(
      BuildContext context, DocumentSnapshot document) {
    return Stack(children: <Widget>[
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 1),
        ),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
            maxHeight: MediaQuery.of(context).size.width * 0.7),
        child: InkWell(
          child: Hero(
            tag: document['content'],
            child: Material(
              child: CachedNetworkImage(
                placeholder: (context, url) => Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.45,
                  child: reusableWidget().indicator(context),
                  padding: EdgeInsets.all(70.0),
                ),
                errorWidget: (context, url, error) => Material(
                  child: Image.asset(
                    'assets/images/img_not_available.jpeg',
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                ),
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.45,
                imageUrl: document['content'],
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              clipBehavior: Clip.hardEdge,
            ),
          ),
          onTap: () {
            focusNode.unfocus();
            Navigator.push(context,
                FadeRoute(page: FullScreenImageView(url: document['content'])));
          },
        ),
        margin: EdgeInsets.all(5.0),
      ),
      Positioned(
        right: 20,
        bottom: 10,
        child: Text(
          DateFormat('h:mma').format(DateTime.fromMillisecondsSinceEpoch(
              int.parse(document['timestamp']))),
          style: TextStyle(
              fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
      ),
    ]);
  }

  Widget otherPersonTextMessage(
      BuildContext context, DocumentSnapshot document) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(width: 1),
        color: Theme.of(context).primaryColor,
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      child: Text(
        document['content'],
        maxLines: 75,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white),
      ),
      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      margin: EdgeInsets.all(5.0),
    );
  }

  // if last message from other user
  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            userName,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: buildListMessage(),
              flex: (MediaQuery.of(context).size.height * 0.95).ceil(),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: buildInput(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Center(
              child: reusableWidget().indicator(context),
            )
          : Container(),
    );
  }

  // chat text field
  Widget buildInput() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.25,
      ),
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.image,
                color: Theme.of(context).indicatorColor,
              ),
              onPressed: getImageFromGallery,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.face,
                color: Theme.of(context).indicatorColor,
              ),
              onPressed: () => pickGiphyGif(context),
            ),
          ),
          Flexible(
            child: Container(
              child: TextField(
                maxLines: 10,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                style: TextStyle(fontSize: 18.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                    hintText: 'Type your message...',
                    hintStyle:
                        TextStyle(color: Theme.of(context).indicatorColor)),
                focusNode: focusNode,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).splashColor,
            ),
            child: Container(
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).indicatorColor,
                ),
                onPressed: () =>
                    onSendMessage(textEditingController.text.trim(), 0),
              ),
            ),
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                width: 0.5, color: Theme.of(context).indicatorColor)),
      ),
    );
  }

  Widget buildListMessage() {
    return groupChatId == ''
        ? Center(
            child: reusableWidget().indicator(context),
          )
        : StreamBuilder(
            stream: chatMessageStream(groupChatId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: reusableWidget().indicator(context),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("No Data Found"),
                );
              } else {
                listMessage = snapshot.data.documents;
                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(5.0),
                  itemBuilder: (context, index) =>
                      buildItem(index, snapshot.data.documents[index], context),
                  itemCount: snapshot.data.documents.length,
                  reverse: true,
                  controller: listScrollController,
                );
              }
            },
          );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    listScrollController.dispose();
    focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
