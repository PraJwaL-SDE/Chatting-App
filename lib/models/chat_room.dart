class ChatRoom {
  String? id;
  Map<String,dynamic>? participants;
  String? lastMessage;
  String? type;

  ChatRoom({this.id,this.participants,this.lastMessage,this.type});

  ChatRoom.FromMap(Map<String,dynamic> map){
    id = map["id"];
    participants = map["participants"];
    lastMessage = map["lastMessage"];
    type = map["type"];
  }

  Map<String,dynamic> toMap(){
    return {
      "id":id,
      "participants" : participants,
      "lastMessage" : lastMessage,
      "type" : type
    };
  }

}