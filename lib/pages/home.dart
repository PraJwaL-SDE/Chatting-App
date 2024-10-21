import 'package:chatting_app_2/helper/GetServerKey.dart';
import 'package:chatting_app_2/helper/firebase_helper.dart';
import 'package:chatting_app_2/helper/widget_helper.dart';
import 'package:chatting_app_2/models/group_chat_room.dart';
import 'package:chatting_app_2/models/user.dart';
import 'package:chatting_app_2/pages/group_chat/create_new_group.dart';
import 'package:chatting_app_2/pages/group_chat/group_chatting_page.dart';
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
        if(chatroomMap["type"]=="dm")
        chatRoom = ChatRoom.FromMap(chatroomMap);
        else
          {

          }
      } else {
        chatRoom = ChatRoom(
          id: uuid.v1(),
          participants: {
            user.uid!: true,
            targetUser.uid!: true,
          },
          type: "dm"
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
  // first get all data

  // check the type of chatroom
  // Navigate to DM chat room
  // Navigate to group chatroom
  void goToGroupChattingPage(GroupChatRoom chatroom){

    Navigator.push(context, MaterialPageRoute(
        builder: (context)=>GroupChattingPage(chatRoom: chatroom, userModel: widget.userModel)));
  }


  void logout() async {
    WidgetHelper.loadingDialog(context, "SignOut...");
    await FirebaseAuth.instance.signOut();
    Navigator.popUntil(context,(route)=>route.isFirst);
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));

  }
  CreateNewGroup(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateNewGroupScreen(userModel: widget.userModel)));

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatting App"),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert), // Icon for the popup menu
            onSelected: (String result) {
              switch (result) {
                case 'logout':
                // Call the logout function
                  logout();
                  break;
                case 'CreteGroup':
                  CreateNewGroup();
                  break;
                case 'settings':
                // Navigate to settings page
                //   navigateToSettings();
                  break;
                case 'profile':
                // Navigate to profile page
                //   navigateToProfile();
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem<String>(
                value: 'CreteGroup',
                child: Text('Crete new Group'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
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
                  print("participants fetche : ${chatrooms.length}" );
                  return ListView.builder(
                    itemCount: chatrooms.length,
                    itemBuilder: (context, index) {
                      // Extract the data from the document
                      var chatroom = chatrooms[index].data() as Map<String, dynamic>;

                      // Provide a default value "dm" if type is not defined
                      var type = chatroom["type"] ?? "dm";

                      // Safely extract participants, default to an empty map if not present
                      var participants = chatroom['participants'] as Map<String, dynamic>? ?? {};

                      var currentUid = widget.userModel.uid;

                      if (type == "dm") {
                        return dmChatroomListTile(participants, currentUid);
                      } else {
                        // Safely access chatroom ID
                        var chatroomId = chatroom["id"] ?? "unknown";
                        return groupChatroomListTile(chatroomId);
                      }
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
  Widget dmChatroomListTile(participants,currentUid){
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
  }
  Widget groupChatroomListTile(id){
    String defaultGroupIcon =
        "https://cdn-icons-png.flaticon.com/128/11820/11820089.png";

    return FutureBuilder<GroupChatRoom?>(
        future: FirebaseHelper.getGroupChatRoomById(id),
        builder: (context,snapshot){
          if(snapshot.hasData){
            GroupChatRoom chatRoom = snapshot.data! ;

            return ListTile(
                    onTap: (){
                      goToGroupChattingPage(chatRoom);

                    },
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(chatRoom.groupIcon ?? defaultGroupIcon),
                      radius: 30,
                    ),
                    title: Text(chatRoom.name!),
                    subtitle: Text("Group"),
            );

          }
          else if (snapshot.hasError) {
            return ListTile(
              title: Text('Error loading user'),
              subtitle: Text(snapshot.error.toString()),
            );
          } else {
            return ListTile(
              title: Text('Loading...'),
            );
          }
        }
    );



  }
}
