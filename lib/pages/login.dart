import 'package:chatting_app_2/helper/firebase_helper.dart';
import 'package:chatting_app_2/helper/notification_services.dart';
import 'package:chatting_app_2/pages/sign_up.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../helper/widget_helper.dart';
import '../models/user.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passWordController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  void checkValues() {
    String emailText = emailController.text.trim();
    String passwordText = passWordController.text.trim();

    if (emailText.isEmpty || passwordText.isEmpty) {
      print("Please fill in all values");
      return;
    } else {
      signIn(emailText, passwordText);
    }
  }

  void signIn(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if(userCredential!=null){
        UserModel? user = await FirebaseHelper.getUserModelById(userCredential.user!.uid);
        NotificationServices notificationServices = NotificationServices();
        user!.deviceToken = await notificationServices.getDeviceToken();
        await FirebaseFirestore.instance.collection("user").doc(user?.uid).set(
            user!.toMap());
        Navigator.push(context, MaterialPageRoute(
            builder: (context)=> Home(userModel: user!,firebaseUser: userCredential!.user,)));
      }

      
      print(userCredential.user!.uid.toString());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMyDialog("No user found for that email.");
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _showMyDialog("Wrong password provided for that user.");
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> _showMyDialog(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void signup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WidgetHelper.textFieldBuilder("Email", emailController),
            SizedBox(height: 10),
            WidgetHelper.textFieldBuilder("Password", passWordController),
            SizedBox(height: 10),
            SizedBox(height: 50),
            Container(
              width: 300,
              child: WidgetHelper.buttonSignIn("Sign in", checkValues),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Create an account? "),
                GestureDetector(
                  onTap: signup,
                  child: Text(
                    "Sign up",
                    style: TextStyle(color: Colors.deepPurpleAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
