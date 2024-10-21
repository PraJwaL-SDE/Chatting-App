import 'package:chatting_app_2/helper/firebase_helper.dart';
import 'package:chatting_app_2/helper/notification_services.dart';
import 'package:chatting_app_2/models/group_chat_room.dart';
import 'package:chatting_app_2/pages/audio_call_screen.dart';
import 'package:chatting_app_2/pages/complete_profile.dart';
import 'package:chatting_app_2/pages/group_chat/create_new_group.dart';
import 'package:chatting_app_2/pages/group_chat/group_chatting_page.dart';
import 'package:chatting_app_2/pages/home.dart';
import 'package:chatting_app_2/pages/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'models/user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized before running the app
  runApp(const MyApp());
}

@pragma("vm:entry-point")
Future<void> _onBackgroundMessagehandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Set the splash screen as the home widget
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Using a post frame callback to ensure the context is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initServices(context);
    });
  }

  Future<void> _initServices(BuildContext context) async {
    try {
      await Firebase.initializeApp();
      print("Firebase connected");
    } on FirebaseException catch (e) {
      print(e.code.toString());
      // Optionally handle the error, e.g., show an alert dialog
    }

    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessagehandler);

    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      UserModel? thisUserModel = await FirebaseHelper.getUserModelById(firebaseUser.uid);
      if (thisUserModel != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(firebaseUser: firebaseUser, userModel: thisUserModel),
          ),
        );
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUp()));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: const CircularProgressIndicator(), // Show loading indicator
      ),
    );
  }
}


//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(SplashScreen());
//
//   // try {
//   //   await Firebase.initializeApp();
//   //   print("Firebase connected");
//   // } on FirebaseException catch (e) {
//   //   print(e.code.toString());
//   // }
//   //
//   // FirebaseMessaging.onBackgroundMessage(_onBackgroundMessagehandler);
//   //
//   // User? firebaseUser = FirebaseAuth.instance.currentUser;
//   // // runApp(TestApp());
//   // if (firebaseUser != null) {
//   //   UserModel? thisUserModel = await FirebaseHelper.getUserModelById(firebaseUser.uid);
//   //   if (thisUserModel != null) {
//   //     runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: firebaseUser));
//   //   } else {
//   //     runApp(const MyApp());
//   //   }
//   // } else {
//   //   runApp(const MyApp());
//   // }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const SignUp(),
//     );
//   }
// }
//
// class MyAppLoggedIn extends StatelessWidget {
//   final UserModel userModel;
//   final User? firebaseUser;
//   const MyAppLoggedIn({super.key, required this.userModel, this.firebaseUser});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       // home: Home(userModel: userModel, firebaseUser: firebaseUser),
//       home: Home(firebaseUser: firebaseUser, userModel: userModel),
//     );
//   }
// }

// class TestApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: CreateNewGroupScreen(),
//     );
//   }
//
// }
//
// class TestApp extends StatefulWidget {
//   final UserModel userModel;
//   final User? firebaseUser;
//
//   const TestApp({Key? key, required this.userModel, this.firebaseUser}) : super(key: key);
//
//   @override
//   _TestAppState createState() => _TestAppState();
// }
//
// class _TestAppState extends State<TestApp> {
//   GroupChatRoom? groupChatRoom;
//
//   @override
//   void initState() {
//     super.initState();
//     buildGroupChatRoom();
//   }
//
//   Future<void> buildGroupChatRoom() async {
//     groupChatRoom = await FirebaseHelper.getGroupChatRoomById("5b4eb6b0-8d75-11ef-a47e-017c0f577899");
//     // Ensure the widget is mounted before calling setState
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Show a loading indicator while the groupChatRoom is being fetched
//     if (groupChatRoom == null) {
//       return MaterialApp(
//         home: Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         ),
//       );
//     }
//
//     return MaterialApp(
//       home: GroupChattingPage(chatRoom: groupChatRoom!, userModel: widget.userModel),
//     );
//   }
// }