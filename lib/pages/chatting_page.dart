import 'package:chatting_app_2/helper/notification_services.dart';
import 'package:chatting_app_2/helper/widget_helper.dart';
import 'package:chatting_app_2/models/chat_room.dart';
import 'package:chatting_app_2/models/message.dart';
import 'package:chatting_app_2/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChattingPage extends StatefulWidget {
  final ChatRoom chatRoom;
  final UserModel targetUser;
  final User firebaseUser;
  final UserModel userModel;

  const ChattingPage({
    super.key,
    required this.chatRoom,
    required this.targetUser,
    required this.firebaseUser,
    required this.userModel,
  });

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {
  TextEditingController msgEditingController = TextEditingController();
  Uuid uuid = Uuid();
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  void sendMsg() {
    String msgText = msgEditingController.text.trim();
    if (msgText == "") return;
    Message message = Message(
      messageId: uuid.v1(),
      text: msgText,
      sender: widget.userModel.uid,
      seen: false,
      createdOn: DateTime.now(),
    );

    FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(widget.chatRoom.id)
        .collection("messages")
        .doc(message.messageId)
        .set(message.toMap());
    notificationServices.sendNotificationToTarget(
    widget.targetUser!.deviceToken!,
        RemoteMessage(
          notification: RemoteNotification(
            title: widget.targetUser.name!,
            body: msgText,

          )
        ));
    msgEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.targetUser.profilePic!),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.targetUser.name!),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .doc(widget.chatRoom.id)
                  .collection("messages")
              .orderBy("createdOn")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      bool isSentByUser = message["sender"] == widget.userModel.uid;
                      return Align(
                        alignment: isSentByUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: isSentByUser ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            message["text"],
                            style: TextStyle(
                              color: isSentByUser ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: WidgetHelper.textFieldBuilder(
                    "Enter a message",
                    msgEditingController,
                  ),

                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMsg,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
