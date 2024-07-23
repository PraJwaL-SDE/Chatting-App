import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class FirebaseHelper{

  static Future<UserModel?> getUserModelById(String uid)async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection("user").doc(uid).get();
    if(documentSnapshot!=null){
      return UserModel.FromMap(documentSnapshot.data() as Map<String,dynamic>);
    }
  }

}