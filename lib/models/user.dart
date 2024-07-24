class UserModel {
  String? name;
  String? uid;
  String? email;
  String? profilePic;
  String? deviceToken;

  UserModel({this.uid,this.name,this.email,this.profilePic,this.deviceToken});

  UserModel.FromMap(Map<String,dynamic> map){
    name = map['name'];
    uid = map['uid'];
    email = map['email'];
    profilePic = map['profilePic'];
    deviceToken = map['deviceToken'];
  }

  Map<String,dynamic> toMap(){
    return{
      "uid" : uid,
      "name" : name,
      "email" : email,
      "profilePic" : profilePic,
      "deviceToken" : deviceToken
    };
  }

}