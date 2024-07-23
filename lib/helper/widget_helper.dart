import 'package:chatting_app_2/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetHelper{

  static Widget textFieldBuilder(String text,TextEditingController _controller){

    return TextField(
      controller: _controller,

      decoration: InputDecoration(
        labelText: text,
          enabledBorder:  OutlineInputBorder(
            borderSide:  BorderSide(
                color: Colors.deepPurpleAccent,
                width: 1.0,

            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder:  OutlineInputBorder(
            borderSide:  BorderSide(color: Colors.indigo, width: 2.0,
            ),
            borderRadius: BorderRadius.circular(5.0),
          )
      ),
    );
  }
  
  static Widget buttonSignIn(String text, onpress){
    return ElevatedButton(
        onPressed:()=> onpress(),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurpleAccent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),

            )
          ),
        ),
        child: Text(text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),)
    );
  }
  static Widget tileFromUserModel(UserModel userModel,dynamic onPressed){

    return ListTile(
      onTap: ()=>onPressed,
      leading: Image.network(userModel.profilePic!),
      title: Text(userModel.name!),
      subtitle: Text(userModel.email!),
    );
  }
}