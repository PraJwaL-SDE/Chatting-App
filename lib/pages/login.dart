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
      WidgetHelper.errorDialog(context, "Incomplete Data", "Please fill in all values");
      print("Please fill in all values");
      return;
    } else {
      signIn(emailText, passwordText);
    }
  }

  void signIn(String email, String password) async {
    try {
      WidgetHelper.loadingDialog(context, "Logging in ..");
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        UserModel? user = await FirebaseHelper.getUserModelById(userCredential.user!.uid);

        if (user != null) {
          NotificationServices notificationServices = NotificationServices();
          user.deviceToken = await notificationServices.getDeviceToken();
          await FirebaseFirestore.instance.collection("user").doc(user.uid).set(user.toMap());

          // Close the loading dialog before navigating
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Home(userModel: user, firebaseUser: userCredential.user!),
            ),
          );
        } else {
          Navigator.pop(context); // Close the loading dialog
          WidgetHelper.errorDialog(context, "User Error", "User model could not be retrieved.");
        }
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the loading dialog

      if (e.code == 'user-not-found') {
        WidgetHelper.errorDialog(context, "User Not Found", e.message!);
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        WidgetHelper.errorDialog(context, e.code, e.message!);
        print('Wrong password provided for that user.');
      } else {
        WidgetHelper.errorDialog(context, "Error", e.message!);
      }
    }
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
