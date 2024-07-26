import 'package:chatting_app_2/helper/GetServerKey.dart';
import 'package:chatting_app_2/helper/firebase_helper.dart';
import 'package:chatting_app_2/helper/widget_helper.dart';
import 'package:chatting_app_2/models/user.dart';
import 'package:chatting_app_2/pages/login.dart';
import 'package:chatting_app_2/pages/search_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../helper/message_service.dart';
import '../helper/notification_services.dart';
import '../models/chat_room.dart';
import 'chatting_page.dart';

class Home extends StatefulWidget {
  final User? firebaseUser;
  final UserModel userModel;
  const Home({super.key, required this.firebaseUser, required this.userModel});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserModel? targetUser;
  final Uuid uuid = Uuid();
  NotificationServices notificationServices = NotificationServices();
  final MessageService _messageService = MessageService();

  void loadToken() async{
    String? token = await notificationServices.getDeviceToken();

    print(token);

    // notificationServices.sendNotificationToTarget(token!,RemoteMessage(
    //   notification: RemoteNotification(
    //     title: "Test",
    //     body: "hello from another device"
    //   )
    // ));h





  }


  @override
  void initState() {
    // e-C3_PA0T2KYCHQb6tDYlW:APA91bFOgjf
    notificationServices.initLocalNotificationPlugin();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit();
    // notificationServices.showNotification(
    //   RemoteMessage(
    //     notification: RemoteNotification(
    //         title: "Noti",
    //         body: "this is noti"
    //     )
    //   )
    // );
    print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    loadToken();
    // token

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
            user.uid!: true,
            targetUser.uid!: true,
          },
        );

        await FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(chatRoom.id)
            .set(chatRoom.toMap());
      }
    } catch (e) {
      print("Error fetching or creating chat room: $e");
    }

    return chatRoom;
  }

  void goToChattingPage() async {
    if (targetUser != null) {
      ChatRoom? chatRoom = await getChatRoom(widget.userModel, targetUser!);
      if (chatRoom != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChattingPage(
              chatRoom: chatRoom,
              targetUser: targetUser!,
              firebaseUser: widget.firebaseUser!,
              userModel: widget.userModel,
            ),
          ),
        );
      } else {
        print("Error in chatroom");
      }
    }
  }

  void logout() async {
    WidgetHelper.loadingDialog(context, "SignOut...");
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context,(route)=>route.isFirst);
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatting App"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
            ),
            onPressed: (){
              logout();
            },
          ),
          SizedBox(width: 20,)
        ],
      ),
      floatingActionButton: FloatingActionButton(

        child: Icon(Icons.search_rounded),

        onPressed: () {
          // WidgetHelper.loadingDialog(context, "Loading");
          // WidgetHelper.errorDialog(context, "search", "You can search here using there email address");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchUser(
                firebaseUser: widget.firebaseUser!,
                userModel: widget.userModel,
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .where("participants.${widget.userModel.uid}", isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var chatrooms = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: chatrooms.length,
                    itemBuilder: (context, index) {
                      var chatroom = chatrooms[index];
                      var participants = chatroom['participants'] as Map<String, dynamic>;
                      var currentUid = widget.userModel.uid;
                      var targetUid = participants.keys.firstWhere((uid) => uid != currentUid);

                      return FutureBuilder<UserModel?>(
                        future: FirebaseHelper.getUserModelById(targetUid),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.hasData) {
                            var user = userSnapshot.data!;
                            return ListTile(
                              onTap: () {
                                setState(() {
                                  targetUser = user;
                                });
                                goToChattingPage();
                              },
                              leading: Image.network(user.profilePic!),
                              title: Text(user.name!),
                              subtitle: Text(user.email!),
                            );
                          } else if (userSnapshot.hasError) {
                            return ListTile(
                              title: Text('Error loading user'),
                              subtitle: Text(userSnapshot.error.toString()),
                            );
                          } else {
                            return ListTile(
                              title: Text('Loading...'),
                            );
                          }
                        },
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
        ],
      ),
    );
  }
}
