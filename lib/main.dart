import 'package:flutter/material.dart';
import 'login.dart';
import 'chatscreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Login.id,
      routes: {
        Login.id: (context) => Login(),
        ChatScreen.id: (context) => ChatScreen(),
      },
    );
  }
}
