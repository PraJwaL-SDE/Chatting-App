import 'dart:io';

import 'package:chatting_app_2/helper/widget_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';
import 'home.dart';

class CompleteProfile extends StatefulWidget {
  // const CompleteProfile({super.key});
  final UserModel userModel;
  final User? firebaseUser ;
  CompleteProfile({Key? key,required this.userModel, required this.firebaseUser}):super(key: key);

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  TextEditingController _controller = TextEditingController();
  File? imageFile;
  void selectImage(ImageSource imageSource) async{
    ImagePicker imagePicker = ImagePicker();
    try{
      XFile? xfile = await imagePicker.pickImage(source: imageSource);
      cropImage(xfile!);
    }catch(e){
      print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
      print(e);
    }


  }
  void cropImage(XFile file) async{
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20
    );

    if(croppedFile!=null){
      imageFile = File(croppedFile.path);
    }
  }

  void openDialog()  {
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Center(child: Text("Select source")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap:(){
                Navigator.pop(context);
                selectImage(ImageSource.gallery);
                },

              leading: Icon(Icons.photo),
              title: Text("Pick from gallery"),
            ),
            ListTile(
              onTap:(){
                Navigator.pop(context);
                selectImage(ImageSource.camera);
              },
              leading: Icon(Icons.camera),
              title: Text("Pick from camera"),
            )

          ],
        ),
      );
    });


  }
  void submit(){
    String fullname = _controller.text.trim();
    if(fullname == "" || imageFile==null){
      print("Fill the information");
    }else{
      uploadData(fullname,imageFile!);
    }

  }
  void uploadData(String name,File imageFile) async {
    UploadTask uploadTask = FirebaseStorage.instance.ref("profilePicture")
    .child(widget.userModel!.uid.toString()).putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    UserModel? user = widget.userModel;
    user?.profilePic = imageUrl;
    user?.name = name;
    await FirebaseFirestore.instance.collection("user").doc(user?.uid).set(
        user!.toMap());
    User? firebaseUser = widget.firebaseUser;
    Navigator.push(context,
        MaterialPageRoute(
            builder: (context)=> Home(
              firebaseUser: firebaseUser,
              userModel: user,
            )));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          GestureDetector(
            onTap: openDialog,
            child: CircleAvatar(
              backgroundImage: (imageFile!=null)? FileImage(imageFile!) : null,
              radius: 70, // Adjust the radius as needed
              child: Center(
                child: Icon(
                  (imageFile==null)?
                  Icons.person : null,
                  size: 100, // Adjust the icon size as needed
                ),
              ),
            ),
          ),

          SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: WidgetHelper.textFieldBuilder("Full name", _controller),
          ),
          SizedBox(height: 100,),
          WidgetHelper.buttonSignIn("Submit", submit)

        ],
      ),
    );
  }
}
