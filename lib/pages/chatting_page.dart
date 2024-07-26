import 'package:chatting_app_2/helper/image_upload.dart';
import 'package:chatting_app_2/helper/notification_services.dart';
import 'package:chatting_app_2/helper/widget_helper.dart';
import 'package:chatting_app_2/models/chat_room.dart';
import 'package:chatting_app_2/models/message.dart';
import 'package:chatting_app_2/models/user.dart';
import 'package:chatting_app_2/pages/image_view.dart';
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
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_){
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        }
    );

  }

  void sendMsg(String msgText,String type) {

    if (msgText == "") return;
    Message message = Message(
      messageId: uuid.v1(),
      text: msgText,
      sender: widget.userModel.uid,
      seen: false,
      createdOn: DateTime.now(),
      type: type
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
            title: widget.userModel.name!,
            body: msgText,

          )
        ));
    msgEditingController.clear();
  }
  // get Img from gallery
  void sendImg() async {
    String? imgUrl = await ImageUpload.uploadImage(context);
    if(imgUrl!=null){
      sendMsg(imgUrl, "image");
    }
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
              .orderBy("createdOn", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var messages = snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      // get message model for load content
                      Message msgModel = Message.fromMap(message.data() as Map<String,dynamic>);
                      DateTime dateTime = message['createdOn'].toDate();
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
                          child: Column(
                            crossAxisAlignment: isSentByUser? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              msgModel.type == "image" ?
                                  Container(
                                    height: 300,

                                      width: 300,
                                      child: GestureDetector(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>ImageView(imageUrl: msgModel.text!)));
                                        },
                                        child: Image.network(
                                            msgModel.text!,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (BuildContext context, Widget child,
                                              ImageChunkEvent? loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },

                                        ),
                                      )
                                  ) :
                              Text(
                                message["text"],
                                style: TextStyle(
                                  color: isSentByUser ? Colors.white : Colors.black,
                                  fontSize: 18
                                ),
                              ),
                              Text(
                                  dateTime.hour.toString().padLeft(2,'0')+":"+dateTime.minute.toString().padLeft(2,'0'),
                                style: TextStyle(
                                  fontSize: 13
                                ),

                              )
                            ],
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
                    onPressed: sendImg,
                    icon: Icon(Icons.image)),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: (){
                    String msgText = msgEditingController.text.trim();
                    sendMsg(msgText,"text");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
