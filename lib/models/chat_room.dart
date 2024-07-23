class ChatRoom {
  String? id;
  Map<String,dynamic>? participants;
  String? lastMessage;

  ChatRoom({this.id,this.participants,this.lastMessage});

  ChatRoom.FromMap(Map<String,dynamic> map){
    id = map["id"];
    participants = map["participants"];
    lastMessage = map["lastMessage"];
  }

  Map<String,dynamic> toMap(){
    return {
      "id":id,
      "participants" : participants,
      "lastMessage" : lastMessage
    };
  }

}