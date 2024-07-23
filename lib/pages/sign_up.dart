import 'package:chatting_app_2/helper/widget_helper.dart';
import 'package:chatting_app_2/models/user.dart';
import 'package:chatting_app_2/pages/complete_profile.dart';
import 'package:chatting_app_2/pages/home.dart';
import 'package:chatting_app_2/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passWordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();


  void checkValues(){
    String emailText = emailController.text.trim();
    String passwordText = passWordController.text.trim();
    String cPasswordText = cPasswordController.text.trim();

    if(emailText == "" || passwordText=="" || cPasswordText=="")
      {
        print("fill the all values");
        return;

      }else
    if(passwordText!=cPasswordText){
      print("Password Not Matching");
      return;
    }
    else{
      signup(emailText, passwordText);
    }
    print(".....................................................");
  }

  void signup(String email,String password) async{
    UserCredential? userCredential ;
    try{
      userCredential = await FirebaseAuth.instance.
      createUserWithEmailAndPassword(email: email, password: password);


    } on  FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
    print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
    print('The account already exists for that email.');
    }
    }
    String uid = userCredential!.user!.uid.toString();
    if(userCredential!=null){
      UserModel user = UserModel(
        uid: uid,
        email: email,
        name: "",
        profilePic: ""
      );
      try {
        await FirebaseFirestore.instance.collection("user").doc(uid).set(
            user.toMap());
        Navigator.push(context, MaterialPageRoute(builder: (context)=> CompleteProfile(userModel: user,firebaseUser: userCredential!.user,)));
      } on FirebaseException catch(e){
        print(e.code.toString());
      }

    }

  }

  void signin(){
      Navigator.push(context,MaterialPageRoute(builder: (context)=> const Login()));
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
            SizedBox(height: 10,),
            WidgetHelper.textFieldBuilder("Password", passWordController),
            SizedBox(height: 10,),
            WidgetHelper.textFieldBuilder("Conform Password", cPasswordController),
            SizedBox(height: 50,),
            Container(
                width: 300,
                child: WidgetHelper.buttonSignIn("Sign Up", checkValues)
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Text("already have an account? "),
                GestureDetector(
                  onTap: signin,
                  child: Text("sign in",
                    style: TextStyle(color: Colors.deepPurpleAccent),

                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}