import 'package:chatting_app_2/helper/firebase_helper.dart';
import 'package:chatting_app_2/helper/notification_services.dart';
import 'package:chatting_app_2/pages/complete_profile.dart';
import 'package:chatting_app_2/pages/home.dart';
import 'package:chatting_app_2/pages/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'models/user.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("Firebase connected");
  } on FirebaseException catch (e) {
    print(e.code.toString());
  }

  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessagehandler);

  User? firebaseUser = FirebaseAuth.instance.currentUser;
  if (firebaseUser != null) {
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(firebaseUser.uid);
    if (thisUserModel != null) {
      runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: firebaseUser));
    } else {
      runApp(const MyApp());
    }
  } else {
    runApp(const MyApp());
  }
}

@pragma("vm:entry-point")
Future<void> _onBackgroundMessagehandler(RemoteMessage message) async{
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SignUp(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User? firebaseUser;
  const MyAppLoggedIn({super.key, required this.userModel, this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
