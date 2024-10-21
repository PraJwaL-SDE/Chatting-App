import 'dart:io';

import 'package:chatting_app_2/models/group_chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class FirebaseHelper{

  static Future<UserModel?> getUserModelById(String uid)async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("user").doc(uid).get();
    if(documentSnapshot!=null){
      return UserModel.FromMap(documentSnapshot.data() as Map<String,dynamic>);
    }
  }
  static Future<GroupChatRoom?> getGroupChatRoomById(String uid) async {
    print("Finding Group chat model for id $uid");
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("chatrooms").doc(uid).get();
    if(documentSnapshot!=null){
      print("Data found ${documentSnapshot.data()}");
      return GroupChatRoom.fromMap(documentSnapshot.data() as Map<String,dynamic>);
    }

  }

  static Future<String?> uploadImage(BuildContext context, File imageFile) async{
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      // Upload the file to Firebase Storage
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Store the download URL in Realtime Database
      return downloadUrl;


    } catch (e) {
      // Handle errors
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }

  }

}