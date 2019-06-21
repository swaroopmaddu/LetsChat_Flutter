import 'dart:async';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'googleAuth.dart';
import 'chatMessage.dart';
import 'googleAuth.dart';

final googleSignIn = new GoogleSignIn();
final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;
var currentUserEmail;

class ChatScreen extends StatefulWidget {
  static final String id = "chats";
  @override
  ChatScreenState createState() {
    return new ChatScreenState();
  }
}

class ChatScreenState extends State<ChatScreen> {
  GoogleAuth googleAuth = GoogleAuth();
  final TextEditingController _textEditingController =
      new TextEditingController();
  bool _isComposingMessage = false;
  final reference = FirebaseDatabase.instance.reference().child('messages');
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          automaticallyImplyLeading: false,
          leading: Icon(Icons.home),
          title: new Text("Let's Chat"),
          elevation:
              Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
          actions: <Widget>[
            RaisedButton.icon(
              onPressed: () {
                googleAuth.handleSignOut();
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
              label: Text(
                "Logout",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 18.0),
              ),
              color: Colors.blue,
              shape: RoundedRectangleBorder(side: BorderSide.none),
            )
          ],
        ),
        body: new Container(
          child: new Column(
            children: <Widget>[
              new Flexible(
                child: FirebaseAnimatedList(
                  query: reference,
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  sort: (a, b) => b.key.compareTo(a.key),
                  //comparing timestamp of messages to check which one would appear first
                  itemBuilder: (_, DataSnapshot messageSnapshot,
                      Animation<double> animation, int index) {
                    return ChatMessageListItem(
                      messageSnapshot: messageSnapshot,
                      animation: animation,
                    );
                  },
                ),
              ),
              new Divider(height: 1.0),
              new Container(
                decoration:
                    new BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(),
              ),
              new Builder(builder: (BuildContext context) {
                return new Container(width: 0.0, height: 0.0);
              })
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(
                      top: new BorderSide(
                  color: Colors.grey[200],
                )))
              : null,
        ));
  }

  CupertinoButton getIOSSendButton() {
    return new CupertinoButton(
      child: new Text("Send"),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(Icons.send),
      onPressed: _isComposingMessage
          ? () => _textMessageSubmitted(_textEditingController.text)
          : null,
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(
          color: _isComposingMessage
              ? Theme.of(context).accentColor
              : Theme.of(context).disabledColor,
        ),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(
                      Icons.photo_camera,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () async {
                      await googleAuth.handleSignIn();
                      File imageFile = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      int timestamp = new DateTime.now().millisecondsSinceEpoch;
                      StorageReference storageReference = FirebaseStorage
                          .instance
                          .ref()
                          .child("img_" + timestamp.toString() + ".jpg");
                      StorageUploadTask uploadTask =
                          storageReference.putFile(imageFile);
                      StorageTaskSnapshot storageTaskSnapshot =
                          await uploadTask.onComplete;
                      String downloadUrl =
                          await storageTaskSnapshot.ref.getDownloadURL();
                      _sendMessage(
                          messageText: null, imageUrl: downloadUrl.toString());
                    }),
              ),
              new Flexible(
                child: new TextField(
                    controller: _textEditingController,
                    onChanged: (String messageText) {
                      setState(() {
                        _isComposingMessage = messageText.length > 0;
                      });
                    },
                    onSubmitted: _textMessageSubmitted,
                    decoration: InputDecoration(
                        focusedBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        enabledBorder:
                            OutlineInputBorder(borderSide: BorderSide.none),
                        hintText: "Send a message")),
              ),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? getIOSSendButton()
                    : getDefaultSendButton(),
              ),
            ],
          ),
        ));
  }

  Future<Null> _textMessageSubmitted(String text) async {
    _textEditingController.clear();

    setState(() {
      _isComposingMessage = false;
    });

    await googleAuth.handleSignIn();
    _sendMessage(messageText: text, imageUrl: null);
  }

  void _sendMessage({String messageText, String imageUrl}) {
    print(loggedinUser.email);
    reference.push().set({
      'text': messageText,
      'email': loggedinUser.email,
      'imageUrl': imageUrl,
      'senderName': loggedinUser.displayName,
      'senderPhotoUrl': loggedinUser.photoUrl,
    });

    analytics.logEvent(name: 'send_message');
  }
}
