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

  static Future<void> loadingDialog(BuildContext context, String text){
    AlertDialog alertDialog = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: CircularProgressIndicator(
              color: Colors.lightBlue,
              strokeWidth: 6,
            ),
          ),

          Text(text)
        ],
      ),
    );

    return showDialog(context: context, builder: (context){
      return alertDialog;
    });
  }

  static Future<void> errorDialog(BuildContext context, String title , String content)async{
    AlertDialog alertDialog = AlertDialog(
      title: Center(child: Text(title)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Text(content),
          SizedBox(height: 10,),
          Center(
            child: ElevatedButton(onPressed: ()=>Navigator.pop(context),
                child: Text("ok")
            ),
          )
        ],
      ),
    );
    return showDialog(context: context, builder: (context){
      return alertDialog;
    });
  }

}