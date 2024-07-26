import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUpload{
  static Future<String?> uploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      File file = File(imageFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      try {
        // Upload the file to Firebase Storage
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('uploads/$fileName')
            .putFile(file);

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
    } else {
      print("No image selected");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected')),
      );
    }


  }
}