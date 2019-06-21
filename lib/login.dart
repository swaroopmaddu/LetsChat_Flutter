import 'package:flutter/material.dart';
import 'googleAuth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'chatscreen.dart';

class Login extends StatefulWidget {
  static final String id = "Login";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GoogleAuth googleAuth = GoogleAuth();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 60.0,
                        child: Icon(
                          Icons.chat,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                      Text(
                        "Let's Chat",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 32,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    isLoading
                        ? CircularProgressIndicator()
                        : GoogleSignInButton(
                            darkMode: true,
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });
                              FirebaseUser user =
                                  await googleAuth.handleSignIn();
                              if (user.uid == loggedinUser.uid) {
                                isLoading = false;
                                Navigator.pushNamed(context, ChatScreen.id);
                              } else {
                                print("Filed signin");
                              }
                            },
                          ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
