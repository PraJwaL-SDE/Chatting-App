import 'package:chatting_app_2/helper/widget_helper.dart';
import 'package:chatting_app_2/models/chat_room.dart';
import 'package:chatting_app_2/models/user.dart';
import 'package:chatting_app_2/pages/chatting_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SearchUser extends StatefulWidget {
  final User firebaseUser;
  final UserModel userModel;
  const SearchUser({super.key, required this.firebaseUser, required this.userModel});

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  TextEditingController _controller = TextEditingController();
  Uuid uuid = Uuid();
  UserModel? targetUser;
  void search(){
    setState(() { });
  }
  Future<ChatRoom?> getChatRoom(UserModel user, UserModel targetUser) async {
    ChatRoom? chatRoom;

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("chatrooms")
          .where("participants.${user.uid}", isEqualTo: true)
          .where("participants.${targetUser.uid}", isEqualTo: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> chatroomMap = querySnapshot.docs[0].data() as Map<String, dynamic>;
        chatRoom = ChatRoom.FromMap(chatroomMap);
      } else {
        chatRoom = ChatRoom(
          id: uuid.v1(),
          participants: {
            user.uid.toString(): true,
            targetUser.uid.toString(): true,
          },
        );

        await FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(chatRoom.id.toString())
            .set(chatRoom.toMap());
      }
    } catch (e) {
      print("Error fetching or creating chat room: $e");
    }

    return chatRoom;
  }

  void goToChattingPage()async{
    print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    print("Get Chat Room call");
    ChatRoom? chatRoom = await getChatRoom(widget.userModel, targetUser!);
    if(chatRoom!=null){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ChattingPage(
        chatRoom: chatRoom,
        targetUser: targetUser!,
        firebaseUser: widget.firebaseUser,
        userModel: widget.userModel,
      )));
    }else{
      print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
      print("Error in chatroom");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search User"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: WidgetHelper.textFieldBuilder("Enter Email", _controller),
          ),
          WidgetHelper.buttonSignIn("Search",search),
          SizedBox(height: 20),
          
          StreamBuilder(
              stream: FirebaseFirestore.instance.collection("user").where("email",isEqualTo: _controller.text.trim()).snapshots(),
              builder: (context,snapshot){
                if(snapshot.connectionState == ConnectionState.active){
                  if(snapshot.hasData){
                    QuerySnapshot docSna = snapshot.data as QuerySnapshot;
                    if(docSna.docs.length > 0){
                      Map<String,dynamic> userMap = docSna.docs[0].data() as Map<String,dynamic>;
                      targetUser = UserModel.FromMap(userMap);

                      return ListTile(
                        onTap: goToChattingPage,
                        leading: Image.network(targetUser!.profilePic!),
                        title: Text(targetUser!.name!),
                        subtitle: Text(targetUser!.email!),
                      );
                    }else{
                      return Text("User Not Found");
                    }

                  }else
                    if(snapshot.hasError){
                      print("------------Error-----------");
                    }else{
                      return Text("User Not Found");
                    }
                }
                return CircularProgressIndicator();
              }
          )
        ],
      ),
    );
  }
}
