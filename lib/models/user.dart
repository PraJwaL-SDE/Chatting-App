class UserModel {
  String? name;
  String? uid;
  String? email;
  String? profilePic;

  UserModel({this.uid,this.name,this.email,this.profilePic});

  UserModel.FromMap(Map<String,dynamic> map){
    name = map['name'];
    uid = map['uid'];
    email = map['email'];
    profilePic = map['profilePic'];
  }

  Map<String,dynamic> toMap(){
    return{
      "uid" : uid,
      "name" : name,
      "email" : email,
      "profilePic" : profilePic
    };
  }

}